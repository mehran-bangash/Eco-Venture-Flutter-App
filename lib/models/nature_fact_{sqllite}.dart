class NatureFact {
  final String name;
  final String description;
  final String category;

  NatureFact({
    required this.name,
    required this.description,
    required this.category,
  });

  factory NatureFact.fromMap(Map<String, dynamic> map) {
    return NatureFact(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
    };
  }
}