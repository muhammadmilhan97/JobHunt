// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApplicationImpl _$$ApplicationImplFromJson(Map<String, dynamic> json) =>
    _$ApplicationImpl(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      jobSeekerId: json['jobSeekerId'] as String,
      employerId: json['employerId'] as String,
      status: json['status'] as String,
      cvUrl: json['cvUrl'] as String,
      jobTitle: json['jobTitle'] as String?,
      employerName: json['employerName'] as String?,
      notes: json['notes'] as String?,
      coverLetter: json['coverLetter'] as String?,
      expectedSalary: (json['expectedSalary'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ApplicationImplToJson(_$ApplicationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobId': instance.jobId,
      'jobSeekerId': instance.jobSeekerId,
      'employerId': instance.employerId,
      'status': instance.status,
      'cvUrl': instance.cvUrl,
      'jobTitle': instance.jobTitle,
      'employerName': instance.employerName,
      'notes': instance.notes,
      'coverLetter': instance.coverLetter,
      'expectedSalary': instance.expectedSalary,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
