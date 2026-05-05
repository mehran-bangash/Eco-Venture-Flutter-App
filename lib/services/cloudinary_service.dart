import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:async';

class CloudinaryService {
  final String cloudName = "dc6suw4tu";
  // IMPORTANT: Fill these for deletion to work
  final String apiKey = "512897754688659";// remove later from here
  final String apiSecret = "uBlrQa-nXVs3Flq-QOVHyR60bCA";// remove later from here

  final String defaultPreset = "ecoventure";
  final String studentTaskPreset = "Eco_stem_challenges";
  final String teacherQuizPreset = "eco_teacher_quiz";
  final String teacherStemPreset = "eco_teacher_stem_challenge";
  final String teacherMultimediaPreset = "eco_teacher_multimedia_content";
  final String teacherQrHuntPreset = "eco_teacher_treasure_hunt";
  final String reportPreset = "eco_child_reports";
  final String childNaturePhotoPreset = "eco_child_nature_photo_journal";

  String? _optimizeUrl(String? url) {
    if (url == null || !url.contains("cloudinary.com")) return url;
    return url.replaceAll("/upload/", "/upload/q_auto,f_auto/");
  }

  /// Extracts Public ID from Cloudinary URL for deletion
  String? _getPublicIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1) return null;

      // Extract parts after 'upload/v1234567/' or 'upload/'
      final relevantSegments = pathSegments.sublist(uploadIndex + 1);
      if (relevantSegments.first.startsWith('v') &&
          relevantSegments.first.length > 5) {
        relevantSegments.removeAt(0);
      }

      final fullName = relevantSegments.join('/');
      return fullName.split('.').first;
    } catch (e) {
      return null;
    }
  }

  /// NEW: Robust Delete Logic
  Future<void> deleteImage(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return;

    try {
      final publicId = _getPublicIdFromUrl(imageUrl);
      if (publicId == null) return;

      final authHeader =
          'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}';

      // Determine if it's video or image based on URL
      final resourceType = imageUrl.contains("/video/") ? "video" : "image";

      final response = await http.post(
        Uri.parse(
          "https://api.cloudinary.com/v1_1/$cloudName/$resourceType/destroy",
        ),
        body: {'public_id': publicId, 'api_key': apiKey},
        headers: {"Authorization": authHeader},
      );

      if (response.statusCode == 200) {
        print("Successfully deleted from Cloudinary: $publicId");
      } else {
        print("Cloudinary delete failed: ${response.body}");
      }
    } catch (e) {
      print("Error deleting image: $e");
    }
  }

  Future<String?> uploadImage(File imageFile, {String? preset}) async {
    try {
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final fileType = mimeType.split('/');
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/upload",
      );

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
        return _optimizeUrl(jsonResponse['secure_url']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // --- PRESET WRAPPERS (No changes to logic) ---
  Future<String?> uploadTaskImage(File imageFile) async =>
      await uploadImage(imageFile, preset: studentTaskPreset);

  Future<List<String>> uploadMultipleTaskImages(List<File> images) async {
    List<String> uploadedUrls = [];
    for (var image in images) {
      String? url = await uploadTaskImage(image);
      if (url != null) uploadedUrls.add(url);
    }
    return uploadedUrls;
  }

  Future<String?> _upload(
    File file,
    String preset, {
    bool isVideo = false,
  }) async {
    try {
      final mimeType =
          lookupMimeType(file.path) ?? (isVideo ? 'video/mp4' : 'image/jpeg');
      final fileType = mimeType.split('/');
      final resourceType = isVideo ? 'video' : 'image';
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload",
      );

      final request = http.MultipartRequest("POST", uri)
        ..fields['upload_preset'] = preset
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            contentType: MediaType(fileType[0], fileType[1]),
          ),
        );

      final response = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        return _optimizeUrl(jsonResponse['secure_url']);
      }
      throw "Server Error: ${response.statusCode}";
    } catch (e) {
      throw "Upload Failed: $e";
    }
  }

  Future<String?> uploadTeacherQuizImage(File imageFile) async =>
      await _upload(imageFile, teacherQuizPreset);
  Future<String?> uploadTeacherStemImage(File imageFile) async =>
      await _upload(imageFile, teacherStemPreset);
  Future<String?> uploadTeacherMultimediaFile(
    File file, {
    bool isVideo = false,
  }) async => await _upload(file, teacherMultimediaPreset, isVideo: isVideo);
  Future<String?> uploadTeacherQrImage(File imageFile) async =>
      await _upload(imageFile, teacherQrHuntPreset);
  Future<String?> uploadReportScreenshot(File file) async =>
      await _upload(file, reportPreset);
  Future<String?> uploadChildNaturePhotoImage(File imageFile) async =>
      await _upload(imageFile, childNaturePhotoPreset);
}
