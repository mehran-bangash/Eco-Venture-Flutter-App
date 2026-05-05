import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/child_view_model/game_viewmodel/game_viewmodel.dart';

class EcoGameScreen extends ConsumerStatefulWidget {
  const EcoGameScreen({super.key});

  @override
  ConsumerState<EcoGameScreen> createState() => _EcoGameScreenState();
}

class _EcoGameScreenState extends ConsumerState<EcoGameScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            setState(() => _isLoading = false);
            _resumeProgress(); // Fetch and set last level
          },
        ),
      )
      ..addJavaScriptChannel(
        'GameChannel',
        onMessageReceived: (message) => _onGameMessage(message.message),
      )
      ..loadFlutterAsset('assets/html/recycling_game.html');
  }

  Future<void> _resumeProgress() async {
    final childId = SharedPreferencesHelper.instance.getUserId();
    if (childId == null) return;

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('game_module/$childId/recycling_sorter/level')
          .get();

      if (snapshot.exists) {
        final lastLevel = snapshot.value as int;
        // Inject JS to jump to that level
        _controller.runJavaScript('window.setStartingLevel($lastLevel)');
      }
    } catch (e) {
      debugPrint("Error resuming progress: $e");
    }
  }

  void _onGameMessage(String jsonString) {
    final childId = SharedPreferencesHelper.instance.getUserId();
    if (childId == null) return;

    ref.read(gameViewModelProvider.notifier).saveProgress(
      childId: childId,
      gameId: 'recycling_sorter',
      gameName: 'Recycling Sorter',
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Mission Success! 🏆"),
        content: const Text("Great job! You've mastered all recycling levels."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text("AWESOME"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Eco Mission")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}