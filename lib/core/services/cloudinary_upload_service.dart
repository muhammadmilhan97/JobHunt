import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

/// Upload result model
class UploadResult {
  final String publicId;
  final String secureUrl;
  final String originalFilename;
  final int bytes;
  final String format;
  final String resourceType;

  UploadResult({
    required this.publicId,
    required this.secureUrl,
    required this.originalFilename,
    required this.bytes,
    required this.format,
    required this.resourceType,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      publicId: json['public_id'] ?? '',
      secureUrl: json['secure_url'] ?? '',
      originalFilename: json['original_filename'] ?? '',
      bytes: json['bytes'] ?? 0,
      format: json['format'] ?? '',
      resourceType: json['resource_type'] ?? '',
    );
  }
}

/// Upload progress callback
typedef ProgressCallback = void Function(double progress);

/// Service for handling signed Cloudinary uploads
class CloudinaryUploadService {
  static const String _functionBaseUrl =
      'https://us-central1-jobhunt-dev-7b0ae.cloudfunctions.net';

  /// Get signed upload parameters from Cloud Function
  static Future<Map<String, dynamic>> _getSignedUploadParams({
    required String folder,
    required String preset,
    String? publicId,
  }) async {
    try {
      // Get current user's ID token
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await user.getIdToken();

      // Call Cloud Function
      final response = await http.post(
        Uri.parse('$_functionBaseUrl/signCloudinaryUpload'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'folder': folder,
          'preset': preset,
          if (publicId != null) 'public_id': publicId,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to get upload signature: ${errorData['error']}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error getting signed upload params: $e');
      rethrow;
    }
  }

  /// Upload CV file to Cloudinary
  static Future<UploadResult> uploadCV({
    required File file,
    String? customPublicId,
    ProgressCallback? onProgress,
  }) async {
    return _uploadFile(
      file: file,
      folder: 'jobhunt-dev/cv',
      preset: 'jobhunt_cv_signed',
      customPublicId: customPublicId,
      onProgress: onProgress,
    );
  }

  /// Upload profile image to Cloudinary
  static Future<UploadResult> uploadProfileImage({
    required File file,
    String? customPublicId,
    ProgressCallback? onProgress,
  }) async {
    return _uploadFile(
      file: file,
      folder: 'jobhunt-dev/profiles',
      preset: 'jobhunt_profile_signed',
      customPublicId: customPublicId,
      onProgress: onProgress,
    );
  }

  /// Upload company logo to Cloudinary
  static Future<UploadResult> uploadCompanyLogo({
    required File file,
    String? customPublicId,
    ProgressCallback? onProgress,
  }) async {
    return _uploadFile(
      file: file,
      folder: 'jobhunt-dev/logos',
      preset: 'jobhunt_logo_signed',
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

      // Get signed upload parameters
      final signedParams = await _getSignedUploadParams(
        folder: folder,
        preset: preset,
        publicId: publicId,
      );

      // Prepare multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(signedParams['upload_url']),
      );

      // Add form fields
      request.fields.addAll({
        'api_key': signedParams['api_key'],
        'timestamp': signedParams['timestamp'].toString(),
        'signature': signedParams['signature'],
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
        contentType: http_parser.MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);

      // Send request with progress tracking
      final streamedResponse = await request.send();

      // Track upload progress (approximation)
      if (onProgress != null) {
        // This is a simplified progress tracking
        // For real progress, you'd need to implement a custom HTTP client
        onProgress(0.5); // Assume 50% when request is sent
      }

      // Get response
      final response = await http.Response.fromStream(streamedResponse);

      if (onProgress != null) {
        onProgress(1.0); // Complete
      }

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Upload failed: ${errorData['error']?['message'] ?? 'Unknown error'}');
      }

      final responseData = jsonDecode(response.body);
      return UploadResult.fromJson(responseData);
    } catch (e) {
      debugPrint('Error uploading file: $e');
      if (onProgress != null) {
        onProgress(0.0); // Reset progress on error
      }
      rethrow;
    }
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
