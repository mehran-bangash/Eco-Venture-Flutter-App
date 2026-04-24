import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/child_view_model/inbox_report/child_safety_provider.dart';
import 'blocked_screen/app_locked_screen.dart';

class ChildSafetyEnforcer extends ConsumerWidget {
  final Widget child;
  const ChildSafetyEnforcer({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(childSafetySettingsProvider);
    final usageAsync = ref.watch(childUsageProvider);

    return settingsAsync.when(
      // FIX: Show a blank scaffold instead of `child` while loading.
      // This prevents the home screen from flashing before the lock check runs.
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.shrink(),
      ),
      error: (_, __) => child,
      data: (settings) {

        // 1. CHECK PAUSE (Parent Override)
        if (settings.isAppPaused) {
          return const AppLockedScreen(message: "App Paused by Parent");
        }

        // 2. CHECK BEDTIME
        if (_isBedtime(settings.bedtimeStart, settings.bedtimeEnd)) {
          return AppLockedScreen(
            message: "It's Bedtime! 🌙",
          );
        }

        // 3. CHECK DAILY LIMIT
        return usageAsync.when(
          // FIX: Same here — blank screen while usage data loads,
          // so a child who hit their limit doesn't see home screen first.
          loading: () => const Scaffold(
            backgroundColor: Colors.white,
            body: SizedBox.shrink(),
          ),
          error: (_, __) => child,
          data: (usedMinutes) {
            int limitMinutes = (settings.dailyLimitHours * 60).round();

            if (limitMinutes > 0 && usedMinutes >= limitMinutes) {
              return const AppLockedScreen(message: "Time's Up for Today!");
            }

            return child;
          },
        );
      },
    );
  }

  bool _isBedtime(String startStr, String endStr) {
    try {
      final now = TimeOfDay.now();
      final start = _parseTime(startStr);
      final end = _parseTime(endStr);

      final nowMinutes = now.hour * 60 + now.minute;
      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;

      if (startMinutes <= endMinutes) {
        return nowMinutes >= startMinutes && nowMinutes < endMinutes;
      } else {
        return nowMinutes >= startMinutes || nowMinutes < endMinutes;
      }
    } catch (e) {
      return false;
    }
  }

  TimeOfDay _parseTime(String s) {
    s = s.trim();
    bool isPm = s.contains("PM");
    bool isAm = s.contains("AM");

    String raw = s.replaceAll(RegExp(r'[A-Z ]'), '');
    List<String> parts = raw.split(":");

    int h = int.parse(parts[0]);
    int m = int.parse(parts[1]);

    if (isPm && h != 12) h += 12;
    if (isAm && h == 12) h = 0;

    return TimeOfDay(hour: h, minute: m);
  }
}