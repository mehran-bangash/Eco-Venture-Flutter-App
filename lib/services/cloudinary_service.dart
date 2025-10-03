import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class CloudinaryService {
  final String cloudName = "dc6suw4tu"; // your cloud name
  final String defaultPreset = "ecoventure"; // default preset

  /// Upload image to Cloudinary
  /// [preset] allows switching between different presets (e.g. "profile")
  Future<String?> uploadImage(File imageFile, {String? preset}) async {
    try {
      // Detect MIME type dynamically (e.g. image/jpeg, image/png, image/heic)
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
        return jsonResponse['secure_url']; // final hosted image URL
      } else {
        final error = await response.stream.bytesToString();
        print(" Cloudinary upload failed: ${response.statusCode} | $error");
        return null;
      }
    } catch (e) {
      print("⚠ Cloudinary upload error: $e");
      return null;
    }
  }
  Future<void> deleteImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);

      // Extract full public_id (may include folders)
      String publicId = uri.pathSegments
          .skipWhile((segment) => segment != "upload")
          .skip(1)
          .join('/')
          .split('.')
          .first;

      final cloudName = "<your_cloud_name>";
      final apiKey = "<your_api_key>";
      final apiSecret = "<your_api_secret>";

      final authHeader =
          'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}';

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
      throw Exception("Error deleting image: $e");
    }
  }

}
