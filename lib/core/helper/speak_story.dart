import 'package:flutter_tts/flutter_tts.dart';

final FlutterTts flutterTts = FlutterTts();

Future<void> speakStory(String text) async {
  await flutterTts.setLanguage("en-US");
  await flutterTts.setPitch(1.0);
  await flutterTts.setSpeechRate(0.5); // slower for better clarity
  await flutterTts.speak(text);
}
