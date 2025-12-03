import 'dart:async';
import 'package:eco_venture/viewmodels/child_view_model/multimedia_content/video_state.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../../models/video_model.dart';
import '../../../repositories/video_StoryRepo.dart';



class VideoViewModel extends StateNotifier<VideoState> {
  final VideoStoryRepository _repo;
  StreamSubscription? _sub;

  VideoViewModel(this._repo) : super(VideoState());

  // Fetch Videos
  void fetchVideos() {
    state = state.copyWith(isLoading: true);
    _sub?.cancel();
    _sub = _repo.getVideos().listen(
          (data) => state = state.copyWith(isLoading: false, videos: data),
      onError: (e) => state = state.copyWith(isLoading: false, error: e.toString()),
    );
  }

  // Increment View
  Future<void> incrementView(VideoModel video) async {
    final newViews = video.views + 1;
    // Update DB
    await _repo.updateVideoInteraction(
        video.id, video.adminId, video.createdBy, {'views': newViews}
    );

    // Log History
    await _repo.logActivity(
        id: video.id,
        title: video.title,
        type: "Video",
        category: video.category
    );
  }

  // Like/Dislike
  Future<void> toggleVideoLikeDislike({required VideoModel video, required String userId, required bool isLiking}) async {
    final userLikes = Map<String, bool>.from(video.userLikes);

    if (userLikes[userId] == isLiking) {
      userLikes.remove(userId); // Toggle off
    } else {
      userLikes[userId] = isLiking;
    }

    int likes = userLikes.values.where((v) => v == true).length;
    int dislikes = userLikes.values.where((v) => v == false).length;

    // Update DB
    await _repo.updateVideoInteraction(
        video.id, video.adminId, video.createdBy,
        {'likes': likes, 'dislikes': dislikes, 'userLikes': userLikes}
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
