import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/child_view_model/game_viewmodel/game_viewmodel.dart';

class CircuitGameScreen extends ConsumerStatefulWidget {
  const CircuitGameScreen({super.key});

  @override
  ConsumerState<CircuitGameScreen> createState() => _CircuitGameScreenState();
}

class _CircuitGameScreenState extends ConsumerState<CircuitGameScreen> {
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
      ..setBackgroundColor(const Color(0xFF102027))
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: (_) {
        setState(() => _isWebReady = true);
        _resumeProgress();
      }))
      ..addJavaScriptChannel('GameChannel', onMessageReceived: (m) => _onGameMessage(m.message))
      ..loadFlutterAsset('assets/html/circuit_builder.html');
  }

  Future<void> _resumeProgress() async {
    final uid = SharedPreferencesHelper.instance.getUserId();
    if (uid == null) return;
    final snap = await FirebaseDatabase.instance.ref('game_module/$uid/circuit_builder/level').get();
    if (snap.exists && _isWebReady) {
      _controller.runJavaScript('window.setStartingLevel(${snap.value})');
    }
  }

  void _onGameMessage(String json) {
    final uid = SharedPreferencesHelper.instance.getUserId();
    if (uid == null) return;
    ref.read(gameViewModelProvider.notifier).saveProgress(
        childId: uid, gameId: 'circuit_builder', gameName: 'Circuit Builder', rawJson: json
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Circuit Lab"), backgroundColor: const Color(0xFF102027), foregroundColor: Colors.white),
      body: WebViewWidget(controller: _controller),
    );
  }
}