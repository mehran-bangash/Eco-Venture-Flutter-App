
import 'package:eco_venture/viewmodels/child_view_model/multimedia_content/story_state.dart';
import 'package:eco_venture/viewmodels/child_view_model/multimedia_content/story_view_model.dart';
import 'package:eco_venture/viewmodels/child_view_model/multimedia_content/video_state.dart';
import 'package:eco_venture/viewmodels/child_view_model/multimedia_content/video_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/video_StoryRepo.dart';
import '../../../services/Database_video_story.dart';

final videoViewModelProvider =
StateNotifierProvider<VideoViewModel, VideoState>(
      (ref) => VideoViewModel(ref.watch(videoStoryRepoProvider)),
);

final storyViewModelProvider =
StateNotifierProvider<StoryViewModel, StoryState>(
      (ref) => StoryViewModel(ref.watch(videoStoryRepoProvider)),
);

final videoStoryRepoProvider = Provider.autoDispose<VideoStoryRepo>((ref) {
  return VideoStoryRepo(DatabaseVideoStory());
});
