
import 'package:eco_venture/models/quiz_topic_model.dart';
import 'package:eco_venture/models/stem_challenge_read_model.dart';
import 'package:eco_venture/views/child_section/InteractiveQuiz/child_quiz_topic_detail_screen.dart';
import 'package:eco_venture/views/child_section/InteractiveQuiz/quiz_completion_screen.dart';
import 'package:eco_venture/views/child_section/InteractiveQuiz/quiz_question_screen.dart';
import 'package:eco_venture/views/child_section/multimedia/story_play_screen.dart';
import 'package:eco_venture/views/child_section/multimedia/video_play_screen.dart';
import 'package:eco_venture/views/child_section/naturePhotoJournal/learn_with_ai.dart';
import 'package:eco_venture/views/child_section/naturePhotoJournal/nature_description_screen.dart';
import 'package:eco_venture/views/child_section/naturePhotoJournal/nature_photo_explore_screen.dart';
import 'package:eco_venture/views/child_section/progress_dashboard_screen.dart';
import 'package:eco_venture/views/child_section/report_issue_screen.dart';
import 'package:eco_venture/views/child_section/report_safety_screen.dart';
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
import '../../models/child_progress_model.dart';
import '../../models/story_model.dart';
import '../../models/video_model.dart';
import '../../navigation/bottom_nav_child.dart';
import '../../views/child_section/InteractiveQuiz/interactive_quiz_screen.dart';
import '../../views/child_section/child_home_screen.dart';
import '../../views/child_section/multimedia/child_multimedia_screen.dart';
import '../../views/child_section/multimedia/story_screen.dart';
import '../../views/child_section/multimedia/video_screen.dart';
import '../../views/child_section/naturePhotoJournal/nature_photo_journal_screen.dart';
import '../../views/child_section/rewards_screen.dart';
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
           path: 'progress-dashboard-screen',
           name: 'progressDashboardScreen',
           builder: (context, state) => const ProgressDashboardScreen(),

       ),
       GoRoute(
         path: 'rewards-screen',
         name: 'RewardsScreen',
         builder: (context, state) => RewardsScreen(),

       ),
       GoRoute(
           path: 'report-safety-screen',
           name: "reportSafetyScreen",
          builder: (context, state) => const ReportSafetyScreen(),
         routes: [
           GoRoute(
               path: 'report-issue-screen',
               name: "reportIssueScreen",
               builder: (context, state) => const ReportIssueScreen(),
           )
         ]

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
                    builder: (context, state) {
                      final video = state.extra as VideoModel;

                      return VideoPlayerScreen(
                        videoId: video.id,         // required now
                        videoUrl: video.videoUrl,
                        title: video.title,
                        duration: video.duration,
                        views: video.views,
                      );
                    },
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
                    builder: (context, state) {
                      // Extract the StoryModel from the 'extra' parameter
                      final story = state.extra as StoryModel;

                      // Pass the story to the screen
                      return StoryPlayScreen(story: story);
                    },
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
                    builder: (context, state) {
                      final scienceChallenge= state.extra as StemChallengeReadModel;
                       return ScienceInstructionScreen(challenge: scienceChallenge,);
                    }
                  ),
                  GoRoute(
                    path: 'science-submit-screen',
                    name: 'scienceSubmitScreen',
                    builder: (context, state) {
                      final scienceChallenge= state.extra as StemChallengeReadModel;
                      return ScienceSubmitScreen(challenge: scienceChallenge,);
                    },
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
                    builder: (context, state) {
                      final mathChallenge= state.extra as StemChallengeReadModel;
                      return   MathInstructionScreen(challenge: mathChallenge,);
                    },
                  ),
                  GoRoute(
                    path: 'math-submit-screen',
                    name: 'mathSubmitScreen',
                    builder: (context, state) {
                      final mathChallenge= state.extra as StemChallengeReadModel;
                      return MathSubmitScreen(challenge:mathChallenge);
                    },
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
                    builder: (context, state) {
                      final engineeringChallenge= state.extra as StemChallengeReadModel;
                      return  EngineeringInstructionScreen(challenge:engineeringChallenge);
                    }
                        ,
                  ),
                  GoRoute(
                    path: 'engineering-submit-screen',
                    name: 'engineeringSubmitScreen',
                    builder: (context, state) {
                      final engineeringChallenge= state.extra as StemChallengeReadModel;
                      return  EngineeringSubmitScreen(challenge:engineeringChallenge);
                    }
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
                    builder: (context, state) {
                      final technologyScreenChallenge= state.extra as StemChallengeReadModel;
                      return TechnologyInstructionScreen(challenge:technologyScreenChallenge);
                    }
                        ,
                  ),
                  GoRoute(
                    path: 'technology-submit-screen',
                    name: 'technologySubmitScreen',
                    builder: (context, state) {
                      final technologyScreenChallenge= state.extra as StemChallengeReadModel;
                      return TechnologySubmitScreen(challenge:technologyScreenChallenge);
                    },
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
                path: 'learn-with-Ai-screen',
                name: "learnWithAiScreen",
                builder: (context, state) => const LearnWithAi(),
                routes: [
                  GoRoute(
                    path: 'nature-photo-explore-screen',
                    name: 'naturePhotoExploreScreen',
                    builder: (context, state) => NaturePhotoExplorerScreen(),
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
                path: RouteNames.childQuizTopicDetailScreen,
                name: 'childQuizTopicDetailScreen',
                builder: (context, state) {
                  final quizModel = state.extra as QuizTopicModel;
                  return ChildQuizTopicDetailScreen(topic: quizModel);
                },

              ),
              GoRoute(
                path: 'quiz-question-screen',
                name: 'quizQuestionScreen',
                builder: (context, state) {
                  final questionArgs = state.extra as QuizQuestionArgs;
                  return QuizQuestionScreen(args:questionArgs ,);
                },

              ),
            ],
          ),
          GoRoute(
            path: 'quiz-completion-screen/:correct/:total',
            name: 'quizCompletionScreen',
            pageBuilder: (context, state) {

              // ✔ Correct: receive values as STRINGS (do not parse here)
              final correct = state.pathParameters['correct']!;
              final total = state.pathParameters['total']!;

              // ✔ Correct: progress passed through extra
              final progress = state.extra as ChildQuizProgressModel?;

              return CustomTransitionPage(
                transitionDuration: const Duration(milliseconds: 500),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0, 1);
                  const end = Offset.zero;
                  var curve = Curves.easeOutCubic;

                  var tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: QuizCompletionScreen(
                  correctStr: correct,
                  totalStr: total,
                  progress: progress,
                ),
              );
            },
          ),


        ],
      ),
    ],
  );
}
