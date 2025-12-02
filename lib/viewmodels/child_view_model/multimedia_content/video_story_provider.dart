
import 'package:eco_venture/viewmodels/child_view_model/multimedia_content/story_state.dart';
import 'package:eco_venture/viewmodels/child_view_model/multimedia_content/story_view_model.dart';
import 'package:eco_venture/viewmodels/child_view_model/multimedia_content/video_state.dart';
import 'package:eco_venture/viewmodels/child_view_model/multimedia_content/video_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/video_StoryRepo.dart';
import '../../../services/video_story_service.dart';
final videoStoryServiceProvider = Provider((ref) => VideoStoryService());

final videoStoryRepositoryProvider = Provider((ref) => VideoStoryRepository(ref.watch(videoStoryServiceProvider)));

final videoViewModelProvider = StateNotifierProvider<VideoViewModel, VideoState>((ref) {
  return VideoViewModel(ref.watch(videoStoryRepositoryProvider));
});

final storyViewModelProvider = StateNotifierProvider<StoryViewModel, StoryState>((ref) {
  return StoryViewModel(ref.watch(videoStoryRepositoryProvider));
});