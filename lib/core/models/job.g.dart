// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$JobImpl _$$JobImplFromJson(Map<String, dynamic> json) => _$JobImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      company: json['company'] as String,
      category: json['category'] as String,
      locationCity: json['locationCity'] as String,
      locationCountry: json['locationCountry'] as String,
      salaryMin: (json['salaryMin'] as num?)?.toInt(),
      salaryMax: (json['salaryMax'] as num?)?.toInt(),
      type: json['type'] as String,
      logoUrl: json['logoUrl'] as String?,
      description: json['description'] as String,
      requirements: (json['requirements'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      skills:
          (json['skills'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      employerId: json['employerId'] as String,
      isActive: json['isActive'] as bool? ?? true,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$JobImplToJson(_$JobImpl instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'company': instance.company,
      'category': instance.category,
      'locationCity': instance.locationCity,
      'locationCountry': instance.locationCountry,
      'salaryMin': instance.salaryMin,
      'salaryMax': instance.salaryMax,
      'type': instance.type,
      'logoUrl': instance.logoUrl,
      'description': instance.description,
      'requirements': instance.requirements,
      'skills': instance.skills,
      'createdAt': instance.createdAt.toIso8601String(),
      'employerId': instance.employerId,
      'isActive': instance.isActive,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
