import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/child_view_model/report_safety/child_safety_provider.dart';
import 'blocked_screen/app_locked_screen.dart';


class ChildSafetyEnforcer extends ConsumerWidget {
  final Widget child;
  const ChildSafetyEnforcer({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(childSafetySettingsProvider);
    final usageAsync = ref.watch(childUsageProvider);

    return settingsAsync.when(
        loading: () => child,
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
              // "Sleep well! See you at ${settings.bedtimeEnd}"
            );
          }

          // 3. CHECK DAILY LIMIT
          return usageAsync.when(
              loading: () => child,
              error: (_, __) => child,
              data: (usedMinutes) {
                int limitMinutes = (settings.dailyLimitHours * 60).round();

                if (limitMinutes > 0 && usedMinutes >= limitMinutes) {
                  return const AppLockedScreen(message: "Time's Up for Today!");
                }

                return child;
              }
          );
        }
    );
  }

  // Helper: Is Current Time between Start and End?
  bool _isBedtime(String startStr, String endStr) {
    try {
      final now = TimeOfDay.now();
      final start = _parseTime(startStr);
      final end = _parseTime(endStr);

      final nowMinutes = now.hour * 60 + now.minute;
      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;

      if (startMinutes <= endMinutes) {
        // Simple range (e.g. 1 PM to 5 PM)
        return nowMinutes >= startMinutes && nowMinutes < endMinutes;
      } else {
        // Overnight range (e.g. 9 PM to 7 AM)
        return nowMinutes >= startMinutes || nowMinutes < endMinutes;
      }
    } catch (e) {
      return false; // Fallback if format is wrong
    }
  }

  TimeOfDay _parseTime(String s) {
    // Expected format: "9:00 PM" or "21:00"
    // Clean string first
    s = s.trim();
    bool isPm = s.contains("PM");
    bool isAm = s.contains("AM");

    // Remove AM/PM for parsing numbers
    String raw = s.replaceAll(RegExp(r'[A-Z ]'), '');
    List<String> parts = raw.split(":");

    int h = int.parse(parts[0]);
    int m = int.parse(parts[1]);

    if (isPm && h != 12) h += 12;
    if (isAm && h == 12) h = 0;

    return TimeOfDay(hour: h, minute: m);
  }
}