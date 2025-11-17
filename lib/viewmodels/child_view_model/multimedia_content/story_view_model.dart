import 'package:eco_venture/viewmodels/child_view_model/multimedia_content/story_state.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../../models/story_model.dart';
import '../../../repositories/video_StoryRepo.dart';

class StoryViewModel extends StateNotifier<StoryState> {
  final VideoStoryRepo _repo;

  StoryViewModel(this._repo) : super(StoryState());

  // Fetch public stories as List<StoryModel>
  Future<void> fetchStories() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final List<StoryModel> stories = await _repo.getPublicStories();
      state = state.copyWith(isLoading: false, stories: stories);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}