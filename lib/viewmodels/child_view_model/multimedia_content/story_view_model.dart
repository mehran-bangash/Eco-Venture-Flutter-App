import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/story_page_model.dart';


class StoryViewModel extends StateNotifier<List<StoryPageModel>> {
  StoryViewModel() : super(_hardcodedStory);

  static final List<StoryPageModel> _hardcodedStory = [
    StoryPageModel(
      imageUrl:
      "https://lh3.googleusercontent.com/aida-public/AB6AXuC3cIUzUl2kAwEK2-z3SBAtMNlSqSLEAn-zjl6JRyn9Ei6Fm_TjwWHwMcSMQ_fiRqQxlSwaGN2e55kgELw65oPB2AT-ejBUXDhM2BvB-qJVS5e9ckqw8hZHZmoNJ9nngNccfOBDKI9M5uDP_g1JnsDTNt5D-AhrC3Xfzuf_-T0_BiV2wUs4s0quCB5RrMGBggFrR4rzcMb_Ug_m_bvuWzgxNWe7Ib3mtAcy0I8Bgd40msti4YHWfBC51psTerw66DTIHEOQRMKEaPAO",
      text:
      "Once upon a time, in a lush green forest, there stood a magical treehouse. It was home to two adventurous siblings, Lily and Tom...",
    ),
    StoryPageModel(
      imageUrl:
      "https://img.freepik.com/free-vector/fantasy-magic-forest-landscape_107791-28277.jpg",
      text:
      "As they walked further, the trees whispered secrets of the forest, and glowing fireflies lit up their way...",
    ),
  ];

  // Later you’ll replace this with Firestore fetch
  void loadFromFirestore(List<StoryPageModel> pages) {
    state = pages;
  }
}