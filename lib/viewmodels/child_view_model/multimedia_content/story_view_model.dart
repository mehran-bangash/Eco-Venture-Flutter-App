import 'dart:async';
import 'package:eco_venture/viewmodels/child_view_model/multimedia_content/story_state.dart';
import 'package:state_notifier/state_notifier.dart';

import '../../../models/story_model.dart';
import '../../../repositories/video_StoryRepo.dart';

class StoryViewModel extends StateNotifier<StoryState> {
  final VideoStoryRepository _repo;
  StreamSubscription? _sub;

  StoryViewModel(this._repo) : super(StoryState());

  void fetchStories() {
    state = state.copyWith(isLoading: true);
    _sub?.cancel();
    _sub = _repo.getStories().listen(
      (data) => state = state.copyWith(isLoading: false, stories: data),
      onError: (e) =>
          state = state.copyWith(isLoading: false, error: e.toString()),
    );
  }

  Future<void> incrementView(StoryModel story) async {
    final newViews = story.views + 1;
    await _repo.updateStoryInteraction(
      story.id,
      story.adminId,
      story.createdBy,
      {'views': newViews},
    );

    // 2. Log to User History (Fixed Call)
    await _repo.logActivity(
      id: story.id,
      title: story.title,
      type: "Story",
      category:
          "Reading", // Stories usually don't have categories in model, defaulting to 'Reading'
    );
  }

  Future<void> toggleLikeDislike({
    required StoryModel story,
    required String userId,
    required bool isLiking,
  }) async {
    final userLikes = Map<String, bool>.from(story.userLikes);

    if (userLikes[userId] == isLiking) {
      userLikes.remove(userId);
    } else {
      userLikes[userId] = isLiking;
    }

    int likes = userLikes.values.where((v) => v == true).length;
    int dislikes = userLikes.values.where((v) => v == false).length;

    await _repo.updateStoryInteraction(
      story.id,
      story.adminId,
      story.createdBy,
      {'likes': likes, 'dislikes': dislikes, 'userLikes': userLikes},
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
