import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/applications_repository.dart';
import '../models/application.dart';

final applicationsRepositoryProvider = Provider<ApplicationsRepository>((ref) {
  return ApplicationsRepository();
});

final seekerApplicationsProvider = StreamProvider.autoDispose
    .family<List<Application>, String?>((ref, userId) {
  final repo = ref.watch(applicationsRepositoryProvider);
  return repo.streamForSeeker(userId);
});

final applicationByIdProvider =
    FutureProvider.family<Application?, String>((ref, id) {
  final repo = ref.watch(applicationsRepositoryProvider);
  return repo.getById(id);
});

final applicationProvider =
    StreamProvider.family<Application?, String>((ref, id) {
  final repo = ref.watch(applicationsRepositoryProvider);
  return repo.getById(id).asStream();
});

final applicationsForJobProvider =
    StreamProvider.family<List<Application>, String>((ref, jobId) {
  final applicationsRepository = ref.watch(applicationsRepositoryProvider);
  return applicationsRepository.streamForJob(jobId);
});
