import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'job.freezed.dart';
part 'job.g.dart';

@freezed
class Job with _$Job {
  const factory Job({
    required String id,
    required String title,
    required String company,
    required String category,
    required String locationCity,
    required String locationCountry,
    int? salaryMin,
    int? salaryMax,
    required String type,
    String? logoUrl,
    required String description,
    required List<String> requirements,
    required List<String> skills,
    required DateTime createdAt,
    required String employerId,
    @Default(true) bool isActive,
    DateTime? updatedAt,
  }) = _Job;

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

  /// Create Job from Firestore DocumentSnapshot
  factory Job.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Job.fromJson({
      'id': doc.id,
      ...data,
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
      'updatedAt':
          (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }
}

extension JobExtension on Job {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Firestore document ID is separate

    // Convert DateTime to Timestamp
    if (json['createdAt'] != null) {
      json['createdAt'] = Timestamp.fromDate(DateTime.parse(json['createdAt']));
    }
    if (json['updatedAt'] != null) {
      json['updatedAt'] = Timestamp.fromDate(DateTime.parse(json['updatedAt']));
    }

    return json;
  }
}
