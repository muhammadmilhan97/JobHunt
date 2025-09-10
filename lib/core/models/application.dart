import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'application.freezed.dart';
part 'application.g.dart';

@freezed
class Application with _$Application {
  const factory Application({
    required String id,
    required String jobId,
    required String jobSeekerId,
    required String employerId,
    required String status,
    required String cvUrl,
    String? jobTitle,
    String? employerName,
    String? notes,
    String? coverLetter,
    int? expectedSalary,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Application;

  factory Application.fromJson(Map<String, dynamic> json) =>
      _$ApplicationFromJson(json);

  factory Application.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return Application(
      id: doc.id,
      jobId: data['jobId'] ?? '',
      jobSeekerId: data['jobSeekerId'] ?? '',
      employerId: data['employerId'] ?? '',
      status: data['status'] ?? 'pending',
      cvUrl: data['cvUrl'] ?? '',
      jobTitle: data['jobTitle'],
      employerName: data['employerName'],
      notes: data['notes'],
      coverLetter: data['coverLetter'],
      expectedSalary: data['expectedSalary']?.toInt(),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}

extension ApplicationExtension on Application {
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
