import 'package:go_router/go_router.dart';
import '../../views/teacher_section/teacher_home_screen.dart';
import '../constants/route_names.dart';



class TeacherRouter {
  static GoRoute routes = GoRoute(
    path: RouteNames.teacherHome,
    name: 'teacherHome',
    builder: (context, state) => const TeacherHomeScreen(),
    routes: [
      // GoRoute(
      //   path: 'class-management',
      //   name: 'classManagement',
      //   builder: (context, state) => const ClassManagementScreen(),
      // ),
      // GoRoute(
      //   path: 'assignments',
      //   name: 'assignments',
      //   builder: (context, state) => const AssignmentsScreen(),
      // ),
      // GoRoute(
      //   path: 'analytics',
      //   name: 'analytics',
      //   builder: (context, state) => const AnalyticsScreen(),
      // ),
    ],
  );
}
