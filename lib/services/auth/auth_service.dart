import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_venture/models/google_user_data.dart';
import 'package:eco_venture/services/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

const String kGoogleServerClientId = '547444130498-bov8shk21qfrhbi94rvt32bo03uq37qd.apps.googleusercontent.com';

class AuthService {
  AuthService._();
  static final AuthService authInstance = AuthService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Use the standard GoogleSignIn instance
  final GoogleSignIn signIn = GoogleSignIn.instance;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await signIn.initialize(
        serverClientId: kGoogleServerClientId,
      );
      _initialized = true;
    } catch (e) {
      debugPrint("GoogleSignIn init error: $e");
    }
  }

  Future<GoogleUserData> continueWithGoogle() async {
    try {
      if (!_initialized) {
        await init();
      }

      final GoogleSignInAccount account = await signIn.authenticate();
      final GoogleSignInAuthentication googleAuth = account.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception("Google ID token is null.");
      }

      return GoogleUserData(
        idToken: idToken,
        email: account.email,
        displayName: account.displayName ?? "Unknown User",
      );

    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw Exception("Google sign-in cancelled by user.");
      }
      throw Exception("Login Failed: ${e.toString()}");
    } catch (e) {
      throw Exception("Login Error: ${e.toString()}");
    }
  }

  Future<void> forgot(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception("Reset password failed: $e");
    }
  }

  Future<void> logout() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': FieldValue.delete(),
        });
      }
      await SharedPreferencesHelper.instance.clearAll();
      await _auth.signOut();
      try {
        await signIn.signOut();
      } catch (_) {}

    } catch (e) {
      debugPrint("Sign Out Error: $e");
    }
  }
}