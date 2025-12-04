import 'package:eco_venture/navigation/bottom_nav_parent.dart';
import 'package:eco_venture/views/parent_section/parent_child_section_screen.dart';
import 'package:eco_venture/views/parent_section/profile/parent_edit_profile_screen.dart';
import 'package:eco_venture/views/parent_section/profile/parent_profile_screen.dart';
import 'package:eco_venture/views/parent_section/safety_and_report/parent_content_filters_screen.dart';
import 'package:eco_venture/views/parent_section/safety_and_report/parent_report_alerts_screen.dart';
import 'package:eco_venture/views/parent_section/safety_and_report/parent_report_safety_screen.dart';
import 'package:eco_venture/views/parent_section/safety_and_report/parent_screen_time_screen.dart';
import 'package:eco_venture/views/parent_section/settings/parent_settings.dart';
import 'package:go_router/go_router.dart';
import '../../views/parent_section/parent_home_screen.dart';
import '../constants/route_names.dart';

class ParentRouter {
  static GoRoute routes = GoRoute(
    path: RouteNames.parentChildSection,
    name: 'parentChildSection',
    builder: (context, state) => const ParentChildSelectionScreen(),
    routes: [
      GoRoute(
        path: RouteNames.bottomNavParent,
        name: 'bottomNavParent',
        builder: (context, state) => const BottomNavParent(),
        routes: [
          GoRoute(
            path: RouteNames.parentHome,
            name: 'parentHome',
            builder: (context, state) => const ParentHomeScreen(),
          ),

          GoRoute(
            path: RouteNames.parentSettings,
            name: 'parentSettings',
            builder: (context, state) => const ParentSettings(),
            routes: [
              GoRoute(
                path: RouteNames.parentProfile,
                name: 'parentProfile',
                builder: (context, state) => const ParentProfileScreen(),
              ),
              GoRoute(
                path: RouteNames.parentEditProfile,
                name: 'parentEditProfile',
                builder: (context, state) => const ParentEditProfileScreen(),
              ),
            ],
          ),

          GoRoute(
            path: RouteNames.parentReportSafetyScreen,
            name: 'parentReportSafetyScreen',
            builder: (context, state) => const ParentReportSafetyScreen(),
            routes: [
              GoRoute(
                path: RouteNames.parentScreenTimeScreen,
                name: 'parentScreenTimeScreen',
                builder: (context, state) => const ParentScreenTimeScreen(),
              ),
              GoRoute(
                path: RouteNames.parentContentFiltersScreen,
                name: 'parentContentFiltersScreen',
                builder: (context, state) => const ParentContentFiltersScreen(),
              ),
              GoRoute(
                path: RouteNames.parentReportAlertsScreen,
                name: 'parentReportAlertsScreen',
                builder: (context, state) => const ParentReportAlertsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

