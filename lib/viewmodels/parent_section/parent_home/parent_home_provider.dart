import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repositories/parent_home_repository.dart';
import '../../../services/parent_home_service.dart';
import '../report_safety/parent_safety_provider.dart';

final parentHomeServiceProvider = Provider((ref) => ParentHomeService());

final parentHomeRepositoryProvider = Provider((ref) {
  return ParentHomeRepository(ref.watch(parentHomeServiceProvider));
});

// --- MAIN DASHBOARD STREAM ---
final parentDashboardStreamProvider = StreamProvider.autoDispose<Map<String, dynamic>>((ref) {
  final safetyState = ref.watch(parentSafetyViewModelProvider);
  final childId = safetyState.selectedChildId;

  if (childId == null) {
    return Stream.value({'usageMinutes': 0, 'recentActivity': [], 'totalXP': 0});
  }

  return ref.watch(parentHomeRepositoryProvider).getDashboardData(childId);
});