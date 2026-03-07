import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service for handling authentication logic with Firebase.
class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Stream of current user's ID.
  Stream<String?> get onAuthStateChanged =>
      _auth.authStateChanges().map((user) => user?.uid);

  /// Current user ID.
  String? get currentUserId => _auth.currentUser?.uid;

  /// Whether the user is currently signed in.
  bool get isAuthenticated => _auth.currentUser != null;

  /// Sign in with email and password.
  Future<String?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user?.uid;
    } catch (e) {
      debugPrint('[AuthService] Sign-in error: $e');
      rethrow;
    }
  }

  /// Sign up with email and password.
  Future<String?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user?.uid;
    } catch (e) {
      debugPrint('[AuthService] Sign-up error: $e');
      rethrow;
    }
  }

  /// Sign in with Google.
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final fb.OAuthCredential credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user?.uid;
    } catch (e) {
      debugPrint('[AuthService] Google sign-in error: $e');
      rethrow;
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  /// Restore session (e.g., on app start).
  Future<String?> restoreSession() async {
    return _auth.currentUser?.uid;
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
