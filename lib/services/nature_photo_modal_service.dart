import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nature_photo_predictiion{ai}.dart';
import 'nature_photo_sqlflite.dart'; // Import your LocalDBService

class ModalService {
  final String _endpointUrl = "https://muhammadmavia540--yolo8-object-detection-api-predict.modal.run";
  final LocalDBService _dbService = LocalDBService(); // DB instance

  Future<NaturePrediction> predictImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_endpointUrl));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var json = jsonDecode(responseString);

        // Normalize label from model
        String rawLabel = (json['label'] as String).trim().toLowerCase();
        String normalizedLabel = _normalizeLabel(rawLabel);

        // Query local DB for description
        var fact = await _dbService.getFactFor(normalizedLabel);

        return NaturePrediction(
          label: fact.name,
          confidence: json['confidence'] ?? 0.0,
          description: fact.description,
          category: fact.category,
        );
      } else {
        throw Exception("Model API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Modal Error: $e");
      return NaturePrediction(
        label: "Unknown",
        confidence: 0.0,
        description: "We are still learning about this!",
        category: "Unknown",
      );
    }
  }

  String _normalizeLabel(String label) {
    String temp = label.trim().toLowerCase().replaceAll(' ', '_');

    Map<String, String> labelMap = {
      "cat": "cat",
      "dog": "dog",
      "babul": "babul",
      "bamboo": "bamboo",
      "burnet": "burnet",
      "cactus": "cactus",
      "cockroach": "cockroach",
      "dafodil": "dafodils",
      "daffodil": "dafodils",
      "elephant": "elephant",
      "fly": "fly",
      "giraffe": "giraffe",
      "grasshopper": "grasshopper",
      "ladybug": "ladybugs",
      "ladybugs": "ladybugs",
      "leopard": "leopard",
      "mango": "mango",
      "neem": "neem",
      "ostrich": "ostrich",
      "palm tree": "palm_tree",
      "pipal": "pipal",
      "purple cornflower": "purple_cornflower",
      "sunflower": "sunflower",
      "turtle": "turtle",
      "zebra": "zebra",
      "azalea": "azalea",
    };

    return labelMap[temp] ?? temp;
  }

}