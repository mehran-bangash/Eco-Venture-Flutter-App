import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/story_model.dart';
import '../../models/video_model.dart';
import '../../repositories/teacher_multimedia_repository.dart';
import '../../services/cloudinary_service.dart';
import 'teacher_multimedia_state.dart';

class TeacherMultimediaViewModel extends StateNotifier<TeacherMultimediaState> {
  final TeacherMultimediaRepository _repository;
  final CloudinaryService _cloudinaryService;
  StreamSubscription? _videoSub;
  StreamSubscription? _storySub;

  TeacherMultimediaViewModel(this._repository, this._cloudinaryService) : super(TeacherMultimediaState());

  // --- VIDEOS ---
  void loadVideos() {
    _videoSub?.cancel();
    state = state.copyWith(isLoading: true);
    _videoSub = _repository.watchVideos().listen(
          (data) => state = state.copyWith(isLoading: false, videos: data),
      onError: (e) => state = state.copyWith(isLoading: false, errorMessage: e.toString()),
    );
  }

  Future<void> addVideo(VideoModel video) async {
    state = state.copyWith(isLoading: true);
    try {
      final processed = await _processVideoFiles(video);
      await _repository.addVideo(processed);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateVideo(VideoModel video) async {
    state = state.copyWith(isLoading: true);
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
      await _repository.deleteVideo(id);
    } catch (e) {
      state = state.copyWith(errorMessage: "Delete failed: $e");
    }
  }

  // Helper to upload Video & Thumbnail
  Future<VideoModel> _processVideoFiles(VideoModel video) async {
    String finalVideoUrl = video.videoUrl;
    String? finalThumbUrl = video.thumbnailUrl;

    // Upload Video File (if local path)
    if (video.videoUrl.isNotEmpty && !video.videoUrl.startsWith('http')) {
      final file = File(video.videoUrl);
      if(file.existsSync()) {
        final uploaded = await _cloudinaryService.uploadTeacherMultimediaFile(file, isVideo: true);
        if(uploaded != null) finalVideoUrl = uploaded;
      }
    }

    // Upload Thumbnail (if local path)
    if (video.thumbnailUrl != null && !video.thumbnailUrl!.startsWith('http')) {
      final file = File(video.thumbnailUrl!);
      if(file.existsSync()) {
        final uploaded = await _cloudinaryService.uploadTeacherMultimediaFile(file, isVideo: false); // image
        if(uploaded != null) finalThumbUrl = uploaded;
      }
    }

    return video.copyWith(videoUrl: finalVideoUrl, thumbnailUrl: finalThumbUrl);
  }


  // --- STORIES ---
  void loadStories() {
    _storySub?.cancel();
    state = state.copyWith(isLoading: true);
    _storySub = _repository.watchStories().listen(
          (data) => state = state.copyWith(isLoading: false, stories: data),
      onError: (e) => state = state.copyWith(isLoading: false, errorMessage: e.toString()),
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
      await _repository.deleteStory(id);
    } catch (e) {
      state = state.copyWith(errorMessage: "Delete failed: $e");
    }
  }

  // Helper to upload Cover & Pages
  Future<StoryModel> _processStoryFiles(StoryModel story) async {
    // FIX: Use 'thumbnailUrl' as defined in your StoryModel, not 'coverImageUrl'
    String? coverUrl = story.thumbnailUrl;

    // Upload Cover
    if (coverUrl != null && coverUrl.isNotEmpty && !coverUrl.startsWith('http')) {
      final file = File(coverUrl);
      if(file.existsSync()) {
        // FIX: Ensure uploadTeacherMultimediaFile exists in CloudinaryService or rename this call
        coverUrl = await _cloudinaryService.uploadTeacherMultimediaFile(file, isVideo: false);
      }
    }

    // Upload Pages
    // FIX: Use 'StoryPage' type instead of 'StoryPageModel'
    List<StoryPage> updatedPages = [];
    for (var page in story.pages) {
      String? pageImg = page.imageUrl;
      if (pageImg != null && pageImg.isNotEmpty && !pageImg.startsWith('http')) {
        final file = File(pageImg);
        if(file.existsSync()) {
          pageImg = await _cloudinaryService.uploadTeacherMultimediaFile(file, isVideo: false);
        }
      }
      // FIX: Use StoryPage constructor since copyWith might be missing on StoryPage
      updatedPages.add(StoryPage(text: page.text, imageUrl: pageImg ?? ''));
    }

    // FIX: Update copyWith to match StoryModel properties (thumbnailUrl)
    return story.copyWith(thumbnailUrl: coverUrl, pages: updatedPages);
  }

  void resetSuccess() => state = state.copyWith(isSuccess: false);

  @override
  void dispose() {
    _videoSub?.cancel();
    _storySub?.cancel();
    super.dispose();
  }
}