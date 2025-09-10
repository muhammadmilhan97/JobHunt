import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job.dart';
import '../models/application.dart';
import '../repository/job_repository.dart';
import '../repository/applications_repository.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';

// Repository providers
final jobRepositoryProvider = Provider<JobRepository>((ref) => JobRepository());
final applicationsRepositoryProvider =
    Provider<ApplicationsRepository>((ref) => ApplicationsRepository());

// Job providers
final latestJobsProvider = StreamProvider<List<Job>>((ref) {
  final repository = ref.watch(jobRepositoryProvider);
  return repository.streamLatestJobs().map((result) => result.data ?? []);
});

final jobByIdProvider = FutureProvider.family<Job?, String>((ref, id) async {
  final repository = ref.watch(jobRepositoryProvider);
  final result = await repository.getJobById(id);
  return result.data;
});

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(jobRepositoryProvider);
  final result = await repository.getJobCategories();
  return result.data ?? [];
});

final jobTypesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(jobRepositoryProvider);
  final result = await repository.getAvailableJobTypes();
  return result.data ?? [];
});

final citiesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(jobRepositoryProvider);
  final result = await repository.getAvailableCities();
  return result.data ?? [];
});

final jobsByEmployerProvider =
    StreamProvider.family<List<Job>, String>((ref, employerId) {
  final repository = ref.watch(jobRepositoryProvider);
  return repository
      .streamJobsByEmployerId(employerId)
      .map((result) => result.data ?? []);
});

// Search providers
final searchJobsProvider =
    FutureProvider.family<List<Job>, Map<String, dynamic>>(
        (ref, filters) async {
  final repository = ref.watch(jobRepositoryProvider);
  final result = await repository.searchJobs(
    query: filters['query'] as String?,
    category: filters['category'] as String?,
    location: filters['location'] as String?,
    type: filters['type'] as String?,
    minSalary: filters['minSalary'] as int?,
    maxSalary: filters['maxSalary'] as int?,
  );
  return result.data ?? [];
});

// Application providers
final seekerApplicationsProvider = StreamProvider<List<Application>>((ref) {
  final repository = ref.watch(applicationsRepositoryProvider);
  final currentUser = AuthService.currentUser;
  return repository.streamForSeeker(currentUser?.uid);
});

final applicationByIdProvider =
    FutureProvider.family<Application?, String>((ref, id) async {
  final repository = ref.watch(applicationsRepositoryProvider);
  return await repository.getById(id);
});

// Auth providers
final authStateProvider = StreamProvider((ref) => AuthService.authStateChanges);

final currentUserProvider = Provider((ref) => AuthService.currentUser);

final isAuthenticatedProvider = Provider((ref) => AuthService.isAuthenticated);

// Auth actions
final loginProvider =
    FutureProvider.family<void, Map<String, String>>((ref, credentials) async {
  await AuthService.signInWithEmailAndPassword(
    email: credentials['email']!,
    password: credentials['password']!,
  );
});

final logoutProvider = FutureProvider((ref) async {
  await AuthService.signOut();
});

final registerProvider =
    FutureProvider.family<void, Map<String, String>>((ref, userData) async {
  await AuthService.createUserWithEmailAndPassword(
    email: userData['email']!,
    password: userData['password']!,
    name: userData['name']!,
    role: userData['role']!,
  );
});

final setRoleProvider = FutureProvider.family<void, String>((ref, role) async {
  final currentUser = AuthService.currentUser;
  if (currentUser != null) {
    await AuthService.updateUserProfileInFirestore(
      uid: currentUser.uid,
      data: {'role': role},
    );
  }
});

// Analytics providers
final analyticsEnabledProvider = StateProvider<bool>((ref) => true);

final toggleAnalyticsProvider =
    FutureProvider.family<void, bool>((ref, enabled) async {
  await AnalyticsService.setAnalyticsEnabled(enabled);
  ref.read(analyticsEnabledProvider.notifier).state = enabled;
});
