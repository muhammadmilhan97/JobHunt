// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      role: json['role'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      cnic: json['cnic'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      address: json['address'] as String?,
      experienceYears: (json['experienceYears'] as num?)?.toInt(),
      skills:
          (json['skills'] as List<dynamic>).map((e) => e as String).toList(),
      expectedSalary: (json['expectedSalary'] as num?)?.toInt(),
      companyName: json['companyName'] as String?,
      website: json['website'] as String?,
      about: json['about'] as String?,
      cvUrl: json['cvUrl'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      companyLogoUrl: json['companyLogoUrl'] as String?,
      preferredCategories: (json['preferredCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      preferredCities: (json['preferredCities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      minSalaryPreferred: (json['minSalaryPreferred'] as num?)?.toInt(),
      approvalStatus: json['approvalStatus'] as String? ?? 'pending',
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      approvedBy: json['approvedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      weeklyDigest: json['weeklyDigest'] as bool? ?? true,
      instantAlerts: json['instantAlerts'] as bool? ?? true,
      jobPostingNotifications: json['jobPostingNotifications'] as bool? ?? true,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': instance.role,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'cnic': instance.cnic,
      'city': instance.city,
      'country': instance.country,
      'address': instance.address,
      'experienceYears': instance.experienceYears,
      'skills': instance.skills,
      'expectedSalary': instance.expectedSalary,
      'companyName': instance.companyName,
      'website': instance.website,
      'about': instance.about,
      'cvUrl': instance.cvUrl,
      'profilePhotoUrl': instance.profilePhotoUrl,
      'companyLogoUrl': instance.companyLogoUrl,
      'preferredCategories': instance.preferredCategories,
      'preferredCities': instance.preferredCities,
      'minSalaryPreferred': instance.minSalaryPreferred,
      'approvalStatus': instance.approvalStatus,
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'approvedBy': instance.approvedBy,
      'rejectionReason': instance.rejectionReason,
      'emailNotifications': instance.emailNotifications,
      'weeklyDigest': instance.weeklyDigest,
      'instantAlerts': instance.instantAlerts,
      'jobPostingNotifications': instance.jobPostingNotifications,
    };
