import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/child_view_model/inbox_report/child_safety_provider.dart';
import 'blocked_screen/app_locked_screen.dart';
import 'dart:async';

class ChildSafetyEnforcer extends ConsumerStatefulWidget {
  final Widget child;
  const ChildSafetyEnforcer({super.key, required this.child});

  @override
  ConsumerState<ChildSafetyEnforcer> createState() => _ChildSafetyEnforcerState();
}

class _ChildSafetyEnforcerState extends ConsumerState<ChildSafetyEnforcer> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Logic: Force a rebuild every minute to check if bedtime has started or ended

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(childSafetySettingsProvider);
    final usageAsync = ref.watch(childUsageProvider);

    return settingsAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
      ),
      error: (_, __) => widget.child,
      data: (settings) {
        // 1. CHECK PAUSE
        if (settings.isAppPaused) {
          return const AppLockedScreen(message: "App Paused by Parent");
        }

        // 2. CHECK BEDTIME (Now refreshes every minute via the timer)
        if (_isBedtime(settings.bedtimeStart, settings.bedtimeEnd)) {
          return const AppLockedScreen(message: "It's Bedtime! 🌙");
        }

        // 3. CHECK DAILY LIMIT
        return usageAsync.when(
          loading: () => const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
          ),
          error: (_, __) => widget.child,
          data: (usedMinutes) {
            int limitMinutes = (settings.dailyLimitHours * 60).round();
            if (limitMinutes > 0 && usedMinutes >= limitMinutes) {
              return const AppLockedScreen(message: "Time's Up for Today!");
            }
            return widget.child;
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
        // Overnight logic (e.g., 10 PM to 7 AM)
        return nowMinutes >= startMinutes || nowMinutes < endMinutes;
      }
    } catch (e) {
      debugPrint("Bedtime parse error: $e");
      return false;
    }
  }

  TimeOfDay _parseTime(String s) {
    s = s.trim().toUpperCase();
    bool isPm = s.contains("PM");
    bool isAm = s.contains("AM");

    // Remove AM/PM and spaces to get just "7:30"
    String raw = s.replaceAll(RegExp(r'[A-Z ]'), '');
    List<String> parts = raw.split(":");

    int h = int.parse(parts[0]);
    int m = int.parse(parts[1]);

    if (isPm && h != 12) h += 12;
    if (isAm && h == 12) h = 0;

    return TimeOfDay(hour: h, minute: m);
  }
}