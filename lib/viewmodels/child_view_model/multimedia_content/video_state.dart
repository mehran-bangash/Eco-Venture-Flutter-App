import '../../../models/video_model.dart';

class VideoState {
  final bool isLoading;
  final List<VideoModel> videos; // <- non-nullable
  final String? error;

  VideoState({
    this.isLoading = false,
    this.videos = const [], // default to empty list
    this.error,
  });

  VideoState copyWith({
    bool? isLoading,
    List<VideoModel>? videos,
    String? error,
  }) {
    return VideoState(
      isLoading: isLoading ?? this.isLoading,
      videos: videos ?? this.videos,
      error: error ?? this.error,
    );
  }
}
