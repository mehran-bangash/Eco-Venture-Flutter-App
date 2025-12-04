import 'package:eco_venture/models/user_model.dart';
import 'package:eco_venture/navigation/bottom_nav_teacher.dart';
import 'package:eco_venture/views/teacher_section/add_student_screen.dart';
import 'package:eco_venture/views/teacher_section/class_report_screen.dart';
import 'package:eco_venture/views/teacher_section/multi_media_content_Module/teacher_add_story_screen.dart';
import 'package:eco_venture/views/teacher_section/multi_media_content_Module/teacher_add_video_screen.dart';
import 'package:eco_venture/views/teacher_section/multi_media_content_Module/teacher_edit_story_screen.dart';
import 'package:eco_venture/views/teacher_section/multi_media_content_Module/teacher_edit_video_screen.dart';
import 'package:eco_venture/views/teacher_section/multi_media_content_Module/teacher_multimedia_dashboard.dart';
import 'package:eco_venture/views/teacher_section/multi_media_content_Module/teacher_story_dashboard.dart';
import 'package:eco_venture/views/teacher_section/multi_media_content_Module/teacher_video_dahboard.dart';
import 'package:eco_venture/views/teacher_section/profile/teacher_edit_profile_screen.dart';
import 'package:eco_venture/views/teacher_section/profile/teacher_profile_screen.dart';
import 'package:eco_venture/views/teacher_section/quiz_module/teacher_add_quiz_screen.dart';
import 'package:eco_venture/views/teacher_section/quiz_module/teacher_quiz_dashboard.dart';
import 'package:eco_venture/views/teacher_section/settings/teacher_settings.dart';
import 'package:eco_venture/views/teacher_section/stem_challenges_module/teacher_edit_stem_challenge_screen.dart';
import 'package:eco_venture/views/teacher_section/stem_challenges_module/teacher_stem_dashboard.dart';
import 'package:eco_venture/views/teacher_section/teacher_home_screen.dart';
import 'package:eco_venture/views/teacher_section/teacher_treasure_hunt/teacher_add_treasure_hunt_screen.dart';
import 'package:eco_venture/views/teacher_section/teacher_treasure_hunt/teacher_edit_treasure_hunt_screen.dart';
import 'package:eco_venture/views/teacher_section/teacher_treasure_hunt/teacher_treasure_hunt_dashboard.dart';
import 'package:eco_venture/views/teacher_section/view_student_detail_screen.dart';
import 'package:go_router/go_router.dart';

import '../../views/child_section/report_issue_screen.dart';
import '../../views/child_section/report_safety_screen.dart';
import '../../views/child_section/rewards_screen.dart';
import '../../views/teacher_section/quiz_module/teacher_edit_quiz_screen.dart';
import '../../views/teacher_section/stem_challenges_module/teacher_add_stem_challenge_Screen.dart';
import '../constants/route_names.dart';

