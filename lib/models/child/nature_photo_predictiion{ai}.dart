class NaturePrediction {
  final String label;      // The "Name" predicted by AI
  final double confidence; // How sure the AI is

  NaturePrediction({
    required this.label,
    required this.confidence, required String description, required String category,
  });

  factory NaturePrediction.fromJson(Map<String, dynamic> json) {
    return NaturePrediction(
      label: json['label'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(), description: '', category: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'confidence': confidence,
    };
  }

  copyWith({required String label}) {}
}