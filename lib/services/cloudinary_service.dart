import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class CloudinaryService {
  final String cloudName = "dc6suw4tu"; // Your Child App Cloud Name

  final String defaultPreset = "ecoventure";

  // --- UPDATED: Using your new specific preset ---
  final String studentTaskPreset = "Eco_stem_challenges";

  /// Core: Upload image to Cloudinary
  Future<String?> uploadImage(File imageFile, {String? preset}) async {
    try {
      // Detect MIME type dynamically
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final fileType = mimeType.split('/');

      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/upload");

      final request = http.MultipartRequest("POST", uri)
        ..fields['upload_preset'] = preset ?? defaultPreset
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            imageFile.path,
            contentType: MediaType(fileType[0], fileType[1]),
          ),
        );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        return jsonResponse['secure_url']; // Final hosted image URL
      } else {
        final error = await response.stream.bytesToString();
        print("Cloudinary upload failed: ${response.statusCode} | $error");
        return null;
      }
    } catch (e) {
      print("⚠ Cloudinary upload error: $e");
      return null;
    }
  }

  // ---------------------------------------------------------
  //  STUDENT TASK FUNCTIONS
  // ---------------------------------------------------------

  /// 1. Upload Single Task Proof
  /// Uses the 'Eco_stem_challenges' preset
  Future<String?> uploadTaskImage(File imageFile) async {
    return await uploadImage(imageFile, preset: studentTaskPreset);
  }

  /// 2. Upload Multiple Task Proofs (One or More)
  Future<List<String>> uploadMultipleTaskImages(List<File> images) async {
    List<String> uploadedUrls = [];

    for (var image in images) {
      String? url = await uploadTaskImage(image);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    return uploadedUrls;
  }

  // ---------------------------------------------------------

  Future<void> deleteImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);

      // Extract full public_id
      String publicId = uri.pathSegments
          .skipWhile((segment) => segment != "upload")
          .skip(1)
          .join('/')
          .split('.')
          .first;

      final apiKey = "YOUR_API_KEY";
      final apiSecret = "YOUR_API_SECRET";

      final authHeader = 'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}';

      final response = await http.delete(
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/resources/image/upload/$publicId"),
        headers: {
          "Authorization": authHeader,
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to delete image: ${response.body}");
      }
    } catch (e) {
      print("Error deleting image: $e");
    }
  }
}