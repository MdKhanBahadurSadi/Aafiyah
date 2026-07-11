import 'dart:async';

import 'package:flutter/material.dart';
import 'package:aafiyah/features/auth/models/user_model.dart';
import 'package:aafiyah/features/auth/repository/auth_repository.dart';
import 'package:aafiyah/features/auth/repository/auth_repository_impl.dart';
import 'package:aafiyah/core/state/app_state.dart';
import 'package:aafiyah/core/services/notification_service.dart';

class AuthState extends ChangeNotifier {
  AuthState({AuthRepository? repository})
    : _repository = repository ?? AuthRepositoryImpl() {
    _initialize();
  }

  final AuthRepository _repository;
  UserModel? _user;
  bool _isInitializing = true;
  bool _disposed = false;
  int _authEventVersion = 0;
  final Completer<void> _initializationCompleter = Completer<void>();
  StreamSubscription<UserModel?>? _authSubscription;

  UserModel? get user => _user;
  UserModel? get currentUser => _user;
  bool get isAuthenticated => _user != null;
  bool get isInitializing => _isInitializing;
  Future<void> get initialization => _initializationCompleter.future;

  void _initialize() {
    try {
      _authSubscription = _repository.authStateChanges().listen(
        _handleAuthChange,
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('Firebase auth state stream error: $error');
          unawaited(_restoreCurrentUserAfterStreamError());
        },
        onDone: () {
          if (_isInitializing) {
            unawaited(_restoreCurrentUserAfterStreamError());
          }
        },
      );
    } catch (error) {
      debugPrint('Unable to start Firebase auth state stream: $error');
      unawaited(_restoreCurrentUserAfterStreamError());
    }
  }

  void _handleAuthChange(UserModel? user) {
    if (_disposed) return;
    final previousUid = _user?.uid;
    _authEventVersion++;
    _user = user;
    if (previousUid != user?.uid) {
      if (previousUid != null) {
        unawaited(NotificationService().unregisterUserDevice(previousUid));
      }
      if (user != null) {
        unawaited(NotificationService().registerUserDevice(user.uid));
      }
    }
    _finishInitialization();
    notifyListeners();
  }

  Future<void> _restoreCurrentUserAfterStreamError() async {
    final eventVersion = _authEventVersion;
    UserModel? restoredUser;
    try {
      restoredUser = await _repository.getCurrentUser();
    } catch (error) {
      // Do not drop a previously restored session because a stream failed.
      debugPrint('Unable to read the cached Firebase user: $error');
    }

    if (_disposed || eventVersion != _authEventVersion) return;
    if (restoredUser != null || _isInitializing) {
      _user = restoredUser;
    }
    _finishInitialization();
    notifyListeners();
  }

  void _finishInitialization() {
    _isInitializing = false;
    if (!_initializationCompleter.isCompleted) {
      _initializationCompleter.complete();
    }
  }

  Future<void> login(String email, String password, AppState appState) async {
    appState.setLoading(true);
    appState.clearError();
    try {
      _user = await _repository.login(email, password);
      if (_user != null) {
        unawaited(NotificationService().registerUserDevice(_user!.uid));
      }
      // Listener will also handle this, but setting it here for immediate feedback
      notifyListeners();
    } catch (e) {
      appState.setError("Login failed: ${e.toString()}");
    } finally {
      appState.setLoading(false);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required int age,
    required String gender,
    required AppState appState,
  }) async {
    appState.setLoading(true);
    appState.clearError();
    try {
      _user = await _repository.register(
        name: name,
        email: email,
        password: password,
        age: age,
        gender: gender,
      );
      if (_user != null) {
        unawaited(NotificationService().registerUserDevice(_user!.uid));
      }
      notifyListeners();
    } catch (e) {
      appState.setError("Registration failed: ${e.toString()}");
    } finally {
      appState.setLoading(false);
    }
  }

  Future<void> logout() async {
    final uid = _user?.uid;
    if (uid != null) await NotificationService().unregisterUserDevice(uid);
    await _repository.logout();
    if (_disposed) return;
    _authEventVersion++;
    _user = null;
    _finishInitialization();
    notifyListeners();
  }

  Future<void> sendPasswordReset(String email, AppState appState) async {
    appState.setLoading(true);
    appState.clearError();
    try {
      await _repository.sendPasswordReset(email);
    } catch (e) {
      appState.setError(e.toString());
      rethrow;
    } finally {
      appState.setLoading(false);
    }
  }

  Future<void> signInWithGoogle(AppState appState) async {
    appState.setLoading(true);
    appState.clearError();
    try {
      final user = await _repository.signInWithGoogle();
      // If user is null, sign-in was cancelled by the user. Don't treat as error.
      if (user == null) {
        appState.clearError();
        return;
      }
      _user = user;
      unawaited(NotificationService().registerUserDevice(user.uid));
      notifyListeners();
    } catch (e) {
      appState.setError("Google sign-in failed: ${e.toString()}");
    } finally {
      appState.setLoading(false);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _authEventVersion++;
    unawaited(_authSubscription?.cancel());
    super.dispose();
  }
}
