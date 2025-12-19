
import 'nature_fact_{sqllite}.dart';
import 'nature_photo_predictiion{ai}.dart';

class JournalEntry {
  final String id;
  final String userId;
  final String imageUrl;
  final DateTime timestamp;
  final NaturePrediction prediction;
  final NatureFact fact;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.timestamp,
    required this.prediction,
    required this.fact,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'prediction': prediction.toMap(),
      'fact': fact.toMap(),
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      prediction: NaturePrediction.fromJson(Map<String, dynamic>.from(map['prediction'])),
      fact: NatureFact.fromMap(Map<String, dynamic>.from(map['fact'])),
    );
  }

  // --- FIXED COPYWITH FUNCTION ---
  JournalEntry copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    DateTime? timestamp,
    NaturePrediction? prediction,
    NatureFact? fact,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      prediction: prediction ?? this.prediction,
      fact: fact ?? this.fact,
    );
  }
}