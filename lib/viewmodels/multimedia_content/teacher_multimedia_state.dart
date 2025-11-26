import '../../models/story_model.dart';
import '../../models/video_model.dart';


class TeacherMultimediaState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final List<VideoModel> videos;
  final List<StoryModel> stories;

  TeacherMultimediaState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.videos = const [],
    this.stories = const [],
  });

  TeacherMultimediaState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<VideoModel>? videos,
    List<StoryModel>? stories,
  }) {
    return TeacherMultimediaState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? false,
      errorMessage: errorMessage,
      videos: videos ?? this.videos,
      stories: stories ?? this.stories,
    );
  }
}