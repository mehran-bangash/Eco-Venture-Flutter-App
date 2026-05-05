import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/child/game_progress_model.dart';
import '../../services/child/game_service.dart';


class GameRepository {
  final GameService _gameService;

  GameRepository(this._gameService);

  // Uses 'compute' to parse JSON in an Isolate to keep Main Thread smooth
  Future<void> saveGameResult({
    required String childId,
    required String gameId,
    required String gameName, // Added descriptive game name (e.g., "Recycling Sorter")
    required String rawJson,
  }) async {
    try {
      final Map<String, dynamic> parsedData = await compute(_parseJson, rawJson);

      final progress = GameProgressModel(
        gameId: gameId,
        gameName: gameName, // Included game name in the model
        childId: childId,
        score: parsedData['score'] as int,
        level: parsedData['level'] as int,
        updatedAt: DateTime.now(),
      );

      // Path: game_module/{childId}/{gameId}
      final String path = 'game_module/$childId/$gameId';
      await _gameService.updateData(path, progress.toMap());

    } catch (e) {
      debugPrint("Repository Error: $e");
    }
  }
}

// Top-level function for Isolate
Map<String, dynamic> _parseJson(String json) => jsonDecode(json);