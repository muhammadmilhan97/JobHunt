import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repository/favorites_repository.dart';
import '../models/job.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository();
});

final isFavoriteProvider = StreamProvider.family<bool, String>((ref, jobId) {
  final repo = ref.watch(favoritesRepositoryProvider);
  return repo.isFavorite(jobId);
});

final favoritesJobsProvider = StreamProvider.autoDispose<List<Job>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final repo = ref.watch(favoritesRepositoryProvider);
  return repo.streamFavorites(uid);
});

final toggleFavoriteProvider = Provider((ref) {
  final repo = ref.watch(favoritesRepositoryProvider);
  return (String jobId) => repo.toggleFavorite(jobId);
});
