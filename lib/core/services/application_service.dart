import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Service for handling job application operations
class ApplicationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create a new job application
  static Future<String> createApplication({
    required String jobId,
    required String employerId,
    required String cvUrl,
    String? coverLetter,
    int? expectedSalary,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final jobSeekerId = user.uid;

      // Check if user already applied to this job
      final existingApplications = await _firestore
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .where('jobSeekerId', isEqualTo: jobSeekerId)
          .get();

      if (existingApplications.docs.isNotEmpty) {
        throw Exception('You have already applied to this job');
      }

      // Validate CV URL
      if (cvUrl.isEmpty) {
        throw Exception('CV URL is required');
      }

      // Fetch job details to populate jobTitle and employerName
      final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
      if (!jobDoc.exists) {
        throw Exception('Job not found');
      }

      final jobData = jobDoc.data()!;
      final jobTitle = jobData['title'] as String?;
      final employerName = jobData['company'] as String?;

      // Create application document
      final applicationData = {
        'jobId': jobId,
        'employerId': employerId,
        'jobSeekerId': jobSeekerId,
        'jobTitle': jobTitle,
        'employerName': employerName,
        'cvUrl': cvUrl,
        'coverLetter': coverLetter,
        'expectedSalary': expectedSalary,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef =
          await _firestore.collection('applications').add(applicationData);

      debugPrint('Application created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating application: $e');
      rethrow;
    }
  }

  /// Get user's applications
  static Stream<List<Application>> getUserApplications() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('applications')
        .where('jobSeekerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Application.fromFirestore(doc))
          .toList();
    });
  }

  /// Get applications for a specific job (for employers)
  static Stream<List<Application>> getJobApplications(String jobId) {
    return _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Application.fromFirestore(doc))
          .toList();
    });
  }

  /// Update application status (for employers)
  static Future<void> updateApplicationStatus({
    required String applicationId,
    required String newStatus,
  }) async {
    try {
      await _firestore.collection('applications').doc(applicationId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Application status updated to: $newStatus');
    } catch (e) {
      debugPrint('Error updating application status: $e');
      rethrow;
    }
  }

  /// Check if user has applied to a job
  static Future<bool> hasUserAppliedToJob(String jobId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final applications = await _firestore
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .where('jobSeekerId', isEqualTo: user.uid)
          .get();

      return applications.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking application status: $e');
      return false;
    }
  }

  /// Get application statistics for employer
  static Future<Map<String, int>> getApplicationStats(String employerId) async {
    try {
      final applications = await _firestore
          .collection('applications')
          .where('employerId', isEqualTo: employerId)
          .get();

      final stats = <String, int>{
        'total': applications.docs.length,
        'pending': 0,
        'reviewing': 0,
        'shortlisted': 0,
        'interview_scheduled': 0,
        'interviewed': 0,
        'selected': 0,
        'rejected': 0,
        'withdrawn': 0,
      };

      for (final doc in applications.docs) {
        final status = doc.data()['status'] as String? ?? 'pending';
        stats[status] = (stats[status] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      debugPrint('Error getting application stats: $e');
      return {
        'total': 0,
        'pending': 0,
        'reviewing': 0,
        'shortlisted': 0,
        'interview_scheduled': 0,
        'interviewed': 0,
        'selected': 0,
        'rejected': 0,
        'withdrawn': 0,
      };
    }
  }

  /// Withdraw application (for job seekers)
  static Future<void> withdrawApplication(String applicationId) async {
    try {
      await _firestore.collection('applications').doc(applicationId).update({
        'status': 'withdrawn',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Application withdrawn');
    } catch (e) {
      debugPrint('Error withdrawing application: $e');
      rethrow;
    }
  }

  /// Delete application (for job seekers, only if pending)
  static Future<void> deleteApplication(String applicationId) async {
    try {
      // First check if application is still pending
      final doc =
          await _firestore.collection('applications').doc(applicationId).get();

      if (!doc.exists) {
        throw Exception('Application not found');
      }

      final status = doc.data()?['status'] as String? ?? '';
      if (status != 'pending') {
        throw Exception('Cannot delete application that has been reviewed');
      }

      await _firestore.collection('applications').doc(applicationId).delete();

      debugPrint('Application deleted');
    } catch (e) {
      debugPrint('Error deleting application: $e');
      rethrow;
    }
  }
}
