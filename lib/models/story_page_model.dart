class StoryPageModel {
  final String imageUrl;
  final String text;

  StoryPageModel({
    required this.imageUrl,
    required this.text,
  });

  factory StoryPageModel.fromMap(Map<String, dynamic> map) {
    return StoryPageModel(
      imageUrl: map['imageUrl'] ?? '',
      text: map['text'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'text': text,
    };
  }
}
