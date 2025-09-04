import 'package:eco_venture/models/user_model.dart';
import 'package:eco_venture/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepo {
  AuthRepo._();

  static final AuthRepo getInstance = AuthRepo._();

  Future<UserModel?> signUpUser(String email, String password,String role) async {
    User? firebaseUser = await AuthService.authInstance.signUp(email, password);

    if (firebaseUser != null) {
      String? idToken = await firebaseUser.getIdToken(); // token here
      // await ApiService.sendUserToBackend(idToken); // Node.js API call here
      return UserModel(
        uid: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? "",
        email: firebaseUser.email ?? '',
        role: role,
        createdAt: DateTime.now(),
      );
    }
    return null;
  }
}
