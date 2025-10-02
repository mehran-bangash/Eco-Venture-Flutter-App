import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_venture/repositories/firestore_repo.dart';
import '../../../services/cloudinary_service.dart';
import '../../../services/shared_preferences_helper.dart';
import 'user_profile_state.dart';
import 'dart:io';
import 'package:state_notifier/state_notifier.dart';

class UserProfileViewModel extends StateNotifier<UserProfileState> {
  final FirestoreRepo _repo;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  UserProfileViewModel(this._repo) : super(UserProfileState.initial());

  // Fetch user profile from Firestore
  Future<void> fetchUserProfile(String uid) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _repo.getUserProfile(uid);
      state = state.copyWith(isLoading: false, userProfile: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Update profile (without image upload)
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? dob,
    String? phone,
    String? imgUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.updateUserProfile(
        uid: uid,
        name: name,
        dob: dob,
        phone: phone,
        imgUrl: imgUrl,
      );

      // Save locally only for non-null fields
      if (name != null) {
        await SharedPreferencesHelper.instance.saveUserName(name);
      }
      if (phone != null) {
        await SharedPreferencesHelper.instance.saveUserPhoneNumber(phone);
      }
      if (dob != null) {
        await SharedPreferencesHelper.instance.saveUserDOB(dob);   // <-- Missing line
      }
      if (imgUrl != null) {
        await SharedPreferencesHelper.instance.saveUserImgUrl(imgUrl);
      }


      // refresh after update
      await fetchUserProfile(uid);

      //  stop loading
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  Future<void> uploadAndSaveProfileImage({
    required String uid,
    required File imageFile,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final imageUrl = await _cloudinaryService.uploadImage(imageFile);

      if (imageUrl != null) {
        // Update Firestore + local storage
        await _repo.updateUserProfile(uid: uid, imgUrl: imageUrl);
        await SharedPreferencesHelper.instance.saveUserImgUrl(imageUrl);

        // Refresh state
        await fetchUserProfile(uid);

        //  stop loading here
        state = state.copyWith(isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: "Image upload failed");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Delete user account completely
  Future<void> deleteUserProfile(String uid) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _repo.getUserProfile(uid);

      // 1. Delete profile image from Cloudinary (if exists)
      final imgUrl = profile?["imgUrl"];
      if (imgUrl != null && imgUrl.isNotEmpty) {
        await _cloudinaryService.deleteImage(imgUrl);
      }

      // 2. Delete Firestore document
      await _repo.deleteUserProfile(uid);

      // 3. Clear local storage
      await SharedPreferencesHelper.instance.clearAll();

      // 4. Delete Firebase Auth user
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid == uid) {
        await user.delete();
      }

      // Reset state after delete
      state = UserProfileState.initial();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

}
