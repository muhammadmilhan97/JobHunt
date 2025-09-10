import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repository/user_repository.dart';

/// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Provider for getting a user by ID
final userByIdProvider =
    FutureProvider.family<UserProfile?, String>((ref, userId) {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserById(userId);
});

/// Provider for getting multiple users by IDs
final usersByIdsProvider =
    FutureProvider.family<Map<String, UserProfile>, List<String>>(
        (ref, userIds) {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUsersByIds(userIds);
});

/// Stream provider for a user profile
final userStreamProvider =
    StreamProvider.family<UserProfile?, String>((ref, userId) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.streamUser(userId);
});
