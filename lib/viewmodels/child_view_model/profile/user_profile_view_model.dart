import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_venture/repositories/firestore_repo.dart';
import 'user_profile_state.dart';
class UserProfileViewModel extends StateNotifier<UserProfileState> {
  final FirestoreRepo _repo;

  UserProfileViewModel(this._repo) : super(UserProfileState.initial());


  Future<void> fetchUserProfile(String uid) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _repo.getUserProfile(uid);
      state = state.copyWith(isLoading: false, userProfile: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Update profile
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String dob,
    required String phone,
    required String imgUrl,
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
      // refresh after update
      await fetchUserProfile(uid);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
