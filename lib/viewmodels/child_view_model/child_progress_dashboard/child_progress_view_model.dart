import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/child_progress_repository.dart';
import 'child_progress_state.dart';
import 'package:timeago/timeago.dart' as timeago; // Add timeago package for "2 hrs ago"

class ChildProgressViewModel extends StateNotifier<ChildProgressState> {
  final ChildProgressRepository _repository;
  StreamSubscription? _sub;

  ChildProgressViewModel(this._repository) : super(ChildProgressState()) {
    _initStream();
  }

  void _initStream() {
    state = state.copyWith(isLoading: true);

    _sub = _repository.getProgressStream().listen((data) {
      if (data.isEmpty) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final int points = data['totalPoints'] ?? 0;
      final List rawTimeline = data['timeline'] ?? [];
      final Map<String, int> rawSkills = Map<String, int>.from(data['skills'] ?? {});

      // 1. Level Logic
      int level = (points / 200).floor() + 1;
      double progress = (points % 200) / 200;

      // 2. Skill Logic (IMPROVED)
      Map<String, double> normalizedSkills = {};
      // Target: Complete 5 tasks to fill the bar (Easier gratification)
      const double targetTasks = 5.0;

      rawSkills.forEach((key, count) {
        if (count == 0) {
          normalizedSkills[key] = 0.02; // Empty state (tiny sliver)
        } else {
          // If count is 1, 1/5 = 0.2 (20% filled - visible!)
          normalizedSkills[key] = (count / targetTasks).clamp(0.2, 1.0);
        }
      });

      // 3. Timeline Formatting
      List<Map<String, dynamic>> formattedTimeline = rawTimeline.take(10).map((item) {
        final DateTime date = item['date'] != null
            ? (item['date'] is DateTime ? item['date'] : DateTime.tryParse(item['date'].toString()) ?? DateTime.now())
            : DateTime.now();

        Color color = Colors.blue;
        String type = item['type'] ?? 'Unknown';

        if (type == 'Quiz') color = const Color(0xFF9C27B0);
        else if (type == 'STEM') color = const Color(0xFF2196F3);
        else if (type == 'QR Hunt') color = const Color(0xFF4CAF50);
        else if (type == 'Video') color = const Color(0xFFE53935);
        else if (type == 'Story') color = const Color(0xFFFF9800);

        return {
          'title': item['title'] ?? 'Activity',
          'type': type,
          'time': timeago.format(date),
          'score': '+XP',
          'color': color,
        };
      }).toList();

      // 4. Streak
      int streak = rawTimeline.isNotEmpty ? 1 : 0;

      state = state.copyWith(
        isLoading: false,
        totalPoints: points,
        currentLevel: level,
        xpProgress: progress,
        skillStats: normalizedSkills,
        timeline: formattedTimeline,
        dayStreak: streak,
      );
    }, onError: (e) {
      print("Progress Stream Error: $e");
      state = state.copyWith(isLoading: false);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}