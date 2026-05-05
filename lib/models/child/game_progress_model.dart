import 'dart:convert';

class GameProgressModel {
  final String gameId;
  final String gameName; // Added to track the descriptive name of the game
  final String childId;
  final int score;
  final int level;
  final DateTime updatedAt;

  GameProgressModel({
    required this.gameId,
    required this.gameName,
    required this.childId,
    required this.score,
    required this.level,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'gameName': gameName,
      'childId': childId,
      'score': score,
      'level': level,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GameProgressModel.fromMap(Map<dynamic, dynamic> map) {
    return GameProgressModel(
      gameId: map['gameId'] ?? '',
      gameName: map['gameName'] ?? '',
      childId: map['childId'] ?? '',
      score: map['score'] ?? 0,
      level: map['level'] ?? 1,
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());
}