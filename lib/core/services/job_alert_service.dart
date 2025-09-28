import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';
import '../models/user_profile.dart';
import '../services/email_service.dart';
import '../services/error_reporter.dart';
import '../config/email_config.dart';

/// Service for handling job alerts and weekly digest emails
class JobAlertService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send job alerts for a new job posting
  static Future<void> sendJobAlertsForNewJob(Job job) async {
    if (!EmailConfig.isConfigured || !EmailConfig.enableJobAlerts) return;

    try {
      // Get job seekers who have job alerts enabled and match the job criteria
      final jobSeekersQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'job_seeker')
          .where('instantAlerts', isEqualTo: true)
          .where('emailNotifications', isEqualTo: true)
          .get();

      final jobSeekers = jobSeekersQuery.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();

      // Filter job seekers based on job preferences
      final matchingJobSeekers = jobSeekers.where((jobSeeker) {
        return _matchesJobPreferences(jobSeeker, job);
      }).toList();

      // Send individual job alert emails
      for (final jobSeeker in matchingJobSeekers) {
        try {
          await EmailService.sendJobAlertsEmail(
            to: jobSeeker.email,
            toName: jobSeeker.name,
            jobs: [_formatJobForAlert(job)],
          );
        } catch (e) {
          ErrorReporter.reportError(
              'Failed to send job alert to ${jobSeeker.email}', e.toString());
        }
      }
    } catch (e) {
      ErrorReporter.reportError(
          'Failed to send job alerts for new job', e.toString());
    }
  }

  /// Send weekly digest to all job seekers
  static Future<void> sendWeeklyDigest() async {
    if (!EmailConfig.isConfigured || !EmailConfig.enableWeeklyDigest) return;

    try {
      // Get all job seekers who have weekly digest enabled
      final jobSeekersQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'job_seeker')
          .where('weeklyDigest', isEqualTo: true)
          .where('emailNotifications', isEqualTo: true)
          .get();

      final jobSeekers = jobSeekersQuery.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();

      // Get featured jobs from the past week
      final featuredJobs = await _getFeaturedJobs();
      final stats = await _getMarketStats();
      final trendingCompanies = await _getTrendingCompanies();

      // Send weekly digest to each job seeker
      for (final jobSeeker in jobSeekers) {
        try {
          await EmailService.sendWeeklyJobDigestEmail(
            to: jobSeeker.email,
            toName: jobSeeker.name,
            stats: stats,
            featuredJobs: featuredJobs,
            trendingCompanies: trendingCompanies,
          );
        } catch (e) {
          ErrorReporter.reportError(
              'Failed to send weekly digest to ${jobSeeker.email}',
              e.toString());
        }
      }
    } catch (e) {
      ErrorReporter.reportError('Failed to send weekly digest', e.toString());
    }
  }

  /// Check if a job matches job seeker preferences
  static bool _matchesJobPreferences(UserProfile jobSeeker, Job job) {
    // Basic matching logic - can be enhanced based on requirements
    final jobSeekerLocation = jobSeeker.city?.toLowerCase() ?? '';
    final jobLocation =
        '${job.locationCity}, ${job.locationCountry}'.toLowerCase();

    // Check location match (basic)
    final locationMatch = jobSeekerLocation.isEmpty ||
        jobLocation.contains(jobSeekerLocation) ||
        jobSeekerLocation.contains(job.locationCity.toLowerCase());

    // Check salary expectations (basic)
    final salaryMatch = jobSeeker.expectedSalary == null ||
        (job.salaryMin != null &&
            job.salaryMin! >= jobSeeker.expectedSalary! * 0.8);

    return locationMatch && salaryMatch;
  }

  /// Format job for alert email
  static Map<String, String> _formatJobForAlert(Job job) {
    return {
      'title': job.title,
      'company': job.company,
      'location': '${job.locationCity}, ${job.locationCountry}',
      'salary': job.salaryMin != null && job.salaryMax != null
          ? 'PKR ${job.salaryMin!.toStringAsFixed(0)} - PKR ${job.salaryMax!.toStringAsFixed(0)}'
          : job.salaryMin != null
              ? 'PKR ${job.salaryMin!.toStringAsFixed(0)}+'
              : 'Salary not specified',
      'url': 'https://jobhunt.pk/jobs/${job.id}',
    };
  }

  /// Get featured jobs for weekly digest
  static Future<List<Map<String, String>>> _getFeaturedJobs() async {
    try {
      final jobsQuery = await _firestore
          .collection('jobs')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      return jobsQuery.docs.map((doc) {
        final job = Job.fromFirestore(doc);
        return {
          'title': job.title,
          'company': job.company,
          'location': '${job.locationCity}, ${job.locationCountry}',
          'salary': job.salaryMin != null && job.salaryMax != null
              ? 'PKR ${job.salaryMin!.toStringAsFixed(0)} - PKR ${job.salaryMax!.toStringAsFixed(0)}'
              : job.salaryMin != null
                  ? 'PKR ${job.salaryMin!.toStringAsFixed(0)}+'
                  : 'Salary not specified',
          'type':
              'Full-time', // Default type since employmentType doesn't exist
          'url': 'https://jobhunt.pk/jobs/${job.id}',
        };
      }).toList();
    } catch (e) {
      ErrorReporter.reportError('Failed to get featured jobs', e.toString());
      return [];
    }
  }

  /// Get market statistics for weekly digest
  static Future<Map<String, dynamic>> _getMarketStats() async {
    try {
      // Get jobs from the past week
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final jobsQuery = await _firestore
          .collection('jobs')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(weekAgo))
          .get();

      final jobs = jobsQuery.docs.map((doc) => Job.fromFirestore(doc)).toList();

      // Get unique companies
      final companies = jobs.map((job) => job.company).toSet().length;

      // Get applications count (mock data for now)
      final applicationsQuery = await _firestore
          .collection('applications')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(weekAgo))
          .get();

      return {
        'newJobs': jobs.length,
        'companiesHiring': companies,
        'avgApplications': applicationsQuery.docs.length ~/
            (jobs.length > 0 ? jobs.length : 1),
        'hotSkills': 'Flutter, React, Python, Node.js',
        'remotePercentage': 45,
        'salaryIncrease': 12,
        'topSkills': 'Flutter, React, Python, Node.js',
        'hiringTimeline': 14,
        'userApplications': 3, // Mock data - would need to track per user
      };
    } catch (e) {
      ErrorReporter.reportError('Failed to get market stats', e.toString());
      return {
        'newJobs': 0,
        'companiesHiring': 0,
        'avgApplications': 0,
        'hotSkills': 'Flutter, React, Python',
        'remotePercentage': 45,
        'salaryIncrease': 12,
        'topSkills': 'Flutter, React, Python',
        'hiringTimeline': 14,
        'userApplications': 0,
      };
    }
  }

  /// Get trending companies for weekly digest
  static Future<List<Map<String, String>>> _getTrendingCompanies() async {
    try {
      // Get companies with most job postings in the past week
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final jobsQuery = await _firestore
          .collection('jobs')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(weekAgo))
          .get();

      final jobs = jobsQuery.docs.map((doc) => Job.fromFirestore(doc)).toList();

      // Count jobs per company
      final companyJobCounts = <String, int>{};
      for (final job in jobs) {
        companyJobCounts[job.company] =
            (companyJobCounts[job.company] ?? 0) + 1;
      }

      // Sort by job count and take top 3
      final sortedCompanies = companyJobCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedCompanies
          .take(3)
          .map((entry) => {
                'name': entry.key,
                'openings': entry.value.toString(),
              })
          .toList();
    } catch (e) {
      ErrorReporter.reportError(
          'Failed to get trending companies', e.toString());
      return [
        {'name': 'TechCorp', 'openings': '5'},
        {'name': 'StartupXYZ', 'openings': '3'},
        {'name': 'BigCompany', 'openings': '8'},
      ];
    }
  }
}
