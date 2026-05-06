import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

class TtsService {
  final String _apiKey = "YOUR_API_KEY";

  Future<Uint8List?> generateSpeech(String text, String language) async {
    try {
      // 1. Check local file cache first
      final String fileName = _generateHash(text, language);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.wav');

      if (await file.exists()) {
        debugPrint("Playing from Gemini cache...");
        return await file.readAsBytes();
      }

      // 2. Not in cache? Call API
      final audioData = await _makeApiCall(text, language);

      // 3. Save to cache
      if (audioData != null) {
        await file.writeAsBytes(audioData);
      }

      return audioData;
    } catch (e) {
      debugPrint("Gemini Service Error: $e");
      return null;
    }
  }

  String _generateHash(String text, String lang) {
    return sha256.convert(utf8.encode(text + lang)).toString();
  }

  Future<Uint8List?> _makeApiCall(String text, String language) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent?key=$_apiKey');
    final String prompt = language == 'Urdu' ? "Translate to Urdu and speak: $text" : "Speak in English: $text";

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
          "responseModalities": ["AUDIO"],
          "speechConfig": {
            "voiceConfig": {
              "prebuiltVoiceConfig": {"voiceName": language == 'Urdu' ? "Kore" : "Zephyr"}
            }
          }
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final inlineData = data['candidates'][0]['content']['parts'][0]['inlineData'];
      final Uint8List pcmBytes = base64Decode(inlineData['data']);
      return _addWavHeader(pcmBytes, 24000);
    }
    return null;
  }

  Uint8List _addWavHeader(Uint8List pcmData, int sampleRate) {
    final int fileSize = pcmData.length + 44;
    final ByteData header = ByteData(44);
    header.setUint8(0, 0x52); header.setUint8(1, 0x49); header.setUint8(2, 0x46); header.setUint8(3, 0x46);
    header.setUint32(4, fileSize - 8, Endian.little);
    header.setUint8(8, 0x57); header.setUint8(9, 0x41); header.setUint8(10, 0x56); header.setUint8(11, 0x45);
    header.setUint8(12, 0x66); header.setUint8(13, 0x6D); header.setUint8(14, 0x74); header.setUint8(15, 0x20);
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little); header.setUint16(22, 1, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate * 2, Endian.little);
    header.setUint16(32, 2, Endian.little); header.setUint16(34, 16, Endian.little);
    header.setUint8(36, 0x64); header.setUint8(37, 0x61); header.setUint8(38, 0x74); header.setUint8(39, 0x61);
    header.setUint32(40, pcmData.length, Endian.little);
    return Uint8List.fromList(header.buffer.asUint8List() + pcmData);
  }
}