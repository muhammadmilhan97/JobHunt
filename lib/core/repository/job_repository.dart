import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';
import '../models/result.dart';
// import '../services/firebase_service.dart';
import '../services/error_reporter.dart';
import '../services/email_service.dart';
import '../services/job_alert_service.dart';
import '../config/email_config.dart';
import 'user_repository.dart';

class JobRepository {
  final FirebaseFirestore _firestore;

  JobRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _jobsCollection =>
      _firestore.collection('jobs');

  /// Stream latest jobs with Result wrapper
  Stream<Result<List<Job>>> streamLatestJobs() {
    try {
      return _jobsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots()
          .map<Result<List<Job>>>((snapshot) {
        try {
          final jobs =
              snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList();
          return Result.success(jobs);
        } catch (e) {
          ErrorReporter.reportException(
              e, StackTrace.current, 'streamLatestJobs.parse');
          return Result.failure('Failed to parse jobs data', e);
        }
      }).handleError((error) {
        ErrorReporter.reportException(
            error, StackTrace.current, 'streamLatestJobs.stream');
        return Result.failure('Failed to load jobs', error);
      });
    } catch (e) {
      ErrorReporter.reportException(
          e, StackTrace.current, 'streamLatestJobs.setup');
      return Stream.value(Result.failure('Failed to setup jobs stream', e));
    }
  }

  /// Search jobs with Result wrapper
  Future<Result<List<Job>>> searchJobs({
    String? query,
    String? category,
    String? location,
    String? type,
    int? minSalary,
    int? maxSalary,
  }) async {
    return ResultHelper.wrapWithHandler(
      () async {
        Query<Map<String, dynamic>> queryRef = _jobsCollection
            .where('isActive', isEqualTo: true)
            .orderBy('createdAt', descending: true);

        if (category != null && category.isNotEmpty) {
          queryRef = queryRef.where('category', isEqualTo: category);
        }
        if (type != null && type.isNotEmpty) {
          queryRef = queryRef.where('type', isEqualTo: type);
        }

        final snapshot = await queryRef.get();
        List<Job> jobs =
            snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList();

        // Apply additional filters
        if (query != null && query.isNotEmpty) {
          final lowerQuery = query.toLowerCase();
          jobs = jobs
              .where((job) =>
                  job.title.toLowerCase().contains(lowerQuery) ||
                  job.company.toLowerCase().contains(lowerQuery) ||
                  job.description.toLowerCase().contains(lowerQuery))
              .toList();
        }

        if (location != null && location.isNotEmpty) {
          final lowerLocation = location.toLowerCase();
          jobs = jobs
              .where((job) =>
                  job.locationCity.toLowerCase().contains(lowerLocation) ||
                  job.locationCountry.toLowerCase().contains(lowerLocation))
              .toList();
        }

        if (minSalary != null) {
          jobs = jobs
              .where(
                  (job) => job.salaryMin != null && job.salaryMin! >= minSalary)
              .toList();
        }

        if (maxSalary != null) {
          jobs = jobs
              .where(
                  (job) => job.salaryMax != null && job.salaryMax! <= maxSalary)
              .toList();
        }

        return jobs;
      },
      (error) {
        ErrorReporter.reportException(error, StackTrace.current, 'searchJobs');
        return 'Failed to search jobs';
      },
    );
  }

  /// Get job by ID with Result wrapper
  Future<Result<Job?>> getJobById(String id) async {
    return ResultHelper.wrapWithHandler(
      () async {
        final doc = await _jobsCollection.doc(id).get();
        if (doc.exists) {
          return Job.fromFirestore(doc);
        }
        return null;
      },
      (error) {
        ErrorReporter.reportException(error, StackTrace.current, 'getJobById');
        return 'Failed to get job details';
      },
    );
  }

  /// Create job with Result wrapper
  Future<Result<String>> createJob(Job job) async {
    return ResultHelper.wrapWithHandler(
      () async {
        final docRef = await _jobsCollection.add(job.toFirestore());
        final jobId = docRef.id;

        // Create job with ID for email notifications
        final jobWithId = job.copyWith(id: jobId);

        // Send email notifications asynchronously (don't block job creation)
        _sendJobNotifications(jobWithId);

        return jobId;
      },
      (error) {
        ErrorReporter.reportException(error, StackTrace.current, 'createJob');
        return 'Failed to create job';
      },
    );
  }