class TeacherRouter {
  static GoRoute routes = GoRoute(
    path: RouteNames.bottomNavTeacher,
    name: 'bottomNavTeacher',
    builder: (context, state) => const BottomNavTeacher(),
    routes: [
      // Teacher Profile
      GoRoute(
        path: RouteNames.teacherSettings,
        name: 'teacherSettings',
        builder: (context, state) => const TeacherSettings(),
        routes: [
          GoRoute(
            path: RouteNames.teacherProfile,
            name: 'teacherProfile',
            builder: (context, state) => const TeacherProfileScreen(),
          ),
          GoRoute(
            path: RouteNames.teacherEditProfile,
            name: 'teacherEditProfile',
            builder: (context, state) => const TeacherEditProfileScreen(),
          ),
        ],
      ),

      // Teacher Progress Dashboard
      // GoRoute(
      //   path: 'progress-dashboard-screen',
      //   name: 'teacherProgressDashboard',
      //   builder: (context, state) => const ProgressDashboardScreen(),
      // ),

      // Teacher Rewards
      GoRoute(
        path: 'rewards-screen',
        name: 'teacherRewardsScreen',
        builder: (context, state) => RewardsScreen(),
      ),

      // Teacher Safety
      GoRoute(
        path: 'report-safety-screen',
        name: "teacherReportSafetyScreen",
        builder: (context, state) => const ReportSafetyScreen(),
        routes: [
          GoRoute(
            path: 'report-issue-screen',
            name: "teacherReportIssueScreen",
            builder: (context, state) => const ReportIssueScreen(),
          ),
        ],
      ),

      // Teacher Settings
      // Teacher Home + Add Student
      GoRoute(
        path: RouteNames.teacherHome,
        name: 'teacherHome',
        builder: (context, state) => const TeacherHomeScreen(),
        routes: [
          GoRoute(
            path: RouteNames.addStudentScreen,
            name: 'addStudentScreen',
            builder: (context, state) => const AddStudentScreen(),
          ),
          GoRoute(
            path: RouteNames.studentDetailScreen,
            name: 'studentDetailScreen',
            builder: (context, state) {
              // CORRECTED: Create UserModel from the map passed in `state.extra`
              final studentMap = state.extra as Map<String, dynamic>;
              final student = UserModel.fromMap(studentMap);
              return StudentDetailScreen(student: student);
            },
          ),
          GoRoute(
            path: RouteNames.classReportScreen,
            name: 'classReportScreen',
            builder: (context, state) => const ClassReportScreen(),
          ),
          GoRoute(
            path: RouteNames.teacherQuizDashboard,
            name: 'teacherQuizDashBoard',
            builder: (context, state) => const TeacherQuizDashboard(),
            routes: [
              GoRoute(
                path: RouteNames.teacherAddQuizScreen,
                name: 'teacherAddQuizScreen',
                builder: (context, state) => const TeacherAddQuizScreen(),
              ),
              GoRoute(
                path: RouteNames.teacherEditQuizScreen,
                name: 'teacherEditQuizScreen',
                builder: (context, state) {
                  final dynamic quizData = state.extra; // Map or Model
                  return TeacherEditQuizScreen(quizData: quizData);
                },
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.teacherStemChallengeDashboard,
            name: 'teacherStemChallengeDashboard',
            builder: (context, state) => TeacherStemDashboard(),
            routes: [
              GoRoute(
                path: RouteNames.teacherAddStemChallengeScreen,
                name: 'teacherAddStemChallengeScreen',
                builder: (context, state) => TeacherAddStemChallengeScreen(),
              ),
              GoRoute(
                path: RouteNames.teacherEditStemChallengeScreen,
                name: 'teacherEditStemChallengeScreen',
                builder: (context, state) {
                  final dynamic challengeData = state.extra;
                  return TeacherEditStemChallengeScreen(
                    challengeData: challengeData,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.teacherMultimediaDashboard,
            name: 'teacherMultimediaDashboard',
            builder: (context, state) => const TeacherMultimediaDashboard(),
            routes: [
              GoRoute(
                path: RouteNames.teacherVideoDashboard,
                name: 'teacherVideoDashboard',
                builder: (context, state) => const TeacherVideoDashboard(),
                routes: [
                  GoRoute(
                    path: RouteNames.teacherAddVideoScreen,
                    name: 'teacherAddVideoScreen',
                    builder: (context, state) => const TeacherAddVideoScreen(),
                  ),
                  GoRoute(
                    path: RouteNames.teacherEditVideoScreen,
                    name: 'teacherEditVideoScreen',
                    builder: (context, state) {
                      final dynamic videoData = state.extra;
                      return TeacherEditVideoScreen(videoData: videoData);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: RouteNames.teacherStoryDashboard,
                name: 'teacherStoryDashboard',
                builder: (context, state) => TeacherStoryDashboard(),
                routes: [
                  GoRoute(
                    path: RouteNames.teacherAddStoryScreen,
                    name: 'teacherAddStoryScreen',
                    builder: (context, state) => const TeacherAddStoryScreen(),
                  ),
                  GoRoute(
                    path: RouteNames.teacherEditStoryScreen,
                    name: 'teacherEditStoryScreen',
                    builder: (context, state) {
                      final dynamic storyData = state.extra;
                      return TeacherEditStoryScreen(storyData: storyData);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.teacherTreasureHuntDashboard,
            name: 'teacherTreasureHuntDashboard',
            builder: (context, state) => const TeacherTreasureHuntDashboard(),
            routes: [
              GoRoute(
                path: RouteNames.teacherAddTreasureHuntScreen,
                name: 'teacherAddTreasureHuntScreen',
                builder: (context, state) => const TeacherAddTreasureHuntScreen(),
              ),
              GoRoute(
                path: RouteNames.teacherEditTreasureHuntScreen,
                name: 'teacherEditTreasureHuntScreen',
                builder: (context, state) {
                  final dynamic huntData = state.extra;
                  return TeacherEditTreasureHuntScreen(huntData: huntData);
                },
              ),


            ]
          ),
        ],
      ),
    ],
  );
}
