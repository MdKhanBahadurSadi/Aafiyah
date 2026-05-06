import '../models/user_model.dart';

abstract class AuthRepository {
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
