import '../../../models/video_model.dart';

class VideoState {
  final bool isLoading;
  final List<VideoModel> videos;
  final String? error;
  VideoState({this.isLoading = false, this.videos = const [], this.error});

  VideoState copyWith({
    bool? isLoading,
    List<VideoModel>? videos,
    String? error,
  }) => VideoState(
    isLoading: isLoading ?? this.isLoading,
    videos: videos ?? this.videos,
    error: error,
  );
}
