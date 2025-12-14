import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/parent_safety_settings_model.dart';
import '../../../repositories/child_safety_repository.dart';
import '../../../services/child_safety_service.dart';
import '../../../services/cloudinary_service.dart';
import 'child_report_state.dart';
import 'child_report_view_model.dart';

// 1. Services
// Keep as singleton to ensure Timer keeps running
final childSafetyServiceProvider = Provider<ChildSafetyService>((ref) {
  final service = ChildSafetyService();
  ref.onDispose(() => service.dispose()); // Cleanup timer
  return service;
});

final cloudinaryServiceProvider = Provider((ref) => CloudinaryService());

// 2. Repository
final childSafetyRepositoryProvider = Provider((ref) {
  return ChildSafetyRepository(
    ref.watch(childSafetyServiceProvider),
    ref.watch(cloudinaryServiceProvider),
  );
});

// 3. ViewModel
final childReportViewModelProvider =
    StateNotifierProvider<ChildReportViewModel, ChildReportState>((ref) {
      return ChildReportViewModel(ref.watch(childSafetyRepositoryProvider));
    });

// 4. SETTINGS STREAM
// Add .autoDispose here
final childSafetySettingsProvider =
    StreamProvider.autoDispose<ParentSafetySettingsModel>((ref) {
      // This forces the provider to reload fresh data every time the screen is opened
      return ChildSafetyService().getSafetySettingsStream();
    });
// 5. NEW: USAGE STREAM
final childUsageProvider = StreamProvider<int>((ref) {
  return ref.watch(childSafetyServiceProvider).usageMinutesStream;
});
