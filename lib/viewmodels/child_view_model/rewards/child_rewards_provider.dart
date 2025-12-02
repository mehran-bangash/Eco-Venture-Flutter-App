import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'child_rewards_state.dart';
import 'child_rewards_view_model.dart';

final childRewardsViewModelProvider =
    StateNotifierProvider<ChildRewardsViewModel, ChildRewardsState>((ref) {
      return ChildRewardsViewModel();
    });
