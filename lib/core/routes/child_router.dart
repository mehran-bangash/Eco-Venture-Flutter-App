
import 'package:eco_venture/views/child_section/InteractiveQuiz/quiz_completion_screen.dart';
import 'package:eco_venture/views/child_section/InteractiveQuiz/quiz_question_screen.dart';
import 'package:eco_venture/views/child_section/multimedia/story_play_screen.dart';
import 'package:eco_venture/views/child_section/multimedia/video_play_screen.dart';
import 'package:eco_venture/views/child_section/naturePhotoJournal/add_entry_screen.dart';
import 'package:eco_venture/views/child_section/naturePhotoJournal/nature_description_screen.dart';
import 'package:eco_venture/views/child_section/naturePhotoJournal/nature_photo_chatbot_screen.dart';
import 'package:eco_venture/views/child_section/settings/child_settings.dart';
import 'package:eco_venture/views/child_section/settings/profile/child_profile_screen.dart';
import 'package:eco_venture/views/child_section/settings/profile/edit_profile_screen.dart';
import 'package:eco_venture/views/child_section/stemChallenges/engineering_instruction_screen.dart';
import 'package:eco_venture/views/child_section/stemChallenges/engineering_screen.dart';
import 'package:eco_venture/views/child_section/stemChallenges/engineering_submit_screen.dart';
import 'package:eco_venture/views/child_section/stemChallenges/math_instruction_screen.dart';
import 'package:eco_venture/views/child_section/stemChallenges/math_screen.dart';
import 'package:eco_venture/views/child_section/stemChallenges/math_submit_screen.dart';
import 'package:eco_venture/views/child_section/stemChallenges/science_instruction_screen.dart';
import 'package:eco_venture/views/child_section/stemChallenges/science_screen.dart';
import 'package:eco_venture/views/child_section/stemChallenges/science_submit_screen.dart';
import 'package:eco_venture/views/child_section/stemChallenges/technology_instruction_screen.dart';
import 'package:eco_venture/views/child_section/stemChallenges/technology_screen.dart';
import 'package:eco_venture/views/child_section/stemChallenges/technology_submit_screen.dart';
import 'package:eco_venture/views/child_section/treasureHunt/clue_locked_screen.dart';
import 'package:eco_venture/views/child_section/treasureHunt/qR_scanner_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/bottom_nav_child.dart';
import '../../views/child_section/InteractiveQuiz/interactive_quiz_screen.dart';
import '../../views/child_section/child_home_screen.dart';
import '../../views/child_section/multimedia/child_multimedia_screen.dart';
import '../../views/child_section/multimedia/story_screen.dart';
import '../../views/child_section/multimedia/video_screen.dart';
import '../../views/child_section/naturePhotoJournal/nature_photo_journal_screen.dart';
import '../../views/child_section/stemChallenges/stem_challenges_screen.dart';
import '../../views/child_section/treasureHunt/qr_success_screen.dart';
import '../../views/child_section/treasureHunt/treasure_hunt_screen.dart';
import '../constants/route_names.dart';

