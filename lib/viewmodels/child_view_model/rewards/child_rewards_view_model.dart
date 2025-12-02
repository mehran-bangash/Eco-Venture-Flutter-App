import 'dart:async';

import 'package:flutter/material.dart';
import 'package:state_notifier/state_notifier.dart';

import '../../../services/child_rewards_service.dart';
import 'child_rewards_state.dart';

class ChildRewardsViewModel extends StateNotifier<ChildRewardsState> {
  final ChildRewardsService _service = ChildRewardsService();
  StreamSubscription? _sub;

  // --- TARGETS ---
  static const int quizTarget = 50;
  static const int stemTarget = 50;
  static const int videoTarget = 200;
  static const int qrTarget = 50;

  // --- SESSION TRACKING ---
  bool _isFirstLoad = true;
  int _lastQuiz = 0;
  int _lastStem = 0;
  int _lastQr = 0;

  ChildRewardsViewModel() : super(ChildRewardsState()) {
    startListening();
  }

  void startListening() {
    _sub?.cancel();
    _sub = _service.getRealTimeStats().listen((stats) {
      final points = stats['points'] as int;
      final quizCount = stats['quizCount'] as int;
      final stemCount = stats['stemCount'] as int;
      final qrCount = stats['qrCount'] as int;
      final videoCount = 0;

      // --- NOTIFICATION LOGIC ---
      String? notificationBadge;

      // Only trigger popup if crossing threshold in this session
      if (!_isFirstLoad) {
        if (_lastQuiz < quizTarget && quizCount >= quizTarget) {
          notificationBadge = "Quiz Master";
        }
        if (_lastStem < stemTarget && stemCount >= stemTarget) {
          notificationBadge = "STEM Explorer";
        }
        if (_lastQr < qrTarget && qrCount >= qrTarget) {
          notificationBadge = "Treasure Hunter";
        }
      }

      _lastQuiz = quizCount;
      _lastStem = stemCount;
      _lastQr = qrCount;
      _isFirstLoad = false;

      // --- LEVEL & BADGE LOGIC ---
      int level = (points / 200).floor() + 1;
      double progress = (points % 200) / 200;

      int badges = 0;
      List<Map<String, dynamic>> earnedBadges = [];

      if (quizCount >= quizTarget) {
        badges++;
        earnedBadges.add({
          'title': 'Quiz Master',
          'icon': Icons.quiz,
          'color': Colors.purple,
        });
      }
      if (stemCount >= stemTarget) {
        badges++;
        earnedBadges.add({
          'title': 'STEM Explorer',
          'icon': Icons.science,
          'color': Colors.blue,
        });
      }
      if (qrCount >= qrTarget) {
        badges++;
        earnedBadges.add({
          'title': 'Treasure Hunter',
          'icon': Icons.map,
          'color': Colors.green,
        });
      }

      // Use copyWith but specifically handle the nullable newEarnedBadge
      state = ChildRewardsState(
        isLoading: false,
        totalPoints: points,
        badgesEarned: badges,
        currentLevel: level,
        xpProgress: progress,
        recentAchievements: earnedBadges,
        quizCount: quizCount,
        stemCount: stemCount,
        qrCount: qrCount,
        videoCount: videoCount,
        newEarnedBadge:
            notificationBadge ??
            state.newEarnedBadge, // Keep existing unless overwritten
      );
    });
  }

  // --- THIS IS THE MISSING FUNCTION ---
  void clearNotification() {
    // Force the badge notification to null so dialog doesn't show again
    state = ChildRewardsState(
      isLoading: state.isLoading,
      totalPoints: state.totalPoints,
      badgesEarned: state.badgesEarned,
      currentLevel: state.currentLevel,
      xpProgress: state.xpProgress,
      recentAchievements: state.recentAchievements,
      quizCount: state.quizCount,
      stemCount: state.stemCount,
      videoCount: state.videoCount,
      qrCount: state.qrCount,
      newEarnedBadge: null, // CLEAR IT HERE
    );
  }

  // Added this if you need to force refresh manually, though stream handles it
  void loadRealRewardsData() {
    // Just restarts the listener
    startListening();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
