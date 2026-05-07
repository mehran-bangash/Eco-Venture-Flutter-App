import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:async';

class CloudinaryService {
  final String cloudName = "dc6suw4tu";
  final String apiKey = "512897754688659";
  final String apiSecret = "uBlrQa-nXVs3Flq-QOVHyR60bCA";

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

  // FIXED: Logic to extract ONLY the public_id, correctly stripping transformations and versions
  String? _getPublicIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final uploadIndex = segments.indexOf('upload');
      if (uploadIndex == -1) return null;

      final relevantSegments = segments.sublist(uploadIndex + 1);

      // Filter out transformation segments (contain comma) and version segments (start with 'v' + digits)
      final publicIdSegments = relevantSegments.where((segment) {
        final isTransformation = segment.contains(',');
        final isVersion = RegExp(r'^v\d+$').hasMatch(segment);
        return !isTransformation && !isVersion;
      }).toList();

      if (publicIdSegments.isEmpty) return null;

      final fullName = publicIdSegments.join('/');
      return fullName.split('.').first; // Removes extension (.mp4, .jpg, etc)
    } catch (e) {
      return null;
    }
  }

  // FIXED: Using Admin API with DELETE method for reliable cloud deletion
  Future<void> deleteFile(String? fileUrl, {bool isVideo = false}) async {
    if (fileUrl == null ||
        fileUrl.isEmpty ||
        !fileUrl.contains("cloudinary.com"))
      return;

    try {
      final publicId = _getPublicIdFromUrl(fileUrl);
      if (publicId == null) return;

      final authHeader =
          'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}';
      final resourceType = isVideo ? "video" : "image";

      // Admin API uses DELETE request for resources
      final response = await http.delete(
        Uri.parse(
          "https://api.cloudinary.com/v1_1/$cloudName/resources/$resourceType/upload?public_ids[]=$publicId",
        ),
        headers: {"Authorization": authHeader},
      );

      if (response.statusCode == 200) {
        print("Successfully deleted from Cloudinary: $publicId");
      } else {
        print("Cloudinary delete failed: ${response.body}");
      }
    } catch (e) {
      print("Error deleting file: $e");
    }
  }

  Future<void> deleteImage(String? imageUrl) async =>
      await deleteFile(imageUrl, isVideo: false);

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

  Future<dynamic> _upload(
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
        "https://api.cloudinary.com/v1_1/$cloudName/upload",
      );

      final request = http.MultipartRequest("POST", uri)
        ..fields['upload_preset'] = preset
        ..fields['resource_type'] = resourceType
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            contentType: MediaType(fileType[0], fileType[1]),
          ),
        );

      final response = await request.send().timeout(const Duration(minutes: 5));
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData.body);
        final url = _optimizeUrl(jsonResponse['secure_url']);
        if (isVideo) {
          double dur = (jsonResponse['duration'] ?? 0).toDouble();
          int m = (dur / 60).floor();
          int s = (dur % 60).round();
          return {
            "url": url,
            "duration":
                "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}",
          };
        }
        return url;
      }
      throw json.decode(responseData.body)['error']?['message'] ??
          "Error ${response.statusCode}";
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String?> uploadTeacherQuizImage(File imageFile) async =>
      await _upload(imageFile, teacherQuizPreset) as String?;
  Future<String?> uploadTeacherStemImage(File imageFile) async =>
      await _upload(imageFile, teacherStemPreset) as String?;
  Future<dynamic> uploadTeacherMultimediaFile(
    File file, {
    bool isVideo = false,
  }) async => await _upload(file, teacherMultimediaPreset, isVideo: isVideo);
  Future<String?> uploadTeacherQrImage(File imageFile) async =>
      await _upload(imageFile, teacherQrHuntPreset) as String?;
  Future<String?> uploadReportScreenshot(File file) async =>
      await _upload(file, reportPreset) as String?;
  Future<String?> uploadChildNaturePhotoImage(File imageFile) async =>
      await _upload(imageFile, childNaturePhotoPreset) as String?;
}
