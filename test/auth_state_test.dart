import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:aafiyah/features/auth/auth_state.dart';
import 'package:aafiyah/features/auth/models/user_model.dart';
import 'package:aafiyah/features/auth/repository/auth_repository.dart';

void main() {
  test('restores the persisted user from the initial auth snapshot', () async {
    final repository = _FakeAuthRepository();
    final authState = AuthState(repository: repository);
    const user = UserModel(
      uid: 'uid-1',
      name: 'Test User',
      email: 'test@example.com',
      age: 30,
      gender: 'Other',
    );

    expect(authState.isInitializing, isTrue);
    expect(authState.isAuthenticated, isFalse);

    repository.authChanges.add(user);
    await authState.initialization;

    expect(authState.isInitializing, isFalse);
    expect(authState.isAuthenticated, isTrue);
    expect(authState.currentUser, user);

    authState.dispose();
    await repository.dispose();
  });

  test('finishes startup as signed out when Firebase has no session', () async {
    final repository = _FakeAuthRepository();
    final authState = AuthState(repository: repository);

    repository.authChanges.add(null);
    await authState.initialization;

    expect(authState.isInitializing, isFalse);
    expect(authState.isAuthenticated, isFalse);

    authState.dispose();
    await repository.dispose();
  });

  test('explicit logout clears the in-memory authenticated user', () async {
    final repository = _FakeAuthRepository();
    final authState = AuthState(repository: repository);
    const user = UserModel(
      uid: 'uid-1',
      name: 'Test User',
      email: 'test@example.com',
      age: 30,
      gender: 'Other',
    );

    repository.authChanges.add(user);
    await authState.initialization;
    await authState.logout();

    expect(repository.logoutCalled, isTrue);
    expect(authState.isAuthenticated, isFalse);
    expect(authState.currentUser, isNull);

    authState.dispose();
    await repository.dispose();
  });

  test(
    'recovers the locally persisted user if the auth stream errors',
    () async {
      const user = UserModel(
        uid: 'uid-2',
        name: 'Offline User',
        email: 'offline@example.com',
        age: 25,
        gender: 'Not Specified',
      );
      final repository = _FakeAuthRepository(currentUser: user);
      final authState = AuthState(repository: repository);

      repository.authChanges.addError(StateError('temporary stream failure'));
      await authState.initialization;

      expect(authState.isInitializing, isFalse);
      expect(authState.currentUser, user);

      authState.dispose();
      await repository.dispose();
    },
  );
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.currentUser});

  final UserModel? currentUser;
  final StreamController<UserModel?> authChanges = StreamController();
  bool logoutCalled = false;

  Future<void> dispose() => authChanges.close();

  @override
  Stream<UserModel?> authStateChanges() => authChanges.stream;

  @override
  Future<UserModel?> getCurrentUser() async => currentUser;

  @override
  Future<UserModel?> login(String email, String password) async => currentUser;

  @override
  Future<UserModel?> signInWithGoogle() async => currentUser;

  @override
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    required int age,
    required String gender,
  }) async => currentUser;

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  Future<void> sendPasswordReset(String email) async {}
}
