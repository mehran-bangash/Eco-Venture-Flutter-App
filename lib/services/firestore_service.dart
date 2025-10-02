import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreService {
 FirestoreService._();

 static final FirestoreService instance = FirestoreService._();

 final FirebaseFirestore _db = FirebaseFirestore.instance;

 Future<void> updateUserProfile({
  required String uid,
  String? name,
  String? dob,
  String? phone,
  String? imgUrl,
 }) async {
  final updateData = <String, dynamic>{};

  if (name != null) updateData["displayName"] = name;
  if (dob != null) updateData["dob"] = dob;
  if (phone != null) updateData["phone"] = phone;
  if (imgUrl != null) updateData["imgUrl"] = imgUrl;

  if (updateData.isNotEmpty) {
   await _db.collection("users").doc(uid).update(updateData);
  }
 }


 Future<Map<String, dynamic>?> getUserProfile(String uid) async {
  final doc = await _db.collection("users").doc(uid).get();
  return doc.data();
 }

 Future<void> deleteUserProfile(String uid) async {
  try {
   await _db.collection("users").doc(uid).delete();
  } catch (e) {
   throw Exception("Failed to delete user profile: $e");
  }
 }
}


















