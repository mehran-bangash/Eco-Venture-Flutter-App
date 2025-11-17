import 'package:eco_venture/viewmodels/child_view_model/multimedia_content/video_state.dart';
import 'package:state_notifier/state_notifier.dart';

import '../../../models/video_model.dart';
import '../../../repositories/video_StoryRepo.dart';
class VideoViewModel extends StateNotifier<VideoState> {
  final VideoStoryRepo _repo;

  VideoViewModel(this._repo) : super(VideoState());

  /// Fetch public videos as List<VideoModel>
  Future<void> fetchVideos() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final List<VideoModel> videos = await _repo.getPublicVideos();
      state = state.copyWith(isLoading: false, videos: videos);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Increment view count
  Future<void> incrementView(String videoId) async {
    try {
      await _repo.incrementVideoView(videoId);
    } catch (e) {
      print("Error incrementing view: $e");
    }
  }
  // In your VideoViewModel class (video_view_model.dart)
  Future<void> toggleVideoLikeDislike({
    required String videoId,
    required String userId,
    required bool isLiking,
  }) async {

    final originalVideos = state.videos;

    final updatedVideos = state.videos.map((video) {
      if (video.id == videoId) {

        final updatedLikesMap = Map<String, bool>.from(video.userLikes ?? {});
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

        return video.copyWith(
          likes: likeCount,
          dislikes: dislikeCount,
          userLikes: updatedLikesMap,
        );
      }
      return video;
    }).toList();

    state = state.copyWith(videos: updatedVideos);

    try {
      await _repo.toggleVideoLikeDislike(
        videoId: videoId,
        userId: userId,
        isLiking: isLiking,
      );
    } catch (e) {
      print("DB Failed: $e");
      state = state.copyWith(videos: originalVideos);
    }
  }

}
