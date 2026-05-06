import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aafiyah/features/auth/models/user_model.dart';
import 'package:aafiyah/features/auth/repository/auth_repository.dart';
import 'package:aafiyah/features/auth/repository/auth_repository_impl.dart';
import 'package:aafiyah/core/state/app_state.dart';

class AuthState extends ChangeNotifier {
  final AuthRepository _repository = AuthRepositoryImpl();
  UserModel? _user;
  bool _isInitializing = true;

  AuthState() {
    _initialize();
  }

  UserModel? get user => _user;
  UserModel? get currentUser => _user;
  bool get isAuthenticated => _user != null;
  bool get isInitializing => _isInitializing;

  void _initialize() {
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _user = null;
        _isInitializing = false;
        notifyListeners();
      } else {
        // Fetch user profile from Firestore if not already set or if uid changed
        if (_user == null || _user!.uid != firebaseUser.uid) {
          try {
            final doc = await FirebaseFirestore.instance
                .collection('users')
                .doc(firebaseUser.uid)
                .get();

            if (doc.exists) {
              _user = UserModel.fromJson(doc.data()!);
            } else {
              _user = UserModel(
                uid: firebaseUser.uid,
                name: firebaseUser.displayName ?? "No Name",
                email: firebaseUser.email ?? "",
                age: 0,
                gender: "Not Specified",
              );
            }
          } catch (e) {
            debugPrint("Error fetching user profile: $e");
          }
        }
        _isInitializing = false;
        notifyListeners();
      }
    });
  }

  Future<void> login(String email, String password, AppState appState) async {
    appState.setLoading(true);
    appState.clearError();
    try {
      _user = await _repository.login(email, password);
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
      notifyListeners();
    } catch (e) {
      appState.setError("Registration failed: ${e.toString()}");
    } finally {
      appState.setLoading(false);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
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
      notifyListeners();
    } catch (e) {
      appState.setError("Google sign-in failed: ${e.toString()}");
    } finally {
      appState.setLoading(false);
    }
  }
}
