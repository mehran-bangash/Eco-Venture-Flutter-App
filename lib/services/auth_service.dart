import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/google_user_data.dart';

class AuthService {
  AuthService._();

  static final AuthService authInstance = AuthService._();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn signIn = GoogleSignIn.instance;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await signIn.initialize();
    _initialized = true;
  }

  Future<GoogleUserData> continueWithGoogle() async {
    try {
      if (!_initialized) {
        await init();
      }

      final GoogleSignInAccount account = await signIn.authenticate();

      final googleAuth = account.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) throw Exception("Google ID token is null");

      return GoogleUserData(
        idToken: idToken,
        email: account.email ?? "",
        displayName: account.displayName ?? "Unknown User",
      );

    } catch (e, stack) {
      debugPrint("Google sign-in failed: $e\n$stack");
      throw Exception("Google sign-in failed: $e");
    }
  }

  Future<void> forgot(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "An authentication error occurred");
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e, stack) {
      throw Exception("Logout failed: $e");
    }
  }


}
