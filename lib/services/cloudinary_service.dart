import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:async';

class CloudinaryService {
  final String cloudName = "dc6suw4tu";

  final String defaultPreset = "ecoventure";

  final String studentTaskPreset = "Eco_stem_challenges";
  final String teacherQuizPreset = "eco_teacher_quiz";
  final String teacherStemPreset = "eco_teacher_stem_challenge";
  final String teacherMultimediaPreset = "eco_teacher_multimedia_content";
  final String teacherQrHuntPreset = "eco_teacher_treasure_hunt";
  final String reportPreset = "eco_child_reports";
  final String childNaturePhotoPreset = "eco_child_nature_photo_journal";

  // --- NEW: Optimization Helper ---
  /// Logic: Injects auto-optimization parameters into the Cloudinary URL.
  /// q_auto: compresses the file size automatically.
  /// f_auto: chooses the best format (like WebP) for the device.
  String? _optimizeUrl(String? url) {
    if (url == null || !url.contains("cloudinary.com")) return url;
    return url.replaceAll("/upload/", "/upload/q_auto,f_auto/");
  }

  /// Core: Upload image to Cloudinary
  Future<String?> uploadImage(File imageFile, {String? preset}) async {
    try {
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
        // Optimization applied here
        return _optimizeUrl(jsonResponse['secure_url']);
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

  Future<String?> uploadTaskImage(File imageFile) async {
    return await uploadImage(imageFile, preset: studentTaskPreset);
  }

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

  Future<void> deleteImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
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
        headers: {"Authorization": authHeader},
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to delete image: ${response.body}");
      }
    } catch (e) {
      print("Error deleting image: $e");
    }
  }

  Future<String?> _upload(File file, String preset, {bool isVideo = false}) async {
    try {
      final mimeType = lookupMimeType(file.path) ?? (isVideo ? 'video/mp4' : 'image/jpeg');
      final fileType = mimeType.split('/');
      final resourceType = isVideo ? 'video' : 'image';

      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload");

      final request = http.MultipartRequest("POST", uri)
        ..fields['upload_preset'] = preset
        ..files.add(await http.MultipartFile.fromPath(
            'file', file.path,
            contentType: MediaType(fileType[0], fileType[1])));

      final response = await request.send().timeout(const Duration(seconds: 30));
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        // Optimization applied here (Works for both video and image)
        return _optimizeUrl(jsonResponse['secure_url']);
      } else {
        throw "Server Error: Cloudinary rejected the file. Code: ${response.statusCode}";
      }
    } on SocketException {
      throw "Network Error: Cannot reach server. Please try Mobile Data or check Wi-Fi.";
    } on TimeoutException {
      throw "Timeout: Internet is too slow. Upload took too long.";
    } catch (e) {
      throw "Upload Failed: $e";
    }
  }

  Future<String?> uploadTeacherQuizImage(File imageFile) async {
    return await _upload(imageFile, teacherQuizPreset);
  }

  Future<String?> uploadTeacherStemImage(File imageFile) async {
    return await _upload(imageFile, teacherStemPreset);
  }

  Future<String?> uploadTeacherMultimediaFile(File file, {bool isVideo = false}) async {
    return await _upload(file, teacherMultimediaPreset, isVideo: isVideo);
  }

  Future<String?> uploadTeacherQrImage(File imageFile) async {
    return await _upload(imageFile, teacherQrHuntPreset);
  }

  Future<String?> uploadReportScreenshot(File file) async {
    return await _upload(file, reportPreset);
  }

  Future<String?> uploadChildNaturePhotoImage(File imageFile) async {
    return await _upload(imageFile, childNaturePhotoPreset);
  }
}