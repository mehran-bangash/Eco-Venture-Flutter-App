import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth/auth_state.dart';
import '../../views/auth/forgot_password_screen.dart';
import '../../views/auth/sign_up_screen.dart';
import '../../views/splash_screen/splash_screen.dart';
import '../../views/teacher_section/teacher_pending_screen/teacher_status_pending_screen.dart';
import '../constants/route_names.dart';
import 'child_router.dart';
import 'parent_router.dart';
import 'teacher_router.dart';
import '../../views/landing/landing_screen.dart';
import '../../views/auth/login_screen.dart';

class AppRouter {
  static List<RouteBase> routes = [
    GoRoute(
      path: RouteNames.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.landing,
      name: 'landing',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      name: 'login',
      builder: (context, state) {
        final role = state.extra as String?;
        return LoginScreen(selectRole: role);
      },
    ),
    GoRoute(
      path: '/pending-teacher',
      name: 'teacherStatusPending',
      builder: (context, state) => const TeacherStatusPendingScreen(),
    ),
    GoRoute(
      path: RouteNames.signup,
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: RouteNames.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => ForgotPasswordScreen(),
    ),
    ChildRouter.routes,
    ParentRouter.routes,
    TeacherRouter.routes,
  ];

  static String? redirect(BuildContext context, GoRouterState state, AuthState authState) {
    final bool isFirstTime = authState.isFirstTime;
    final String? userId = authState.userId;
    final String? role = authState.role;

    // --- NEW: SESSION BLOCKING LOGIC (CHILD ONLY) ---
    // This logic only runs for children.
    // It checks if a 'sessionInvalid' flag exists in your AuthState.
    final bool isChild = role?.toLowerCase() == 'child';
    final bool isSessionInvalid = authState.isSessionInvalid;

    if (isChild && userId != null && isSessionInvalid) {
      // If session is invalid, force them back to landing/login
      return RouteNames.login;
    }
    // ------------------------------------------------

    if (state.matchedLocation == RouteNames.splash) {
      if (isFirstTime) return null;
      if (userId != null && role != null) return _getRoleRoute(role);
      return RouteNames.login;
    }

    final bool isAuthPage =
        state.matchedLocation == RouteNames.landing ||
            state.matchedLocation == RouteNames.login ||
            state.matchedLocation == RouteNames.signup;

    if (isAuthPage && userId != null && role != null) {
      return _getRoleRoute(role);
    }

    return null; // Added return null to satisfy function signature
  }

  static String _getRoleRoute(String role) {
    switch (role.toLowerCase()) {
      case 'child': return RouteNames.bottomNavChild;
      case 'parent': return RouteNames.bottomNavParent;
      case 'teacher': return RouteNames.bottomNavTeacher;
      default: return RouteNames.landing;
    }
  }
}