import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreService {
 FirestoreService._();

 static final FirestoreService instance = FirestoreService._();

 final FirebaseFirestore _db = FirebaseFirestore.instance;

 Future<void> updateUserProfile({
  required String uid,
  required String name,
  required String dob,
  required String phone,
  required String imgUrl,
 }) async {
  await _db.collection("users").doc(uid).update({
   "displayName": name,
   "dob": dob,
   "phone": phone,
   "imgUrl": imgUrl,
  });
 }

 Future<Map<String, dynamic>?> getUserProfile(String uid) async {
  final doc = await _db.collection("users").doc(uid).get();
  return doc.data();
 }


}


















