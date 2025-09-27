import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

/// Upload progress callback
typedef ProgressCallback = void Function(double progress);

/// Upload result from Cloudinary
class UploadResult {
  final String secureUrl;
  final String publicId;
  final String format;
  final int bytes;

  UploadResult({
    required this.secureUrl,
    required this.publicId,
    required this.format,
    required this.bytes,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      secureUrl: json['secure_url'] ?? '',
      publicId: json['public_id'] ?? '',
      format: json['format'] ?? '',
      bytes: json['bytes'] ?? 0,
    );
  }
}

/// Service for handling Cloudinary uploads
class CloudinaryUploadService {
  // Cloudinary configuration
  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/dd09znqy6/upload';

  // Upload presets (these need to be configured in your Cloudinary dashboard)
  static const String _imagePreset = 'jobhunt_images';
  static const String _documentPreset = 'jobhunt_documents';

  /// Upload a profile image
  static Future<UploadResult> uploadProfileImage({
    required File file,
    String? customPublicId,
    ProgressCallback? onProgress,
  }) async {
    return await _uploadFile(
      file: file,
      folder: 'jobhunt-dev/profile_images',
      preset: _imagePreset,
      customPublicId: customPublicId,
      onProgress: onProgress,
    );
  }

  /// Upload a CV document
  static Future<UploadResult> uploadCV({
    required File file,
    String? customPublicId,
    ProgressCallback? onProgress,
  }) async {
    return await _uploadFile(
      file: file,
      folder: 'jobhunt-dev/cv_documents',
      preset: _documentPreset,
      customPublicId: customPublicId,
      onProgress: onProgress,
    );
  }

  /// Upload a company logo
  static Future<UploadResult> uploadCompanyLogo({
    required File file,
    String? customPublicId,
    ProgressCallback? onProgress,
  }) async {
    return await _uploadFile(
      file: file,
      folder: 'jobhunt-dev/company_logos',
      preset: _imagePreset,
      customPublicId: customPublicId,
      onProgress: onProgress,
    );
  }

  /// Generic file upload method
  static Future<UploadResult> _uploadFile({
    required File file,
    required String folder,
    required String preset,
    String? customPublicId,
    ProgressCallback? onProgress,
  }) async {
    try {
      // Validate file
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        // 10MB limit
        throw Exception('File size exceeds 10MB limit');
      }

      // Get file info
      final fileName = path.basename(file.path);
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      // Validate file type for CV uploads
      if (folder.contains('cv')) {
        const allowedTypes = [
          'application/pdf',
          'application/msword',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        ];

        if (!allowedTypes.contains(mimeType)) {
          throw Exception(
              'Invalid file type. Only PDF, DOC, and DOCX files are allowed.');
        }
      }

      // Generate public_id if not provided
      final publicId = customPublicId ?? _generatePublicId(fileName);

      debugPrint('Uploading to Cloudinary:');
      debugPrint('  URL: $_uploadUrl');
      debugPrint('  Preset: $preset');
      debugPrint('  Folder: $folder');
      debugPrint('  Public ID: $publicId');
      debugPrint('  File: ${file.path}');

      // Prepare multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

      // Add form fields for unsigned upload
      request.fields.addAll({
        'upload_preset': preset,
        'folder': folder,
        'public_id': publicId,
      });

      // Add file
      final fileStream = file.openRead();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileSize,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);

      // Send request with progress tracking
      final streamedResponse = await request.send();

      // Track upload progress (approximation)
      if (onProgress != null) {
        onProgress(0.5); // Assume 50% when request is sent
      }

      // Get response
      final response = await http.Response.fromStream(streamedResponse);

      if (onProgress != null) {
        onProgress(1.0); // Complete
      }

      debugPrint('Cloudinary upload response status: ${response.statusCode}');
      debugPrint('Cloudinary upload response body: ${response.body}');

      if (response.statusCode != 200) {
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage =
              errorData['error']?['message'] ?? 'Unknown error';

          // If preset doesn't exist, try without preset
          if (errorMessage.contains('preset') ||
              errorMessage.contains('Invalid preset')) {
            debugPrint('Preset failed, trying without preset...');
            return await _uploadWithoutPreset(
                file, folder, publicId, onProgress);
          }

          throw Exception('Upload failed: $errorMessage');
        } catch (e) {
          throw Exception(
              'Upload failed with status ${response.statusCode}: ${response.body}');
        }
      }

      final responseData = jsonDecode(response.body);
      debugPrint('Upload successful: ${responseData['secure_url']}');
      return UploadResult.fromJson(responseData);
    } catch (e) {
      debugPrint('Error uploading file: $e');
      if (onProgress != null) {
        onProgress(0.0); // Reset progress on error
      }
      rethrow;
    }
  }

  /// Fallback upload without preset (for testing)
  static Future<UploadResult> _uploadWithoutPreset(
    File file,
    String folder,
    String publicId,
    ProgressCallback? onProgress,
  ) async {
    debugPrint('Attempting upload without preset...');

    final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

    // Minimal fields for unsigned upload
    request.fields.addAll({
      'folder': folder,
      'public_id': publicId,
    });

    final fileStream = file.openRead();
    final fileSize = await file.length();
    final fileName = path.basename(file.path);
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

    final multipartFile = http.MultipartFile(
      'file',
      fileStream,
      fileSize,
      filename: fileName,
      contentType: MediaType.parse(mimeType),
    );
    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint(
        'Fallback upload response: ${response.statusCode} - ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Fallback upload failed: ${response.body}');
    }

    final responseData = jsonDecode(response.body);
    return UploadResult.fromJson(responseData);
  }

  /// Generate a unique public_id for the file
  static String _generatePublicId(String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nameWithoutExt = path.basenameWithoutExtension(fileName);
    final cleanName = nameWithoutExt.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return '${cleanName}_$timestamp';
  }

  /// Validate file type and size
  static bool isValidCVFile(File file) {
    final mimeType = lookupMimeType(file.path);
    const allowedTypes = [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    ];

    return allowedTypes.contains(mimeType);
  }

  /// Get human-readable file size
  static String getFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
