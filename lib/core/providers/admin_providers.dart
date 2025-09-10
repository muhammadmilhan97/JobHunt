import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';

/// Provider to check if current user is admin
final isAdminProvider = FutureProvider<bool>((ref) async {
  if (!AuthService.isAuthenticated) {
    return false;
  }

  try {
    // Check custom claims first
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final idTokenResult = await user.getIdTokenResult();
      final customClaims = idTokenResult.claims;

      if (customClaims?['role'] == 'admin') {
        return true;
      }
    }

    // Fallback to user document role
    final userDoc = await FirebaseService.firestore
        .collection('users')
        .doc(AuthService.currentUserId)
        .get();

    if (userDoc.exists) {
      final userData = userDoc.data();
      return userData?['role'] == 'admin';
    }

    return false;
  } catch (e) {
    print('Error checking admin status: $e');
    return false;
  }
});

/// Admin analytics data
class AdminAnalytics {
  final int totalUsers;
  final int totalEmployers;
  final int totalJobSeekers;
  final int totalJobs;
  final int activeJobs;
  final int totalApplications;
  final int pendingApplications;
  final int suspendedUsers;

  AdminAnalytics({
    required this.totalUsers,
    required this.totalEmployers,
    required this.totalJobSeekers,
    required this.totalJobs,
    required this.activeJobs,
    required this.totalApplications,
    required this.pendingApplications,
    required this.suspendedUsers,
  });
}

/// User data for admin management
class AdminUserData {
  final String id;
  final String email;
  final String? name;
  final String role;
  final DateTime? createdAt;
  final bool suspended;
  final String? companyName;

  AdminUserData({
    required this.id,
    required this.email,
    this.name,
    required this.role,
    this.createdAt,
    required this.suspended,
    this.companyName,
  });

  factory AdminUserData.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return AdminUserData(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'],
      role: data['role'] ?? 'job_seeker',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      suspended: data['suspended'] ?? false,
      companyName: data['companyName'],
    );
  }
}

/// Job data for admin moderation
class AdminJobData {
  final String id;
  final String title;
  final String company;
  final String category;
  final String employerId;
  final bool isActive;
  final DateTime createdAt;
  final int applicationsCount;

  AdminJobData({
    required this.id,
    required this.title,
    required this.company,
    required this.category,
    required this.employerId,
    required this.isActive,
    required this.createdAt,
    required this.applicationsCount,
  });

  factory AdminJobData.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return AdminJobData(
      id: doc.id,
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      category: data['category'] ?? '',
      employerId: data['employerId'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      applicationsCount: 0, // Will be populated separately if needed
    );
  }
}

/// Provider for admin analytics
final adminAnalyticsProvider = FutureProvider<AdminAnalytics>((ref) async {
  if (!await ref.read(isAdminProvider.future)) {
    throw Exception('Access denied: Admin role required');
  }

  try {
    // Get all counts in parallel
    final futures = await Future.wait([
      // Total users
      FirebaseService.firestore.collection('users').count().get(),
      // Total employers
      FirebaseService.firestore
          .collection('users')
          .where('role', isEqualTo: 'employer')
          .count()
          .get(),
      // Total job seekers
      FirebaseService.firestore
          .collection('users')
          .where('role', isEqualTo: 'job_seeker')
          .count()
          .get(),
      // Total jobs
      FirebaseService.firestore.collection('jobs').count().get(),
      // Active jobs
      FirebaseService.firestore
          .collection('jobs')
          .where('isActive', isEqualTo: true)
          .count()
          .get(),
      // Total applications
      FirebaseService.firestore.collection('applications').count().get(),
      // Pending applications
      FirebaseService.firestore
          .collection('applications')
          .where('status', isEqualTo: 'pending')
          .count()
          .get(),
      // Suspended users
      FirebaseService.firestore
          .collection('users')
          .where('suspended', isEqualTo: true)
          .count()
          .get(),
    ]);

    return AdminAnalytics(
      totalUsers: futures[0].count ?? 0,
      totalEmployers: futures[1].count ?? 0,
      totalJobSeekers: futures[2].count ?? 0,
      totalJobs: futures[3].count ?? 0,
      activeJobs: futures[4].count ?? 0,
      totalApplications: futures[5].count ?? 0,
      pendingApplications: futures[6].count ?? 0,
      suspendedUsers: futures[7].count ?? 0,
    );
  } catch (e) {
    print('Error fetching admin analytics: $e');
    rethrow;
  }
});