  /// Send job-related email notifications
  Future<void> _sendJobNotifications(Job job) async {
    try {
      if (!EmailConfig.isConfigured) return;

      // Get employer details for job posting confirmation
      if (EmailConfig.enableEmployerNotifications) {
        final userRepo = UserRepository();
        final employer = await userRepo.getUserById(job.employerId);

        if (employer != null && employer.jobPostingNotifications) {
          await EmailService.sendJobPostingConfirmation(
            to: employer.email,
            toName: employer.name,
            jobTitle: job.title,
            companyName: job.company,
          );
        }
      }

      // Send job alerts to matching job seekers
      if (EmailConfig.enableJobAlerts) {
        await JobAlertService.sendJobAlertsForNewJob(job);
      }
    } catch (e) {
      // Don't fail job creation if email notifications fail
      ErrorReporter.reportError(
        'Failed to send job notifications',
        'Exception occurred while sending job notifications: ${e.toString()}',
      );
    }
  }

  /// Update job with Result wrapper
  Future<Result<void>> updateJob(String id, Map<String, dynamic> data) async {
    return ResultHelper.wrapWithHandler(
      () async {
        await _jobsCollection.doc(id).update(data);
      },
      (error) {
        ErrorReporter.reportException(error, StackTrace.current, 'updateJob');
        return 'Failed to update job';
      },
    );
  }

  /// Delete job with Result wrapper
  Future<Result<void>> deleteJob(String id) async {
    return ResultHelper.wrapWithHandler(
      () async {
        await _jobsCollection.doc(id).update({'isActive': false});
      },
      (error) {
        ErrorReporter.reportException(error, StackTrace.current, 'deleteJob');
        return 'Failed to delete job';
      },
    );
  }

  /// Hard delete job with Result wrapper
  Future<Result<void>> hardDeleteJob(String id) async {
    return ResultHelper.wrapWithHandler(
      () async {
        await _jobsCollection.doc(id).delete();
      },
      (error) {
        ErrorReporter.reportException(
            error, StackTrace.current, 'hardDeleteJob');
        return 'Failed to permanently delete job';
      },
    );
  }

  /// Get jobs by employer ID with Result wrapper
  Stream<Result<List<Job>>> streamJobsByEmployerId(String employerId) {
    try {
      print('Repository - Querying jobs for employerId: $employerId');
      return _jobsCollection
          .where('employerId', isEqualTo: employerId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map<Result<List<Job>>>((snapshot) {
        try {
          final jobs =
              snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList();
          print(
              'Repository - Found ${jobs.length} jobs for employerId: $employerId');
          for (var job in jobs) {
            print('Repository - Job: ${job.title} (ID: ${job.id})');
          }
          return Result.success(jobs);
        } catch (e) {
          ErrorReporter.reportException(
              e, StackTrace.current, 'streamJobsByEmployerId.parse');
          return Result.failure('Failed to parse employer jobs', e);
        }
      }).handleError((error) {
        ErrorReporter.reportException(
            error, StackTrace.current, 'streamJobsByEmployerId.stream');
        return Result.failure('Failed to load employer jobs', error);
      });
    } catch (e) {
      ErrorReporter.reportException(
          e, StackTrace.current, 'streamJobsByEmployerId.setup');
      return Stream.value(
          Result.failure('Failed to setup employer jobs stream', e));
    }
  }

  /// Get job categories with Result wrapper
  Future<Result<List<String>>> getJobCategories() async {
    return ResultHelper.wrapWithHandler(
      () async {
        // For now, return a static list. In a real app, this might come from Firestore
        return [
          'All',
          'Technology',
          'Healthcare',
          'Finance',
          'Education',
          'Marketing',
          'Sales',
          'Customer Service',
          'Engineering',
          'Design',
          'Operations',
          'Human Resources',
        ];
      },
      (error) {
        ErrorReporter.reportException(
            error, StackTrace.current, 'getJobCategories');
        return 'Failed to load job categories';
      },
    );
  }

  /// Get available cities with Result wrapper
  Future<Result<List<String>>> getAvailableCities() async {
    return ResultHelper.wrapWithHandler(
      () async {
        // For now, return a static list. In a real app, this might come from Firestore
        return [
          'All Cities',
          'Karachi',
          'Lahore',
          'Islamabad',
          'Rawalpindi',
          'Faisalabad',
          'Multan',
          'Peshawar',
          'Quetta',
          'Sialkot',
          'Gujranwala',
        ];
      },
      (error) {
        ErrorReporter.reportException(
            error, StackTrace.current, 'getAvailableCities');
        return 'Failed to load available cities';
      },
    );
  }

  /// Get available job types with Result wrapper
  Future<Result<List<String>>> getAvailableJobTypes() async {
    return ResultHelper.wrapWithHandler(
      () async {
        return [
          'Full-time',
          'Part-time',
          'Contract',
          'Internship',
          'Freelance',
        ];
      },
      (error) {
        ErrorReporter.reportException(
            error, StackTrace.current, 'getAvailableJobTypes');
        return 'Failed to load job types';
      },
    );
  }
}
