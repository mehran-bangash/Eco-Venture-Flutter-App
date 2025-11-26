import '../models/video_model.dart';
import '../models/story_model.dart';
import '../services/firebase_teacher_database.dart';

class TeacherMultimediaRepository {
  final FirebaseTeacherDatabase _db;

  TeacherMultimediaRepository(this._db);

  // --- VIDEOS ---
  Future<void> addVideo(VideoModel video) async => await _db.addVideo(video);
  Future<void> updateVideo(VideoModel video) async => await _db.updateVideo(video);
  Future<void> deleteVideo(String id) async => await _db.deleteVideo(id);
  Stream<List<VideoModel>> watchVideos() => _db.getTeacherVideosStream();

  // --- STORIES ---
  Future<void> addStory(StoryModel story) async => await _db.addStory(story);
  Future<void> updateStory(StoryModel story) async => await _db.updateStory(story);
  Future<void> deleteStory(String id) async => await _db.deleteStory(id);
  Stream<List<StoryModel>> watchStories() => _db.getTeacherStoriesStream();
}