
import 'package:go_router/go_router.dart';
import '../../views/parent_section/parent_home_screen.dart';
import '../constants/route_names.dart';

class ParentRouter {
  static GoRoute routes = GoRoute(
    path: RouteNames.parentHome,
    name: 'parentHome',
    builder: (context, state) => const ParentHomeScreen(),
    routes: [
      // GoRoute(
      //   path: 'progress-dashboard',
      //   name: 'progressDashboard',
      //   builder: (context, state) => const ProgressDashboardScreen(),
      // ),
      // GoRoute(
      //   path: 'rewards',
      //   name: 'rewards',
      //   builder: (context, state) => const RewardsScreen(),
      // ),
      // GoRoute(
      //   path: 'reporting',
      //   name: 'reporting',
      //   builder: (context, state) => const ReportingScreen(),
      // ),
    ],
  );
}
