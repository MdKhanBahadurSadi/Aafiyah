import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      // Fetch user profile from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      } else {
        // Fallback for cases where documentation doesn't exist (e.g., partial registration)
        return UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? "No Name",
          email: firebaseUser.email ?? email,
          age: 0,
          gender: "Not Specified",
        );
      }
    } catch (e) {
      rethrow;
    }
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
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

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
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
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
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      // Ensure a user document exists in Firestore
      final usersRef = FirebaseFirestore.instance.collection('users');
      final docRef = usersRef.doc(firebaseUser.uid);
      final snapshot = await docRef.get();
      
      if (!snapshot.exists) {
        final newUser = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          age: 0,
          gender: 'Not Specified',
        );
        await docRef.set(newUser.toJson());
        return newUser;
      }

      // If document exists, map it to UserModel
      final data = snapshot.data()!;
      return UserModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
