import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloudinary/cloudinary.dart';
import '../config/cloudinary_config.dart';

final imageServiceProvider = Provider<ImageService>((ref) => ImageService());

class ImageService {
  /// Pick image from gallery or camera
  Future<File?> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          return File(file.path!);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Upload profile image to Cloudinary
  /// Returns the public URL of the uploaded image
  Future<String> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      final response = await CloudinaryConfig.uploadImage(
        filePath: imageFile.path,
        folder: 'profiles',
        publicId: 'profile_$userId',
      );

      if (response.isSuccessful) {
        return response.secureUrl ?? response.url ?? '';
      } else {
        throw Exception('Failed to upload image: ${response.error}');
      }
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  /// Upload company logo to Cloudinary
  /// Returns the public URL of the uploaded image
  Future<String> uploadCompanyLogo({
    required File imageFile,
    required String companyId,
  }) async {
    try {
      final response = await CloudinaryConfig.uploadImage(
        filePath: imageFile.path,
        folder: 'company_logos',
        publicId: 'logo_$companyId',
      );

      if (response.isSuccessful) {
        return response.secureUrl ?? response.url ?? '';
      } else {
        throw Exception('Failed to upload logo: ${response.error}');
      }
    } catch (e) {
      throw Exception('Logo upload failed: $e');
    }
  }

  /// Upload job-related image to Cloudinary
  /// Returns the public URL of the uploaded image
  Future<String> uploadJobImage({
    required File imageFile,
    required String jobId,
  }) async {
    try {
      final response = await CloudinaryConfig.uploadImage(
        filePath: imageFile.path,
        folder: 'job_images',
        publicId: 'job_$jobId',
      );

      if (response.isSuccessful) {
        return response.secureUrl ?? response.url ?? '';
      } else {
        throw Exception('Failed to upload job image: ${response.error}');
      }
    } catch (e) {
      throw Exception('Job image upload failed: $e');
    }
  }

  /// Upload resume/CV to Cloudinary
  /// Returns the public URL of the uploaded file
  Future<String> uploadResume({
    required File resumeFile,
    required String userId,
  }) async {
    try {
      final response = await CloudinaryConfig.instance.upload(
        file: resumeFile.path,
        folder: 'resumes',
        publicId: 'resume_$userId',
        resourceType: CloudinaryResourceType.raw, // For PDF/DOC files
      );

      if (response.isSuccessful) {
        return response.secureUrl ?? response.url ?? '';
      } else {
        throw Exception('Failed to upload resume: ${response.error}');
      }
    } catch (e) {
      throw Exception('Resume upload failed: $e');
    }
  }

  /// Get optimized image URL for display
  String getOptimizedImageUrl({
    required String publicId,
    int? width,
    int? height,
    String quality = 'auto',
  }) {
    return CloudinaryConfig.getOptimizedImageUrl(
      publicId: publicId,
      width: width,
      height: height,
      quality: quality,
    );
  }

  /// Delete image from Cloudinary
  Future<bool> deleteImage(String publicId) async {
    try {
      final response = await CloudinaryConfig.deleteImage(publicId);
      return response.isSuccessful;
    } catch (e) {
      return false;
    }
  }
}
