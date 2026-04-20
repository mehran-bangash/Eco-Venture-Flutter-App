import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth/auth_state.dart';
import '../../views/auth/forgot_password_screen.dart';
import '../../views/auth/sign_up_screen.dart';
import '../../views/splash_screen/splash_screen.dart';
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
    // Signup
    GoRoute(
      path: RouteNames.signup,
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),

    //forgot Password
    // Login
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

    // If on splash screen
    if (state.matchedLocation == RouteNames.splash) {
      // Still first time — let them see splash
      if (isFirstTime) return null;
      // Finished onboarding — send to role dashboard or landing
      if (userId != null && role != null) return _getRoleRoute(role);
      return RouteNames.login;
    }

    // If on auth pages but already logged in — skip to dashboard
    final bool isAuthPage =
        state.matchedLocation == RouteNames.landing ||
            state.matchedLocation == RouteNames.login ||
            state.matchedLocation == RouteNames.signup;

    if (isAuthPage && userId != null && role != null) {
      return _getRoleRoute(role);
    }

    return null;
  }

  static String _getRoleRoute(String role) {
    // Issue #5: Handle empty or unexpected role strings safely
    switch (role.toLowerCase()) {
      case 'child': return RouteNames.bottomNavChild;
      case 'parent': return RouteNames.bottomNavParent;
      case 'teacher': return RouteNames.bottomNavTeacher;
      default: return RouteNames.landing;
    }
  }
}