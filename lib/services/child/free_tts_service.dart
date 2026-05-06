import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:flutter/material.dart';

class FreeTtsService {
  final FlutterTts _flutterTts = FlutterTts();
  final GoogleTranslator _translator = GoogleTranslator();

  // Logic: In-memory cache for translations to avoid repeated API calls
  final Map<String, String> _translationCache = {};

  Future<void> speak(String text, String language) async {
    String textToSpeak = text;

    if (language == 'Urdu') {
      // 1. Check if we translated this clue before
      if (_translationCache.containsKey(text)) {
        debugPrint("Using cached Urdu translation...");
        textToSpeak = _translationCache[text]!;
      } else {
        debugPrint("Translating to Urdu via API...");
        var translation = await _translator.translate(text, from: 'en', to: 'ur');
        textToSpeak = translation.text;
        _translationCache[text] = textToSpeak; // Save to cache
      }
      await _flutterTts.setLanguage("ur-PK");
    } else {
      await _flutterTts.setLanguage("en-US");
    }

    await _flutterTts.speak(textToSpeak);
  }
}