import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/application.dart';
import '../services/email_service.dart';
import '../services/error_reporter.dart';
import '../config/email_config.dart';
import 'user_repository.dart';
import 'job_repository.dart';

class ApplicationsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ApplicationsRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Stream<List<Application>> streamForSeeker(String? userId) {
    final uid = userId ?? _uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('applications')
        .where('jobSeekerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Application.fromFirestore(doc))
            .toList());
  }

  Stream<List<Application>> streamForJob(String jobId) {
    return _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Application.fromFirestore(doc))
            .toList());
  }

  Future<Application?> getById(String id) async {
    try {
      final doc = await _firestore.collection('applications').doc(id).get();
      if (doc.exists) {
        return Application.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get application by ID: $e');
    }
  }

  /// Get all applications for an employer across all their jobs
  Stream<List<Application>> streamForEmployer(String employerId) {
    return _firestore
        .collection('applications')
        .where('employerId', isEqualTo: employerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Application.fromFirestore(doc))
            .toList());
  }

  Future<void> updateStatus(String applicationId, String newStatus) async {
    try {
      // Get application details before updating
      final applicationDoc =
          await _firestore.collection('applications').doc(applicationId).get();
      if (!applicationDoc.exists) {
        throw Exception('Application not found');
      }

      final application = Application.fromFirestore(applicationDoc);

      // Update status
      await _firestore.collection('applications').doc(applicationId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send email notification to job seeker
      if (EmailConfig.isConfigured) {
        try {
          await _sendApplicationStatusUpdateEmail(application, newStatus);
        } catch (e) {
          // Don't fail status update if email fails
          ErrorReporter.reportError(
              'Failed to send application status email', e.toString());
        }
      }
    } catch (e) {
      throw Exception('Failed to update application status: $e');
    }
  }

  /// Send application status update email to job seeker
  Future<void> _sendApplicationStatusUpdateEmail(
      Application application, String newStatus) async {
    try {
      // Get job details
      final jobRepo = JobRepository();
      final jobResult = await jobRepo.getJobById(application.jobId);
      if (jobResult.isFailure) return;

      final job = jobResult.data;
      if (job == null) return;

      // Get job seeker details
      final userRepo = UserRepository();
      final jobSeeker = await userRepo.getUserById(application.jobSeekerId);
      if (jobSeeker == null || !jobSeeker.emailNotifications) return;

      // Prepare interview details if status is interviewing
      String? interviewDate;
      String? interviewTime;
      if (newStatus.toLowerCase() == 'interviewing') {
        // In a real app, you'd get these from the application or a separate interview collection
        interviewDate = 'To be scheduled';
        interviewTime = 'To be confirmed';
      }

      await EmailService.sendApplicationStatusUpdateEmail(
        to: jobSeeker.email,
        toName: jobSeeker.name,
        jobTitle: job.title,
        companyName: job.company,
        status: newStatus,
        applicationId: application.id,
        interviewDate: interviewDate,
        interviewTime: interviewTime,
        notes: _getStatusNotes(newStatus),
      );
    } catch (e) {
      ErrorReporter.reportError(
          'Failed to send application status update email', e.toString());
    }
  }

  /// Get status-specific notes
  String? _getStatusNotes(String status) {
    switch (status.toLowerCase()) {
      case 'reviewing':
        return 'Your application is being carefully reviewed by our hiring team. We appreciate your patience.';
      case 'interviewing':
        return 'Congratulations! We would like to schedule an interview with you. Please check your email for interview details.';
      case 'accepted':
        return 'We are excited to offer you this position! Our team will contact you soon with next steps.';
      case 'rejected':
        return 'Thank you for your interest. While we were impressed with your qualifications, we have decided to move forward with other candidates.';
      default:
        return null;
    }
  }
}
