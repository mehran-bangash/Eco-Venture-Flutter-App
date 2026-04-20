import 'package:eco_venture/core/routes/router_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth/auth_provider.dart';
import '../constants/route_names.dart';
import 'app_router.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);
  final authState = ref.watch(authViewModelProvider); // Watch the state here

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/', // Usually maps to Splash
    // Pass the current authState to the redirect logic
    redirect: (context, state) => AppRouter.redirect(context, state, authState),
    routes: AppRouter.routes,
  );
});