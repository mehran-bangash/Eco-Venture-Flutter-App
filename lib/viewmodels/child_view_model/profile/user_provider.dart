import 'package:eco_venture/viewmodels/child_view_model/profile/user_profile_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_venture/repositories/firestore_repo.dart';

import 'user_profile_state.dart';

final userProfileProvider =
StateNotifierProvider<UserProfileViewModel, UserProfileState>((ref) {
  return UserProfileViewModel(FirestoreRepo.instance);
});
