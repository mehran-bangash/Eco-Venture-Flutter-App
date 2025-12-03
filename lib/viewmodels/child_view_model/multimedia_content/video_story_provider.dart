
import 'package:eco_venture/viewmodels/child_view_model/multimedia_content/story_state.dart';
import 'package:eco_venture/viewmodels/child_view_model/multimedia_content/story_view_model.dart';
import 'package:eco_venture/viewmodels/child_view_model/multimedia_content/video_state.dart';
import 'package:eco_venture/viewmodels/child_view_model/multimedia_content/video_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/video_StoryRepo.dart';
import '../../../services/video_story_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// Import the separate ViewModel files
import 'video_view_model.dart';
import 'story_view_model.dart';

// 1. Services
final videoStoryServiceProvider = Provider((ref) => VideoStoryService());

// 2. Repository
final videoStoryRepositoryProvider = Provider((ref) {
  return VideoStoryRepository(ref.watch(videoStoryServiceProvider));
});

// 3. Video ViewModel Provider
final videoViewModelProvider = StateNotifierProvider<VideoViewModel, VideoState>((ref) {
  return VideoViewModel(ref.watch(videoStoryRepositoryProvider));
});

// 4. Story ViewModel Provider
final storyViewModelProvider = StateNotifierProvider<StoryViewModel, StoryState>((ref) {
  return StoryViewModel(ref.watch(videoStoryRepositoryProvider));
});