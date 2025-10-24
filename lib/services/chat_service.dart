import 'dart:convert';
import 'package:eco_venture/core/config/api_constants.dart';
import 'package:http/http.dart' as http;

class ChatService {
  final String _apiUrl = ApiConstants.chatEndpoint;

  Future<String> sendMessage(String userMessage, String userId) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': userMessage,
          'userId': userId, //  FIXED
        }),
      );

      print('📡 Sent POST to: $_apiUrl');
      print('📦 Body: {"message": "$userMessage", "userId": "$userId"}');
      print('📥 Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? "AI didn’t return a reply.";
      } else {
        return "️ Error: Server returned ${response.statusCode}.";
      }
    } catch (e) {
      print(' Chat request failed: $e');
      return "AI (offline): I received your message — \"$userMessage\"";
    }
  }
}