class ChildRouter {
  static final routes = GoRoute(
    path: RouteNames.bottomNavChild, // "/child"
    name: 'bottomNavChild',
    builder: (context, state) =>
        const BottomNavChild(), // wrap with your nav container
    routes: [
      GoRoute(
        path: 'child-profile',
        name: 'childProfile',
        builder: (context, state) => const ChildProfile(),
        routes: [
          GoRoute(
            path: 'edit-profile',
            name: 'editProfile',
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: 'child-settings',
        name: 'childSettings',
        builder: (context, state) => const ChildSettings(),
      ),
      GoRoute(
        path: 'home', //  relative path, not /child/home
        name: 'childHome',
        builder: (context, state) => const ChildHomeScreen(),
        routes: [
          GoRoute(
            path: 'treasure-hunt',
            name: 'treasureHunt',
            builder: (context, state) => const TreasureHuntScreen(),
            routes: [
              GoRoute(
                path: 'clue-locked-screen',
                name: 'clueLockedScreen',
                builder: (context, state) => const ClueLockedScreen(),
                routes: [
                  GoRoute(
                    path: 'qr-scanner-screen',
                    name: 'qrScannerScreen',
                    builder: (context, state) => const QRScannerScreen(),
                    routes: [
                      GoRoute(
                        path: 'qr-success-screen',
                        name: 'qrSuccessScreen',

                        builder: (context, state) {
                          final rewardCoins = state.extra as int? ?? 0;
                          return QRSuccessScreen(rewardCoins: rewardCoins);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
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
                routes: [
                  GoRoute(
                    path: 'video-play-screen',
                    name: 'videoPlayScreen',
                    builder: (context, state) => const VideoPlayerScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: 'story-screen',
                name: 'storyScreen',
                builder: (context, state) => const StoryScreen(),
                routes: [
                  GoRoute(
                    path: 'story-play-screen',
                    name: 'storyPlayScreen',
                    builder: (context, state) => const StoryPlayScreen(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'stem-challenges',
            name: 'stemChallenges',
            builder: (context, state) => const StemChallengesScreen(),
            routes: [
              GoRoute(
                path: 'science-screen',
                name: 'scienceScreen',
                builder: (context, state) => const ScienceScreen(),
                routes: [
                  GoRoute(
                    path: 'science-instruction-screen',
                    name: 'scienceInstructionScreen',
                    builder: (context, state) =>
                        const ScienceInstructionScreen(),
                  ),
                  GoRoute(
                    path: 'science-submit-screen',
                    name: 'scienceSubmitScreen',
                    builder: (context, state) => const ScienceSubmitScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: 'math-screen',
                name: 'mathScreen',
                builder: (context, state) => const MathScreen(),
                routes: [
                  GoRoute(
                    path: 'math-instruction-screen',
                    name: 'mathInstructionScreen',
                    builder: (context, state) => const MathInstructionScreen(),
                  ),
                  GoRoute(
                    path: 'math-submit-screen',
                    name: 'mathSubmitScreen',
                    builder: (context, state) => const MathSubmitScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: 'engineering-screen',
                name: 'engineeringScreen',
                builder: (context, state) => const EngineeringScreen(),
                routes: [
                  GoRoute(
                    path: 'engineering-instruction-screen',
                    name: 'engineeringInstructionScreen',
                    builder: (context, state) =>
                        const EngineeringInstructionScreen(),
                  ),
                  GoRoute(
                    path: 'engineering-submit-screen',
                    name: 'engineeringSubmitScreen',
                    builder: (context, state) =>
                        const EngineeringSubmitScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: 'technology-screen',
                name: 'technologyScreen',
                builder: (context, state) => const TechnologyScreen(),
                routes: [
                  GoRoute(
                    path: 'technology-instruction-screen',
                    name: 'technologyInstructionScreen',
                    builder: (context, state) =>
                        const TechnologyInstructionScreen(),
                  ),
                  GoRoute(
                    path: 'technology-submit-screen',
                    name: 'technologySubmitScreen',
                    builder: (context, state) => const TechnologySubmitScreen(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'nature-photo-journal',
            name: 'naturePhotoJournal',
            builder: (context, state) => const NaturePhotoJournalScreen(),
            routes: [
              GoRoute(
                path: 'nature-description-screen',
                name: "natureDescriptionScreen",
                builder: (context, state) => const NatureDescriptionScreen(),
              ),
              GoRoute(
                path: 'add-entry-screen',
                name: "addEntryScreen",
                builder: (context, state) => const AddEntryScreen(),
                routes: [
                  GoRoute(
                    path: 'nature-photo-chatbot-screen',
                    name: 'naturePhotoChatbotScreen',
                    builder: (context, state) => NaturePhotoChatbotScreen(),
                  ),
                ],
              ),
            ],
          ),

          GoRoute(
            path: 'interactive-quiz',
            name: 'interactiveQuiz',
            builder: (context, state) => const InteractiveQuizScreen(),
            routes: [
              GoRoute(
                path: 'quiz-question-screen',
                name: 'quizQuestionScreen',
                builder: (context, state) => const QuizQuestionScreen(),
                routes: [
                  GoRoute(
                    path: 'quiz-completion-screen/:correct/:total', // ✅ MUST have placeholders
                    name: 'quizCompletionScreen',
                    pageBuilder: (context, state) {
                      final correct = int.parse(state.pathParameters['correct']!);
                      final total = int.parse(state.pathParameters['total']!);
                      return CustomTransitionPage(
                        transitionDuration: const Duration(milliseconds: 500),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0, 1);
                          const end = Offset.zero;
                          var curve = Curves.easeOutCubic;
                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: FadeTransition(opacity: animation, child: child),
                          );
                        },
                        child: QuizCompletionScreen(
                          correctAnswers: correct,
                          totalQuestions: total,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

        ],
      ),
    ],
  );
}
