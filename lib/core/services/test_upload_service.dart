import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Simple test upload service that stores files locally
class TestUploadService {
  /// Upload a profile image (stores locally)
  static Future<String> uploadProfileImage({
    required File file,
    String? customPublicId,
    Function(double)? onProgress,
  }) async {
    return await _storeFileLocally(
        file, 'profile_images', customPublicId, onProgress);
  }

  /// Upload a CV document (stores locally)
  static Future<String> uploadCV({
    required File file,
    String? customPublicId,
    Function(double)? onProgress,
  }) async {
    return await _storeFileLocally(
        file, 'cv_documents', customPublicId, onProgress);
  }

  /// Store file locally and return file URL
  static Future<String> _storeFileLocally(
    File file,
    String folder,
    String? customPublicId,
    Function(double)? onProgress,
  ) async {
    try {
      debugPrint('Storing file locally: ${file.path}');

      if (onProgress != null) onProgress(0.1);

      // Get application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final storageDir =
          Directory(path.join(directory.path, 'uploads', folder));

      // Create directory if it doesn't exist
      if (!await storageDir.exists()) {
        await storageDir.create(recursive: true);
      }

      if (onProgress != null) onProgress(0.3);

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = path.basename(file.path);
      final nameWithoutExt = path.basenameWithoutExtension(fileName);
      final extension = path.extension(fileName);
      final uniqueFileName =
          customPublicId ?? '${nameWithoutExt}_$timestamp$extension';

      if (onProgress != null) onProgress(0.5);

      // Copy file to storage directory
      final storedFile = File(path.join(storageDir.path, uniqueFileName));
      await file.copy(storedFile.path);

      if (onProgress != null) onProgress(1.0);

      debugPrint('File stored successfully: ${storedFile.path}');

      // Return file URL (for local testing)
      return 'file://${storedFile.path}';
    } catch (e) {
      debugPrint('Error storing file locally: $e');
      throw Exception('Failed to store file: $e');
    }
  }
}
