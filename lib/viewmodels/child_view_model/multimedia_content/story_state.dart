import '../../../models/story_model.dart';

class StoryState {
  final bool isLoading;
  final String? error;
  final List<StoryModel>? stories;

  StoryState({
    this.isLoading = false,
    this.error,
    this.stories,
  });

  StoryState copyWith({
    bool? isLoading,
    String? error,
    List<StoryModel>? stories,
  }) {
    return StoryState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      stories: stories ?? this.stories,
    );
  }
}
