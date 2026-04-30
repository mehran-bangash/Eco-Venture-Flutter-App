import 'package:eco_venture/core/routes/router_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth/auth_provider.dart';
import 'app_router.dart';

// router_providers.dart
final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  // ✅ Do NOT watch authState here. Let redirect() read it fresh each time.
  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/',
    redirect: (context, state) {
      // Read fresh authState on every redirect call
      final authState = ref.read(authViewModelProvider);
      return AppRouter.redirect(context, state, authState);
    },
    routes: AppRouter.routes,
  );
});