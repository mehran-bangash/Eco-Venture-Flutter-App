import 'package:eco_venture/views/auth/sign_up_screen.dart';
import 'package:go_router/go_router.dart';

import '../constants/route_names.dart';
import 'child_router.dart';
import 'parent_router.dart';
import 'teacher_router.dart';

// Import shared screens
import '../../views/landing/landing_screen.dart';
import '../../views/auth/login_screen.dart';


class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      // // Splash
      // GoRoute(
      //   path: RouteNames.splash,
      //   name: 'splash',
      //   builder: (context, state) => const SplashScreen(),
      // ),

      // Landing
      GoRoute(
        path: RouteNames.landing,
        name: 'landing',
        builder: (context, state) => const LandingScreen(),
      ),

      // Login
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Signup
      GoRoute(
        path: RouteNames.signup,
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      // Child role routes
      ChildRouter.routes,

      // Parent role routes
      ParentRouter.routes,

      // Teacher role routes
      TeacherRouter.routes,
    ],
  );
}
