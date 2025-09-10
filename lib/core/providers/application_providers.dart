import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/application_service.dart';

/// Provider for user's applications stream
final userApplicationsProvider = StreamProvider<List<Application>>((ref) {
  return ApplicationService.getUserApplications();
});

/// Provider for checking if user has applied to a specific job
final hasAppliedToJobProvider =
    FutureProvider.family<bool, String>((ref, jobId) {
  return ApplicationService.hasUserAppliedToJob(jobId);
});

/// Provider for getting applications for a specific job (for employers)
final jobApplicationsProvider =
    StreamProvider.family<List<Application>, String>((ref, jobId) {
  return ApplicationService.getJobApplications(jobId);
});

/// Provider for application statistics (for employers)
final applicationStatsProvider =
    FutureProvider.family<Map<String, int>, String>((ref, employerId) {
  return ApplicationService.getApplicationStats(employerId);
});

/// Provider for application status labels
final applicationStatusLabelsProvider = Provider<Map<String, String>>((ref) {
  return {
    'pending': 'Under Review',
    'reviewing': 'Being Reviewed',
    'shortlisted': 'Shortlisted',
    'interview_scheduled': 'Interview Scheduled',
    'interviewed': 'Interviewed',
    'selected': 'Selected',
    'rejected': 'Not Selected',
    'withdrawn': 'Withdrawn',
  };
});

/// Provider for application status colors
final applicationStatusColorsProvider = Provider<Map<String, Color>>((ref) {
  return {
    'pending': Colors.orange,
    'reviewing': Colors.blue,
    'shortlisted': Colors.purple,
    'interview_scheduled': Colors.indigo,
    'interviewed': Colors.teal,
    'selected': Colors.green,
    'rejected': Colors.red,
    'withdrawn': Colors.grey,
  };
});

/// Application notifier for handling application operations
class ApplicationNotifier extends StateNotifier<AsyncValue<void>> {
  ApplicationNotifier() : super(const AsyncValue.data(null));

  /// Create a new application
  Future<String> createApplication({
    required String jobId,
    required String employerId,
    required String cvUrl,
    String? coverLetter,
    int? expectedSalary,
  }) async {
    state = const AsyncValue.loading();

    try {
      final applicationId = await ApplicationService.createApplication(
        jobId: jobId,
        employerId: employerId,
        cvUrl: cvUrl,
        coverLetter: coverLetter,
        expectedSalary: expectedSalary,
      );

      state = const AsyncValue.data(null);
      return applicationId;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Update application status
  Future<void> updateApplicationStatus({
    required String applicationId,
    required String newStatus,
  }) async {
    state = const AsyncValue.loading();

    try {
      await ApplicationService.updateApplicationStatus(
        applicationId: applicationId,
        newStatus: newStatus,
      );

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Withdraw application
  Future<void> withdrawApplication(String applicationId) async {
    state = const AsyncValue.loading();

    try {
      await ApplicationService.withdrawApplication(applicationId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Delete application
  Future<void> deleteApplication(String applicationId) async {
    state = const AsyncValue.loading();

    try {
      await ApplicationService.deleteApplication(applicationId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

/// Provider for application notifier
final applicationNotifierProvider =
    StateNotifierProvider<ApplicationNotifier, AsyncValue<void>>((ref) {
  return ApplicationNotifier();
});
