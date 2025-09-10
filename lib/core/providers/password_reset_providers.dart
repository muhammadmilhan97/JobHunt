import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/password_reset_service.dart';
import '../models/result.dart';

/// State for password reset functionality
class PasswordResetState {
  final bool isLoading;
  final String? error;
  final bool emailSent;

  const PasswordResetState({
    this.isLoading = false,
    this.error,
    this.emailSent = false,
  });

  PasswordResetState copyWith({
    bool? isLoading,
    String? error,
    bool? emailSent,
  }) {
    return PasswordResetState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      emailSent: emailSent ?? this.emailSent,
    );
  }
}

/// Password reset notifier
class PasswordResetNotifier extends StateNotifier<PasswordResetState> {
  PasswordResetNotifier() : super(const PasswordResetState());

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    final result =
        await PasswordResetService.sendPasswordResetEmail(email: email);

    if (result.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        emailSent: true,
        error: null,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.errorMessage,
      );
    }

    return result;
  }

  /// Reset state
  void reset() {
    state = const PasswordResetState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Password reset provider
final passwordResetProvider =
    StateNotifierProvider<PasswordResetNotifier, PasswordResetState>(
  (ref) => PasswordResetNotifier(),
);

/// Password reset service provider
final passwordResetServiceProvider = Provider<PasswordResetService>(
  (ref) => throw UnimplementedError('PasswordResetService is static'),
);
