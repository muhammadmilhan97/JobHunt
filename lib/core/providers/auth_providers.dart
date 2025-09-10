import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/auth_service.dart';

/// Provider for Firebase Auth user stream
final authStateProvider = StreamProvider<User?>((ref) {
  return AuthService.authStateChanges;
});

/// Provider for current user profile from Firestore
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user != null) {
        return AuthService.getCurrentUserProfile();
      }
      return Future.value(null);
    },
    loading: () => Future.value(null),
    error: (_, __) => Future.value(null),
  );
});

/// Provider for current user role
final currentUserRoleProvider = Provider<String?>((ref) {
  final userProfile = ref.watch(currentUserProfileProvider);

  return userProfile.when(
    data: (profile) => profile?.role,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for authentication loading state
final authLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  final userProfile = ref.watch(currentUserProfileProvider);

  return authState.isLoading || userProfile.isLoading;
});

/// State notifier for authentication actions
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Authentication state
class AuthState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Authentication notifier for handling auth actions
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await AuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create user with email and password
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String role = 'job_seeker',
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await AuthService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update user role
  Future<void> updateUserRole(String role) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await AuthService.updateUserRole(role);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await AuthService.signOut();
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await AuthService.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null, isSuccess: false);
  }

  /// Clear all state
  void reset() {
    state = const AuthState();
  }
}
