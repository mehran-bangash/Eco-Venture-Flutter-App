import 'package:go_router/go_router.dart';
import '../../navigation/bottom_nav_child.dart';
import '../../views/child_section/InteractiveQuiz/interactive_quiz_screen.dart';
import '../../views/child_section/child_home_screen.dart';
import '../../views/child_section/multimedia/child_multimedia_screen.dart';
import '../../views/child_section/multimedia/story_screen.dart';
import '../../views/child_section/multimedia/video_screen.dart';
import '../../views/child_section/naturePhotoJournal/nature_photo_journal_screen.dart';
import '../../views/child_section/stemChallenges/stem_challenges_screen.dart';
import '../../views/child_section/treasureHunt/treasure_hunt_screen.dart';
import '../constants/route_names.dart';
class ChildRouter {
  static final routes = GoRoute(
    path: RouteNames.bottomNavChild, // "/child"
    name: 'bottomNavChild',
    builder: (context, state) => const BottomNavChild(), // wrap with your nav container
    routes: [
      GoRoute(
        path: 'home', //  relative path, not /child/home
        name: 'childHome',
        builder: (context, state) => const ChildHomeScreen(),
        routes: [
          GoRoute(
            path: 'treasure-hunt',
            name: 'treasureHunt',
            builder: (context, state) => const TreasureHuntScreen(),
          ),
          GoRoute(
            path: 'multimedia-content',
            name: 'multiMediaContent',
            builder: (context, state) => const ChildMultimediaScreen(),
            routes: [
              GoRoute(
                path: 'video-screen',
                name: 'videoScreen',
                builder: (context, state) => const VideoScreen(),
              ),
              GoRoute(
                path: 'story-screen',
                name: 'storyScreen',
                builder: (context, state) => const StoryScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'stem-challenges',
            name: 'stemChallenges',
            builder: (context, state) => const StemChallengesScreen(),
          ),
          GoRoute(
            path: 'nature-photo-journal',
            name: 'naturePhotoJournal',
            builder: (context, state) => const NaturePhotoJournalScreen(),
          ),
          GoRoute(
            path: 'interactive-quiz',
            name: 'interactiveQuiz',
            builder: (context, state) => const InteractiveQuizScreen(),
          ),
        ],
      ),
    ],
  );
}
