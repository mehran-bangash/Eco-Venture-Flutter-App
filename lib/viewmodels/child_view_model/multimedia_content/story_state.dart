import '../../../models/story_model.dart';

class StoryState {
  final bool isLoading;
  final List<StoryModel>? stories;
  final String? error;
  StoryState({this.isLoading = false, this.stories, this.error});
  StoryState copyWith({
    bool? isLoading,
    List<StoryModel>? stories,
    String? error,
  }) => StoryState(
    isLoading: isLoading ?? this.isLoading,
    stories: stories ?? this.stories,
    error: error,
  );
}
