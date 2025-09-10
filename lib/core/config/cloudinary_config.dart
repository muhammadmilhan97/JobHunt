import 'package:cloudinary/cloudinary.dart';

class CloudinaryConfig {
  static const String _cloudName = 'dd09znqy6';
  static const String _apiKey = '796983513455731';
  static const String _apiSecret = 'KvAqoHxHzxnFIRz3BGBGYEE76ik';

  static final Cloudinary _instance = Cloudinary.signedConfig(
    apiKey: _apiKey,
    apiSecret: _apiSecret,
    cloudName: _cloudName,
  );

  static Cloudinary get instance => _instance;

  /// Upload image to Cloudinary
  /// [filePath] - Local file path
  /// [folder] - Optional folder name (dynamic folders mode)
  /// [publicId] - Optional custom public ID
  static Future<CloudinaryResponse> uploadImage({
    required String filePath,
    String? folder,
    String? publicId,
  }) async {
    try {
      final response = await _instance.upload(
        file: filePath,
        folder: folder,
        publicId: publicId,
        resourceType: CloudinaryResourceType.image,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Generate optimized image URL
  /// [publicId] - Cloudinary public ID
  /// [width] - Optional width
  /// [height] - Optional height
  /// [quality] - Image quality (auto, best, good, eco, low)
  static String getOptimizedImageUrl({
    required String publicId,
    int? width,
    int? height,
    String quality = 'auto',
  }) {
    // Build URL manually for now - the Cloudinary package API may have changed
    String baseUrl = 'https://res.cloudinary.com/$_cloudName/image/upload/';

    List<String> transformations = [];
    transformations.add('q_$quality');
    transformations.add('f_auto');

    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');

    String transformationString = transformations.join(',');
    return '$baseUrl$transformationString/$publicId';
  }

  /// Delete image from Cloudinary
  /// [publicId] - Cloudinary public ID
  static Future<CloudinaryResponse> deleteImage(String publicId) async {
    try {
      final response = await _instance.destroy(publicId);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
