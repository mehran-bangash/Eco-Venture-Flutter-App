import 'package:eco_venture/services/firestore_service.dart';

class FirestoreRepo {
  FirestoreRepo._();
  static final FirestoreRepo instance = FirestoreRepo._();
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? dob,
    String? phone,
    String? imgUrl,
  }) async {
    try {
      await FirestoreService.instance.updateUserProfile(
        uid: uid,
        name: name,
        dob: dob,
        phone: phone,
        imgUrl: imgUrl,
      );
    } catch (e) {
      print("Error updating user profile: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      return await FirestoreService.instance.getUserProfile(uid);
    } catch (e) {
      print("Error fetching user profile: $e");
      rethrow;
    }
  }

  Future<void> deleteUserProfile(String uid) async {
    try {
      await FirestoreService.instance.deleteUserProfile(uid);
    } catch (e) {
      throw Exception("Failed to delete user profile: $e");
    }
  }
}

