import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String role,
    required String name,
    required String email,
    String? phone,
    String? cnic,
    String? city,
    String? country,
    String? address,
    int? experienceYears,
    required List<String> skills,
    int? expectedSalary,
    String? companyName,
    String? website,
    String? about,
    String? cvUrl,
    String? profilePhotoUrl,
    String? companyLogoUrl,
    @Default(<String>[]) List<String> preferredCategories,
    @Default(<String>[]) List<String> preferredCities,
    int? minSalaryPreferred,

    // Admin approval status
    @Default('pending') String approvalStatus, // pending, approved, rejected
    DateTime? approvedAt,
    String? approvedBy,
    String? rejectionReason,

    // Email notification preferences
    @Default(true) bool emailNotifications,
    @Default(true) bool weeklyDigest,
    @Default(true) bool instantAlerts,
    @Default(true) bool jobPostingNotifications, // for employers
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  factory UserProfile.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserProfile(
      id: doc.id,
      role: data['role'] ?? 'job_seeker',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      cnic: data['cnic'],
      city: data['city'],
      country: data['country'],
      address: data['address'],
      experienceYears: data['experienceYears']?.toInt(),
      skills: List<String>.from(data['skills'] ?? []),
      expectedSalary: data['expectedSalary']?.toInt(),
      companyName: data['companyName'],
      website: data['website'],
      about: data['about'],
      cvUrl: data['cvUrl'],
      profilePhotoUrl: data['profilePhotoUrl'],
      companyLogoUrl: data['companyLogoUrl'],
      preferredCategories: List<String>.from(data['preferredCategories'] ?? []),
      preferredCities: List<String>.from(data['preferredCities'] ?? []),
      minSalaryPreferred: data['minSalaryPreferred']?.toInt(),

      // Admin approval fields
      approvalStatus: data['approvalStatus'] ?? 'pending',
      approvedAt: data['approvedAt'] != null
          ? (data['approvedAt'] as Timestamp).toDate()
          : null,
      approvedBy: data['approvedBy'],
      rejectionReason: data['rejectionReason'],

      // Email notification preferences
      emailNotifications: data['emailNotifications'] ?? true,
      weeklyDigest: data['weeklyDigest'] ?? true,
      instantAlerts: data['instantAlerts'] ?? true,
      jobPostingNotifications: data['jobPostingNotifications'] ?? true,
    );
  }
}
