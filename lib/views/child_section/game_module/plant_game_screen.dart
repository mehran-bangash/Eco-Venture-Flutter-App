import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/child_view_model/game_viewmodel/game_viewmodel.dart';

class PlantGameScreen extends ConsumerStatefulWidget {
  const PlantGameScreen({super.key});

  @override
  ConsumerState<PlantGameScreen> createState() => _PlantGameScreenState();
}

class _PlantGameScreenState extends ConsumerState<PlantGameScreen> {
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
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() => _isWebReady = true);
            _resumeProgress();
          },
        ),
      )
      ..addJavaScriptChannel(
        'GameChannel',
        onMessageReceived: (message) => _onGameMessage(message.message),
      )
      ..loadFlutterAsset('assets/html/plant_game.html');
  }

  Future<void> _resumeProgress() async {
    final childId = SharedPreferencesHelper.instance.getUserId();
    if (childId == null) return;

    final snapshot = await FirebaseDatabase.instance
        .ref('game_module/$childId/plant_growth/level')
        .get();

    if (snapshot.exists && _isWebReady) {
      final lastLevel = snapshot.value as int;
      _controller.runJavaScript('window.setStartingLevel($lastLevel)');
    }
  }

  void _onGameMessage(String jsonString) {
    final childId = SharedPreferencesHelper.instance.getUserId();
    if (childId == null) return;

    ref.read(gameViewModelProvider.notifier).saveProgress(
      childId: childId,
      gameId: 'plant_growth',
      gameName: 'Plant Growth',
      rawJson: jsonString,
    );

    if (jsonString.contains('"status":"completed"')) {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Garden Master! 🌻"),
        content: const Text("You've grown a beautiful garden today!"),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text("CLOSE")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plant Growth")),
      body: WebViewWidget(controller: _controller),
    );
  }
}