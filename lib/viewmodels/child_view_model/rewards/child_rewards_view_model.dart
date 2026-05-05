import 'dart:async';
import 'package:flutter/material.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../../services/child/child_rewards_service.dart';
import 'child_rewards_state.dart';

class ChildRewardsViewModel extends StateNotifier<ChildRewardsState> {
  final ChildRewardsService _service = ChildRewardsService();
  StreamSubscription? _sub;

  // --- TARGETS ---
  static const int quizTarget = 50;
  static const int stemTarget = 50;
  static const int videoTarget = 200;
  static const int qrTarget = 50;
  static const int gameTarget = 50; // New Game Target

  // --- SESSION TRACKING ---
  bool _isFirstLoad = true;
  int _lastQuiz = 0;
  int _lastStem = 0;
  int _lastQr = 0;
  int _lastGame = 0; // New Session Tracker

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
      final gameCount = stats['gameCount'] as int; // Pull from Service
      final videoCount = 0;

      // --- NOTIFICATION LOGIC ---
      String? notificationBadge;

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
        if (_lastGame < gameTarget && gameCount >= gameTarget) {
          notificationBadge = "Game Master"; // New Notification
        }
      }

      _lastQuiz = quizCount;
      _lastStem = stemCount;
      _lastQr = qrCount;
      _lastGame = gameCount;
      _isFirstLoad = false;

      // --- LEVEL & BADGE LOGIC ---
      int level = (points / 200).floor() + 1;
      double progress = (points % 200) / 200;

      int badges = 0;
      List<Map<String, dynamic>> earnedBadges = [];

      if (quizCount >= quizTarget) {
        badges++;
        earnedBadges.add({'title': 'Quiz Master', 'icon': Icons.quiz, 'color': Colors.purple});
      }
      if (stemCount >= stemTarget) {
        badges++;
        earnedBadges.add({'title': 'STEM Explorer', 'icon': Icons.science, 'color': Colors.blue});
      }
      if (qrCount >= qrTarget) {
        badges++;
        earnedBadges.add({'title': 'Treasure Hunter', 'icon': Icons.map, 'color': Colors.green});
      }
      if (gameCount >= gameTarget) {
        badges++;
        earnedBadges.add({'title': 'Game Master', 'icon': Icons.sports_esports, 'color': Colors.orange});
      }

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
        gameCount: gameCount, // Ensure your State class has this field
        videoCount: videoCount,
        newEarnedBadge: notificationBadge ?? state.newEarnedBadge,
      );
    });
  }

  void clearNotification() {
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
      gameCount: state.gameCount,
      newEarnedBadge: null,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}