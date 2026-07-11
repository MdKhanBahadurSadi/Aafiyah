import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Stream<UserModel?> authStateChanges() {
    var isInitialEvent = true;
    return FirebaseAuth.instance.idTokenChanges().asyncMap((firebaseUser) {
      // Firebase does not emit auth changes when an account is disabled or
      // deleted remotely. Check once on startup; later token refresh is managed
      // by Firebase Auth itself.
      final shouldValidateSession = isInitialEvent && firebaseUser != null;
      isInitialEvent = false;
      return _userFromFirebaseUser(
        firebaseUser,
        validateSession: shouldValidateSession,
      );
    });
  }

  @override
  Future<UserModel?> getCurrentUser() {
    return _userFromFirebaseUser(
      FirebaseAuth.instance.currentUser,
      validateSession: true,
    );
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    final userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    return _userFromFirebaseUser(userCredential.user, emailFallback: email);
  }

  @override
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    required int age,
    required String gender,
  }) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      // Update display name in Firebase Auth
      await firebaseUser.updateDisplayName(name);

      final newUser = UserModel(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        age: age,
        gender: gender,
      );

      // Save user profile to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .set(newUser.toJson());

      return newUser;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    // Firebase is the source of truth for the app session. Clear that session
    // even if Google sign-out has a transient plugin error.
    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // Google sign-out is best effort; Firebase has already been signed out.
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();

      // If the user cancels the sign-in, return null to indicate cancellation
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      // Ensure a user document exists in Firestore
      final usersRef = FirebaseFirestore.instance.collection('users');
      final docRef = usersRef.doc(firebaseUser.uid);
      try {
        final snapshot = await docRef.get().timeout(const Duration(seconds: 3));

        if (!snapshot.exists) {
          final newUser = _fallbackUser(firebaseUser);
          await docRef
              .set(newUser.toJson())
              .timeout(const Duration(seconds: 3));
          return newUser;
        }

        // If document exists, map it to UserModel.
        return UserModel.fromJson(snapshot.data()!);
      } catch (_) {
        // Firebase authentication succeeded even if the optional profile
        // lookup is unavailable. Keep the session and use Firebase's identity.
        return _fallbackUser(firebaseUser);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> _userFromFirebaseUser(
    User? firebaseUser, {
    String? emailFallback,
    bool validateSession = false,
  }) async {
    if (firebaseUser == null) return null;
    var activeUser = firebaseUser;

    if (validateSession) {
      try {
        // Verify the persisted refresh credential. Firebase normally refreshes
        // tokens automatically; doing so here detects revoked/expired sessions
        // before routing into the authenticated app.
        await activeUser.getIdToken(true).timeout(const Duration(seconds: 3));
        await activeUser.reload().timeout(const Duration(seconds: 3));
        final refreshedUser = FirebaseAuth.instance.currentUser;
        if (refreshedUser == null) return null;
        activeUser = refreshedUser;
      } on FirebaseAuthException catch (error) {
        const invalidSessionCodes = {
          'user-disabled',
          'user-not-found',
          'user-token-expired',
          'invalid-user-token',
        };
        if (invalidSessionCodes.contains(error.code)) {
          await _clearInvalidSession();
          return null;
        }
        // Network and service errors are not proof that the cached session is
        // invalid. Keep the local Firebase identity and let it retry later.
      } on TimeoutException {
        // Keep the cached identity when validation cannot complete offline.
      } catch (_) {
        // Treat unclassified validation failures as transient as well.
      }
    }

    final profile = FirebaseFirestore.instance
        .collection('users')
        .doc(activeUser.uid);
    try {
      final cachedDoc = await profile.get(
        const GetOptions(source: Source.cache),
      );
      if (cachedDoc.exists) {
        return UserModel.fromJson(cachedDoc.data()!);
      }
    } catch (_) {
      // No cached profile is normal on a fresh install. Try the server below.
    }

    try {
      final doc = await profile.get().timeout(const Duration(seconds: 3));
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
    } catch (_) {
      // Profile data is optional for restoring the Firebase session. When
      // offline or when Firestore data is malformed, use Firebase's cached
      // identity fields and leave the user signed in.
    }

    return _fallbackUser(activeUser, emailFallback: emailFallback);
  }

  Future<void> _clearInvalidSession() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // The auth stream also returns null for the invalid startup snapshot.
    }
  }

  UserModel _fallbackUser(User firebaseUser, {String? emailFallback}) {
    return UserModel(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'No Name',
      email: firebaseUser.email ?? emailFallback ?? '',
      age: 0,
      gender: 'Not Specified',
    );
  }
}
