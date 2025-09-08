import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/exceptions/api_exceptions.dart';

class ApiService {
  Future<Map<String, dynamic>> sendUserToken(String url, dynamic data) async {
    final response = await http
        .post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    )
        .timeout(const Duration(seconds: 20));


    switch (response.statusCode) {
      case 200:
      // success → decode and return
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded;

      case 400:
        throw BadRequestException(response.body.toString());

      case 401:
      case 403:
        throw UnauthorizedException(response.body.toString());

      case 500:
        throw ServerException(response.body.toString());

      default:
        throw FetchDataException(
          "Error occurred: ${response.statusCode} → ${response.reasonPhrase}",
        );
    }
  }
}

