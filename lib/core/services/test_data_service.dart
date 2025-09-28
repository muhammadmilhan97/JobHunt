import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for creating test data for development
class TestDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create sample applications for testing
  static Future<void> createSampleApplications() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No user logged in');
        return;
      }

      // Get the employer's jobs
      final jobsSnapshot = await _firestore
          .collection('jobs')
          .where('employerId', isEqualTo: currentUser.uid)
          .get();

      if (jobsSnapshot.docs.isEmpty) {
        print('No jobs found for employer');
        return;
      }

      final jobs = jobsSnapshot.docs;
      print('Found ${jobs.length} jobs for employer');

      // Create sample applications for each job
      for (int i = 0; i < jobs.length; i++) {
        final job = jobs[i];
        final jobData = job.data();

        // Create 2-5 sample applications per job
        final numApplications = 2 + (i % 4);

        for (int j = 0; j < numApplications; j++) {
          final applicationData = {
            'jobId': job.id,
            'employerId': currentUser.uid,
            'jobSeekerId': 'test_seeker_${i}_$j',
            'jobTitle': jobData['title'],
            'employerName': jobData['company'],
            'cvUrl': 'https://example.com/cv_${i}_$j.pdf',
            'coverLetter':
                'This is a sample cover letter for ${jobData['title']} by test seeker ${i}_$j.',
            'expectedSalary': 50000 + (j * 10000),
            'status': ['pending', 'reviewing', 'accepted', 'rejected'][j % 4],
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };

          await _firestore.collection('applications').add(applicationData);
          print(
              'Created sample application ${j + 1} for job ${jobData['title']}');
        }
      }

      print('Sample applications created successfully!');
    } catch (e) {
      print('Error creating sample applications: $e');
    }
  }

  /// Clear all test applications
  static Future<void> clearTestApplications() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No user logged in');
        return;
      }

      // Get all applications for this employer
      final applicationsSnapshot = await _firestore
          .collection('applications')
          .where('employerId', isEqualTo: currentUser.uid)
          .get();

      // Delete all applications
      for (final doc in applicationsSnapshot.docs) {
        await doc.reference.delete();
      }

      print('Cleared ${applicationsSnapshot.docs.length} test applications');
    } catch (e) {
      print('Error clearing test applications: $e');
    }
  }
}
