import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Simple file storage service for testing uploads
class SimpleFileStorage {
  /// Store a file locally and return a file URL
  static Future<String> storeFile(File file, String folder) async {
    try {
      // Get application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final storageDir =
          Directory(path.join(directory.path, 'uploads', folder));

      // Create directory if it doesn't exist
      if (!await storageDir.exists()) {
        await storageDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = path.basename(file.path);
      final nameWithoutExt = path.basenameWithoutExtension(fileName);
      final extension = path.extension(fileName);
      final uniqueFileName = '${nameWithoutExt}_$timestamp$extension';

      // Copy file to storage directory
      final storedFile = File(path.join(storageDir.path, uniqueFileName));
      await file.copy(storedFile.path);

      // Return file URL (for local testing)
      return 'file://${storedFile.path}';
    } catch (e) {
      throw Exception('Failed to store file: $e');
    }
  }

  /// Get file size in bytes
  static Future<int> getFileSize(File file) async {
    return await file.length();
  }

  /// Check if file exists
  static Future<bool> fileExists(String filePath) async {
    return await File(filePath).exists();
  }
}
