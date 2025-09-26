import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/job.dart';
import '../models/user_profile.dart';
import 'email_service.dart';
import 'error_reporter.dart';

class JobAlertService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send job alerts to all eligible job seekers when new jobs are posted
  static Future<void> sendJobAlertsForNewJob(Job job) async {
    try {
      // Get all job seekers who have email notifications enabled
      final jobSeekersQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'job_seeker')
          .where('emailNotifications', isEqualTo: true)
          .get();

      if (jobSeekersQuery.docs.isEmpty) {
        if (kDebugMode) {
          print('No job seekers found for job alerts');
        }
        return;
      }

      final eligibleRecipients = <EmailRecipient>[];

      for (final doc in jobSeekersQuery.docs) {
        final userProfile = UserProfile.fromFirestore(doc);

        // Check if job matches user's preferences
        if (_jobMatchesUserPreferences(job, userProfile)) {
          eligibleRecipients.add(EmailRecipient(
            email: userProfile.email,
            name: userProfile.name,
            substitutions: {
              'user_name': userProfile.name,
              'job_title': job.title,
              'company_name': job.company,
              'job_location': job.locationCity,
            },
          ));
        }
      }

      if (eligibleRecipients.isEmpty) {
        if (kDebugMode) {
          print('No eligible recipients found for job: ${job.title}');
        }
        return;
      }

      // Send job alerts in batches (SendGrid has limits)
      const batchSize = 100;
      for (int i = 0; i < eligibleRecipients.length; i += batchSize) {
        final batch = eligibleRecipients.skip(i).take(batchSize).toList();

        await EmailService.sendJobAlerts(
          recipients: batch,
          newJobs: [
            {
              'title': job.title,
              'companyName': job.company,
              'location': job.locationCity,
              'description': job.description.length > 200
                  ? '${job.description.substring(0, 200)}...'
                  : job.description,
              'url':
                  'https://your-app-domain.com/jobs/${job.id}', // Update with your actual domain
            }
          ],
        );

        if (kDebugMode) {
          print(
              'Sent job alerts to batch of ${batch.length} users for job: ${job.title}');
        }

        // Small delay between batches to avoid rate limiting
        if (i + batchSize < eligibleRecipients.length) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      // Log the job alert activity
      await _logJobAlertActivity(job.id, eligibleRecipients.length);

      if (kDebugMode) {
        print(
            'Successfully sent job alerts to ${eligibleRecipients.length} users for job: ${job.title}');
      }
    } catch (e) {
      ErrorReporter.reportError(
        'Failed to send job alerts',
        'Exception occurred while sending job alerts: ${e.toString()}',
      );
    }
  }

  /// Send weekly job digest to users
  static Future<void> sendWeeklyJobDigest() async {
    try {
      // Get jobs posted in the last week
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentJobsQuery = await _firestore
          .collection('jobs')
          .where('createdAt', isGreaterThan: weekAgo)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      if (recentJobsQuery.docs.isEmpty) {
        if (kDebugMode) {
          print('No recent jobs found for weekly digest');
        }
        return;
      }

      final recentJobs = recentJobsQuery.docs.map((doc) {
        final data = doc.data();
        return {
          'title': data['title'] ?? '',
          'companyName': data['companyName'] ?? '',
          'location': data['location'] ?? '',
          'description': (data['description'] ?? '').toString().length > 150
              ? '${data['description'].toString().substring(0, 150)}...'
              : data['description'] ?? '',
          'url': 'https://your-app-domain.com/jobs/${doc.id}',
        };
      }).toList();

      // Get job seekers who want weekly digests
      final jobSeekersQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'job_seeker')
          .where('weeklyDigest', isEqualTo: true)
          .get();

      if (jobSeekersQuery.docs.isEmpty) {
        if (kDebugMode) {
          print('No users subscribed to weekly digest');
        }
        return;
      }

      // Send weekly digest individually using template and Gmail SMTP via Cloud Function
      for (final doc in jobSeekersQuery.docs) {
        final userProfile = UserProfile.fromFirestore(doc);
        final ok = await EmailService.sendWeeklyDigest(
          to: userProfile.email,
          toName: userProfile.name,
          category: userProfile.preferredCategories.isNotEmpty
              ? userProfile.preferredCategories.first
              : 'Jobs',
          jobs: recentJobs,
        );
        if (kDebugMode) {
          print('Weekly digest to ${userProfile.email}: $ok');
        }
        await Future.delayed(const Duration(milliseconds: 50));
      }

      if (kDebugMode) {
        print(
            'Successfully processed weekly digest for ${jobSeekersQuery.docs.length} users');
      }
    } catch (e) {
      ErrorReporter.reportError(
        'Failed to send weekly job digest',
        'Exception occurred while sending weekly digest: ${e.toString()}',
      );
    }
  }

  /// Check if a job matches user's preferences
  static bool _jobMatchesUserPreferences(Job job, UserProfile userProfile) {
    // Check preferred categories
    if (userProfile.preferredCategories.isNotEmpty) {
      final jobCategory = job.category.toLowerCase();
      final preferredCategories = userProfile.preferredCategories
          .map((cat) => cat.toLowerCase())
          .toList();

      if (!preferredCategories.contains(jobCategory)) {
        return false;
      }
    }

    // Check preferred cities
    if (userProfile.preferredCities.isNotEmpty) {
      final jobLocation = job.locationCity.toLowerCase();
      final preferredCities = userProfile.preferredCities
          .map((city) => city.toLowerCase())
          .toList();

      final cityMatch = preferredCities.any(
          (city) => jobLocation.contains(city) || city.contains(jobLocation));

      if (!cityMatch) {
        return false;
      }
    }

    // Check minimum salary preference
    final userMinSalary = userProfile.minSalaryPreferred ?? 0;
    final jobMinSalary = job.salaryMin ?? 0;
    if (userMinSalary > 0 && jobMinSalary > 0) {
      if (jobMinSalary < userMinSalary) {
        return false;
      }
    }

    return true;
  }

  /// Log job alert activity for analytics
  static Future<void> _logJobAlertActivity(
      String jobId, int recipientCount) async {
    try {
      await _firestore.collection('job_alert_logs').add({
        'jobId': jobId,
        'recipientCount': recipientCount,
        'sentAt': FieldValue.serverTimestamp(),
        'type': 'new_job_alert',
      });
    } catch (e) {
      // Don't throw error for logging failure
      if (kDebugMode) {
        print('Failed to log job alert activity: $e');
      }
    }
  }

  /// Update user's email notification preferences
  static Future<bool> updateEmailPreferences({
    required String userId,
    required bool emailNotifications,
    required bool weeklyDigest,
    required bool instantAlerts,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'emailNotifications': emailNotifications,
        'weeklyDigest': weeklyDigest,
        'instantAlerts': instantAlerts,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('Updated email preferences for user: $userId');
      }

      return true;
    } catch (e) {
      ErrorReporter.reportError(
        'Failed to update email preferences',
        'Exception occurred while updating email preferences: ${e.toString()}',
      );
      return false;
    }
  }
}
