import 'package:eco_venture/models/story_model.dart';
import 'package:eco_venture/models/video_model.dart';

import '../services/Database_video_story.dart';

class VideoStoryRepo {
  final DatabaseVideoStory _databaseService;

  VideoStoryRepo(this._databaseService);

  /// Fetch public videos
  Future<List<VideoModel>> getPublicVideos() {
    return _databaseService.fetchPublicVideos();
  }

  /// Fetch public stories
  Future<List<StoryModel>> getPublicStories() {
    return _databaseService.fetchPublicStories();
  }

  /// Increment video views
  Future<void> incrementVideoView(String videoId) {
    return _databaseService.incrementVideoView(videoId);
  }

  /// Toggle like/dislike
  Future<void> toggleVideoLikeDislike({
    required String videoId,
    required String userId,
    required bool isLiking,
  }) {
    return _databaseService.toggleVideoLikeDislike(
      videoId: videoId,
      userId: userId,
      isLiking: isLiking,
    );
  }
}
