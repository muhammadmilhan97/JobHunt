import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_approval_service.dart';
import '../models/result.dart';

/// State for admin approval operations
class AdminApprovalState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> pendingUsers;
  final List<Map<String, dynamic>> allUsers;

  const AdminApprovalState({
    this.isLoading = false,
    this.error,
    this.pendingUsers = const [],
    this.allUsers = const [],
  });

  AdminApprovalState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? pendingUsers,
    List<Map<String, dynamic>>? allUsers,
  }) {
    return AdminApprovalState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pendingUsers: pendingUsers ?? this.pendingUsers,
      allUsers: allUsers ?? this.allUsers,
    );
  }
}

/// Admin approval notifier
class AdminApprovalNotifier extends StateNotifier<AdminApprovalState> {
  AdminApprovalNotifier() : super(const AdminApprovalState());

  /// Load pending users
  Future<void> loadPendingUsers() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await AdminApprovalService.getPendingUsers();

    if (result.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        pendingUsers: result.data!,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.errorMessage,
      );
    }
  }

  /// Load all users with status
  Future<void> loadAllUsers() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await AdminApprovalService.getAllUsersWithStatus();

    if (result.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        allUsers: result.data!,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.errorMessage,
      );
    }
  }

  /// Approve user
  Future<Result<void>> approveUser(String userId,
      {String? approverName}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await AdminApprovalService.approveUser(
      userId: userId,
      approverName: approverName,
    );

    if (result.isSuccess) {
      // Remove from pending users list
      final updatedPending =
          state.pendingUsers.where((user) => user['id'] != userId).toList();

      state = state.copyWith(
        isLoading: false,
        pendingUsers: updatedPending,
      );

      // Refresh all users if loaded
      if (state.allUsers.isNotEmpty) {
        await loadAllUsers();
      }
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.errorMessage,
      );
    }

    return result;
  }

  /// Reject user
  Future<Result<void>> rejectUser(
    String userId,
    String rejectionReason, {
    String? approverName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await AdminApprovalService.rejectUser(
      userId: userId,
      rejectionReason: rejectionReason,
      approverName: approverName,
    );

    if (result.isSuccess) {
      // Remove from pending users list
      final updatedPending =
          state.pendingUsers.where((user) => user['id'] != userId).toList();

      state = state.copyWith(
        isLoading: false,
        pendingUsers: updatedPending,
      );

      // Refresh all users if loaded
      if (state.allUsers.isNotEmpty) {
        await loadAllUsers();
      }
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.errorMessage,
      );
    }

    return result;
  }

  /// Reset user approval status
  Future<Result<void>> resetUserApproval(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await AdminApprovalService.resetUserApproval(userId);

    if (result.isSuccess) {
      // Refresh data
      await loadAllUsers();
      await loadPendingUsers();
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.errorMessage,
      );
    }

    return result;
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Admin approval provider
final adminApprovalProvider =
    StateNotifierProvider<AdminApprovalNotifier, AdminApprovalState>(
  (ref) => AdminApprovalNotifier(),
);

/// Provider for pending users count
final pendingUsersCountProvider = Provider<int>((ref) {
  final approvalState = ref.watch(adminApprovalProvider);
  return approvalState.pendingUsers.length;
});
