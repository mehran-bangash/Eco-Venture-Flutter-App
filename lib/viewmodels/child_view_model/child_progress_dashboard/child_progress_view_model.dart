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

      // 2. Skill Logic
      Map<String, double> normalizedSkills = {};
      rawSkills.forEach((key, count) {
        normalizedSkills[key] = (count / 10).clamp(0.1, 1.0);
      });

      // 3. Timeline Formatting
      List<Map<String, dynamic>> formattedTimeline = rawTimeline.take(10).map((item) {
        final DateTime date = item['date'];
        Color color = Colors.blue;
        String type = item['type'];

        // FIX: Map Types to Colors explicitly
        if (type == 'Quiz') color = Colors.purple;
        else if (type == 'STEM') color = Colors.blue;
        else if (type == 'QR Hunt') color = Colors.green;
        else if (type == 'Video') color = Colors.redAccent; // Video Color
        else if (type == 'Story') color = Colors.orange;    // Story Color

        return {
          'title': item['title'],
          'type': type,
          'time': timeago.format(date),
          'score': '+XP',
          'color': color,
        };
      }).toList();

      // 4. Streak Calculation
      int streak = 0;
      if (rawTimeline.isNotEmpty) streak = 1;

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
      print("Progress VM Error: $e");
      state = state.copyWith(isLoading: false);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}