/// Provider for admin users list
final adminUsersProvider = StreamProvider<List<AdminUserData>>((ref) {
  return ref.watch(isAdminProvider).when(
        data: (isAdmin) {
          if (!isAdmin) {
            return Stream.error(
                Exception('Access denied: Admin role required'));
          }

          return FirebaseService.firestore
              .collection('users')
              .orderBy('createdAt', descending: true)
              .limit(100)
              .snapshots()
              .map((snapshot) => snapshot.docs
                  .map((doc) => AdminUserData.fromFirestore(doc))
                  .toList());
        },
        loading: () => const Stream.empty(),
        error: (error, stack) => Stream.error(error),
      );
});

/// Provider for admin jobs list
final adminJobsProvider = StreamProvider<List<AdminJobData>>((ref) {
  return ref.watch(isAdminProvider).when(
        data: (isAdmin) {
          if (!isAdmin) {
            return Stream.error(
                Exception('Access denied: Admin role required'));
          }

          return FirebaseService.firestore
              .collection('jobs')
              .orderBy('createdAt', descending: true)
              .limit(100)
              .snapshots()
              .map((snapshot) => snapshot.docs
                  .map((doc) => AdminJobData.fromFirestore(doc))
                  .toList());
        },
        loading: () => const Stream.empty(),
        error: (error, stack) => Stream.error(error),
      );
});

/// Admin operations service
class AdminService {
  /// Suspend user
  static Future<void> suspendUser(String userId) async {
    await FirebaseService.firestore.collection('users').doc(userId).update({
      'suspended': true,
      'suspendedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Unsuspend user
  static Future<void> unsuspendUser(String userId) async {
    await FirebaseService.firestore.collection('users').doc(userId).update({
      'suspended': false,
      'suspendedAt': FieldValue.delete(),
    });
  }

  /// Delete user (soft delete by marking as deleted)
  static Future<void> deleteUser(String userId) async {
    await FirebaseService.firestore.collection('users').doc(userId).update({
      'deleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
      'suspended': true,
    });
  }

  /// Deactivate job
  static Future<void> deactivateJob(String jobId) async {
    await FirebaseService.firestore.collection('jobs').doc(jobId).update({
      'isActive': false,
      'deactivatedAt': FieldValue.serverTimestamp(),
      'deactivatedBy': 'admin',
    });
  }

  /// Reactivate job
  static Future<void> reactivateJob(String jobId) async {
    await FirebaseService.firestore.collection('jobs').doc(jobId).update({
      'isActive': true,
      'reactivatedAt': FieldValue.serverTimestamp(),
      'reactivatedBy': 'admin',
    });
  }

  /// Delete job (soft delete)
  static Future<void> deleteJob(String jobId) async {
    await FirebaseService.firestore.collection('jobs').doc(jobId).update({
      'deleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
      'isActive': false,
    });
  }
}

/// Admin operations notifier
class AdminNotifier extends StateNotifier<AsyncValue<void>> {
  AdminNotifier() : super(const AsyncValue.data(null));

  Future<void> suspendUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      await AdminService.suspendUser(userId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> unsuspendUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      await AdminService.unsuspendUser(userId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      await AdminService.deleteUser(userId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deactivateJob(String jobId) async {
    state = const AsyncValue.loading();
    try {
      await AdminService.deactivateJob(jobId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> reactivateJob(String jobId) async {
    state = const AsyncValue.loading();
    try {
      await AdminService.reactivateJob(jobId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteJob(String jobId) async {
    state = const AsyncValue.loading();
    try {
      await AdminService.deleteJob(jobId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

/// Provider for admin operations
final adminNotifierProvider =
    StateNotifierProvider<AdminNotifier, AsyncValue<void>>((ref) {
  return AdminNotifier();
});
