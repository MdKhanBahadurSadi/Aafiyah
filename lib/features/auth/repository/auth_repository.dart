import '../models/user_model.dart';

abstract class AuthRepository {
  /// Emits the persisted Firebase session first, then later auth/token changes.
  Stream<UserModel?> authStateChanges();

  /// Reads Firebase's locally persisted user if the auth stream cannot start.
  Future<UserModel?> getCurrentUser();

  Future<UserModel?> login(String email, String password);
  Future<UserModel?> signInWithGoogle();
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    required int age,
    required String gender,
  });
  Future<void> logout();
  Future<void> sendPasswordReset(String email);
}
