import 'package:eco_venture/models/google_user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Used for debugPrint
import 'package:google_sign_in/google_sign_in.dart';

// Your Web Client ID is used here
const String kGoogleServerClientId = '547444130498-bov8shk21qfrhbi94rvt32bo03uq37qd.apps.googleusercontent.com';


class AuthService {
  // 1. Singleton pattern setup
  AuthService._();
  static final AuthService authInstance = AuthService._();

  // 2. Class fields
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn signIn = GoogleSignIn.instance; // Use the singleton instance
  bool _initialized = false;

  // 3. Initialization Method (Corrected syntax)
  Future<void> init() async {
    if (_initialized) return;

    try {
      await signIn.initialize(
        serverClientId: kGoogleServerClientId,
        // Scopes are omitted here as they are handled automatically for basic login
      );
      _initialized = true;
      debugPrint("GoogleSignIn initialized successfully.");
    } catch (e) {
      debugPrint("GoogleSignIn initialization failed: $e");
    }
  }

  // 4. Google Sign-In Logic
  Future<GoogleUserData> continueWithGoogle() async {
    try {
      if (!_initialized) {
        await init();
      }

      // v7.x method for interactive sign-in
      final GoogleSignInAccount account = await signIn.authenticate();

      final GoogleSignInAuthentication googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception("Google ID token is null. Check client ID configuration and platform setup.");
      }

      return GoogleUserData(
        idToken: idToken,
        email: account.email,
        displayName: account.displayName ?? "Unknown User",
      );

    } on GoogleSignInException catch (e, stack) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // User explicitly cancelled the sign-in flow
        throw Exception("Google sign-in cancelled by user.");
      }
      debugPrint("Google sign-in failed (Code: ${e.code.name}): ${e.description}\n$stack");
      throw Exception("Google sign-in failed: ${e.description ?? e.toString()}");
    } catch (e, stack) {
      debugPrint("Google sign-in failed: $e\n$stack");
      throw Exception("Google sign-in failed: ${e.toString()}");
    }
  }

  // 5. Firebase Forgot Password (Corrected syntax)
  // FIX 1: Added explicit parameters '()'
  Future<void> forgot(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "An authentication error occurred");
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  // 6. Firebase Logout (Corrected syntax)
  // FIX 1 & 2: Removed 'static' (extraneous_modifier) and added explicit parameters '()'
  Future<void> logout() async {
    try {
      await signIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception("Logout failed: ${e.toString()}");
    }
  }
}