import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/story_model.dart';
import '../../models/video_model.dart';
import '../../repositories/teacher/teacher_multimedia_repository.dart';
import '../../services/cloudinary_service.dart';
import 'teacher_multimedia_state.dart';

class TeacherMultimediaViewModel extends StateNotifier<TeacherMultimediaState> {
  final TeacherMultimediaRepository _repository;
  final CloudinaryService _cloudinaryService;
  StreamSubscription? _videoSub;
  StreamSubscription? _storySub;

  TeacherMultimediaViewModel(this._repository, this._cloudinaryService)
    : super(TeacherMultimediaState());

  // --- VIDEOS ---
  void loadVideos() {
    _videoSub?.cancel();
    state = state.copyWith(isLoading: true);
    _videoSub = _repository.watchVideos().listen(
      (data) => state = state.copyWith(isLoading: false, videos: data),
      onError: (e) =>
          state = state.copyWith(isLoading: false, errorMessage: e.toString()),
    );
  }

  Future<void> addVideo(VideoModel video) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final processed = await _processVideoFiles(video);
      await _repository.addVideo(processed);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateVideo(VideoModel video) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final processed = await _processVideoFiles(video);
      await _repository.updateVideo(processed);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteVideo(String id) async {
    try {
      final video = state.videos.firstWhere((v) => v.id == id);
      await _cloudinaryService.deleteFile(video.videoUrl, isVideo: true);
      if (video.thumbnailUrl != null)
        await _cloudinaryService.deleteFile(video.thumbnailUrl, isVideo: false);
      await _repository.deleteVideo(id);
    } catch (e) {
      state = state.copyWith(errorMessage: "Delete failed: $e");
    }
  }

  Future<VideoModel> _processVideoFiles(VideoModel video) async {
    String vUrl = video.videoUrl;
    String? tUrl = video.thumbnailUrl;
    String dur = video.duration;

    if (vUrl.isNotEmpty && !vUrl.startsWith('http')) {
      final res = await _cloudinaryService.uploadTeacherMultimediaFile(
        File(vUrl),
        isVideo: true,
      );
      if (res is Map) {
        vUrl = res['url'];
        dur = res['duration'];
      }
    }
    if (tUrl != null && !tUrl.startsWith('http')) {
      final res = await _cloudinaryService.uploadTeacherMultimediaFile(
        File(tUrl),
        isVideo: false,
      );
      if (res is String) tUrl = res;
    }
    return video.copyWith(videoUrl: vUrl, thumbnailUrl: tUrl, duration: dur);
  }

  // --- STORIES ---
  void loadStories() {
    _storySub?.cancel();
    state = state.copyWith(isLoading: true);
    _storySub = _repository.watchStories().listen(
      (data) => state = state.copyWith(isLoading: false, stories: data),
      onError: (e) =>
          state = state.copyWith(isLoading: false, errorMessage: e.toString()),
    );
  }

  Future<void> addStory(StoryModel story) async {
    state = state.copyWith(isLoading: true);
    try {
      final processed = await _processStoryFiles(story);
      await _repository.addStory(processed);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Restored updateStory to fix undefined_method error in Story Edit screen
  Future<void> updateStory(StoryModel story) async {
    state = state.copyWith(isLoading: true);
    try {
      final processed = await _processStoryFiles(story);
      await _repository.updateStory(processed);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteStory(String id) async {
    try {
      final story = state.stories.firstWhere((s) => s.id == id);

      // 1. Delete Thumbnail from Cloudinary
      if (story.thumbnailUrl != null && story.thumbnailUrl!.isNotEmpty) {
        await _cloudinaryService.deleteFile(
          story.thumbnailUrl!,
          isVideo: false,
        );
      }

      // 2. Loop and Delete all Page Images from Cloudinary
      for (var page in story.pages) {
        if (page.imageUrl.isNotEmpty) {
          await _cloudinaryService.deleteFile(page.imageUrl, isVideo: false);
        }
      }

      // 3. Delete from Firebase
      await _repository.deleteStory(id);
    } catch (e) {
      state = state.copyWith(errorMessage: "Delete failed: $e");
    }
  }

  Future<StoryModel> _processStoryFiles(StoryModel story) async {
    String? cUrl = story.thumbnailUrl;
    if (cUrl != null && !cUrl.startsWith('http')) {
      final res = await _cloudinaryService.uploadTeacherMultimediaFile(
        File(cUrl),
        isVideo: false,
      );
      if (res is String) cUrl = res;
    }
    List<StoryPage> pages = [];
    for (var p in story.pages) {
      String img = p.imageUrl;
      if (img.isNotEmpty && !img.startsWith('http')) {
        final res = await _cloudinaryService.uploadTeacherMultimediaFile(
          File(img),
          isVideo: false,
        );
        if (res is String) img = res;
      }
      pages.add(StoryPage(text: p.text, imageUrl: img));
    }
    return story.copyWith(thumbnailUrl: cUrl, pages: pages);
  }

  void resetSuccess() => state = state.copyWith(isSuccess: false);

  @override
  void dispose() {
    _videoSub?.cancel();
    _storySub?.cancel();
    super.dispose();
  }
}
