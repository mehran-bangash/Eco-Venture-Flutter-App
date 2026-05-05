import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/child_view_model/game_viewmodel/game_viewmodel.dart';

class MathAdventureScreen extends ConsumerStatefulWidget {
  const MathAdventureScreen({super.key});

  @override
  ConsumerState<MathAdventureScreen> createState() => _MathAdventureScreenState();
}

class _MathAdventureScreenState extends ConsumerState<MathAdventureScreen> {
  late final WebViewController _controller;
  bool _isWebReady = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF87CEEB))
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          setState(() => _isWebReady = true);
          _resumeProgress();
        },
      ))
      ..addJavaScriptChannel(
        'GameChannel',
        onMessageReceived: (JavaScriptMessage m) => _onGameMessage(m.message),
      )
      ..loadFlutterAsset('assets/html/math_adventure.html');
  }

  /// Fetches saved level from Firebase and sets it in the WebView
  Future<void> _resumeProgress() async {
    final uid = SharedPreferencesHelper.instance.getUserId();
    if (uid == null) return;

    final dbRef = FirebaseDatabase.instance.ref('game_module/$uid/math_adventure/level');
    final snapshot = await dbRef.get();

    if (snapshot.exists && _isWebReady) {
      final level = snapshot.value as int;
      _controller.runJavaScript('window.setStartingLevel($level)');
    }
  }

  /// Handles progress data sent from the JavaScript game
  void _onGameMessage(String json) {
    final uid = SharedPreferencesHelper.instance.getUserId();
    if (uid == null) return;

    ref.read(gameViewModelProvider.notifier).saveProgress(
      childId: uid,
      gameId: 'math_adventure',
      gameName: 'Math Adventure',
      rawJson: json,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Math Island Adventure"),
        backgroundColor: const Color(0xFF87CEEB),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}