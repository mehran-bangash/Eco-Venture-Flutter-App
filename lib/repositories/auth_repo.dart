
import 'package:eco_venture/core/config/api_constants.dart';
import 'package:eco_venture/models/user_model.dart';
import 'package:eco_venture/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/api_service.dart';

class AuthRepo {
  AuthRepo._();

  static final AuthRepo getInstance = AuthRepo._();
  final ApiService _apiService = ApiService();

  Future<UserModel?> signUpUser(
    String email,
    String password,
    String role,
    String name,
  ) async {
    var requestBody = {
      'email': email,
      'password': password,
      'role': role,
      'name': name,
    };

    final userData = await _apiService.sendUserToken(
      ApiConstants.signUpEndpoint,
      requestBody,
    );

    // Sign in to Firebase with custom token from Node.js
    if (userData.containsKey("token")) {
      await FirebaseAuth.instance.signInWithCustomToken(userData["token"]);
    }

    return UserModel(
      uid: userData['uid'],
      displayName: name,
      email: email,
      role: role,
      createdAt: DateTime.now(),
    );
  }
  Future<UserModel?> loginUser(String email, String password) async {
    try {

      final userData = await _apiService.sendUserToken(
        ApiConstants.signInEndpoint,
        {
          'email': email,
          'password': password,
        },
      );

      return UserModel(
        uid: userData['uid'],
        displayName: userData['name'] ?? '',
        email: userData['email'] ?? '',
        role: userData['role'] ?? 'unknown',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }
  Future<UserModel?> sendTokenOfGoogle(String role) async {
    final googleUser = await AuthService.authInstance.continueWithGoogle();

    final requestBody = {
      'idToken': googleUser.idToken ,
      'email': googleUser.email ,
      'name': googleUser.displayName,
      'role': role.isNotEmpty ? role : "user",  // safer check
    };

    final response = await _apiService.sendUserToken(
      ApiConstants.googleEndpoint,
      requestBody,
    );

    return UserModel.fromMap(response);
  }


  Future<void> forgotUser(String email) async {
    await AuthService.authInstance.forgot(email);
  }

  Future<void> logout()async{
    await AuthService.authInstance.logout();
  }


}
