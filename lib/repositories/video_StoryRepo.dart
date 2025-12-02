import '../models/video_model.dart';
import '../models/story_model.dart';
import '../services/video_story_service.dart';

class VideoStoryRepository {
  final VideoStoryService _service;

  VideoStoryRepository(this._service);

  Stream<List<VideoModel>> getVideos() => _service.getVideosStream();
  Stream<List<StoryModel>> getStories() => _service.getStoriesStream();

  Future<void> updateVideoInteraction(String videoId, String creatorId, String createdBy, Map<String, dynamic> updates) async {
    await _service.updateVideoInteraction(videoId, creatorId, createdBy, updates);
  }

  Future<void> updateStoryInteraction(String storyId, String creatorId, String createdBy, Map<String, dynamic> updates) async {
    await _service.updateStoryInteraction(storyId, creatorId, createdBy, updates);
  }
}