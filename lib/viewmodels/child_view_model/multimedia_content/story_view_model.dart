import 'package:eco_venture/viewmodels/child_view_model/multimedia_content/story_state.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../../models/story_model.dart';
import '../../../repositories/video_StoryRepo.dart';

import '../../../services/shared_preferences_helper.dart'; // <-- Adjust path as needed

class StoryViewModel extends StateNotifier<StoryState> {
  final VideoStoryRepo _repo;

  StoryViewModel(this._repo) : super(StoryState());

  // Fetch public stories as List<StoryModel>
  Future<void> fetchStories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final List<StoryModel> stories = await _repo.getPublicStories();
      state = state.copyWith(isLoading: false, stories: stories);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // --- NEW FUNCTIONS ADDED ---

  /// Increment story view count
  Future<void> incrementView(String storyId) async {
    try {
      // Calls the new repo function
      await _repo.incrementStoryView(storyId);
    } catch (e) {
      print("Error incrementing story view: $e");
    }
  }

  /// Toggle story like/dislike
  Future<void> toggleLikeDislike({
    required String storyId,
    required bool isLiking,
  }) async {

    // 1. Get the userId from SharedPreferences for the optimistic update
    final String? userId = await SharedPreferencesHelper.instance.getUserId();

    if (userId == null || userId.isEmpty) {
      print("ViewModel: Cannot toggle like, user ID is null or empty.");
      return; // Stop
    }

    final originalStories = state.stories;

    // 2. Perform the Optimistic Update on the local state
    final updatedStories = state.stories?.map((story) {
      if (story.id == storyId) {

        final updatedLikesMap = Map<String, bool>.from(story.userLikes);
        final bool? currentVote = updatedLikesMap[userId];

        if (isLiking) {
          if (currentVote == true) {
            updatedLikesMap.remove(userId);
          } else {
            updatedLikesMap[userId] = true;
          }
        } else {
          if (currentVote == false) {
            updatedLikesMap.remove(userId);
          } else {
            updatedLikesMap[userId] = false;
          }
        }

        final likeCount = updatedLikesMap.values.where((v) => v == true).length;
        final dislikeCount = updatedLikesMap.values.where((v) => v == false).length;

        // Use the copyWith method we added to StoryModel
        return story.copyWith(
          likes: likeCount,
          dislikes: dislikeCount,
          userLikes: updatedLikesMap,
        );
      }
      return story;
    }).toList();

    // 3. Update the UI state
    state = state.copyWith(stories: updatedStories);

    // 4. Call the repository
    try {
      await _repo.toggleStoryLikeDislike(
        storyId: storyId,
        isLiking: isLiking,
      );
    } catch (e) {
      print("DB Failed: $e");
      // Roll back the UI on failure
      state = state.copyWith(stories: originalStories);
    }
  }
}