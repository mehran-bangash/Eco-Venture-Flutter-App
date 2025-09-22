import 'package:eco_venture/viewmodels/child_view_model/multimedia_content/story_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/story_page_model.dart';

final storyProvider =
    StateNotifierProvider<StoryViewModel, List<StoryPageModel>>(
      (ref) => StoryViewModel(),
    );
