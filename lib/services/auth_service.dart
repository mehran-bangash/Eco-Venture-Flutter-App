import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();
  static final AuthService authInstance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      throw Exception(e.message);
    } catch (e) {
      // Handle any other errors
      throw Exception("Something went wrong: $e");
    }
  }
}
