import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/pin_service.dart';

/// PIN state model
class PinState {
  final bool isLoading;
  final String? error;
  final bool isSet;
  final bool isVerified;
  final int remainingAttempts;

  const PinState({
    this.isLoading = false,
    this.error,
    this.isSet = false,
    this.isVerified = false,
    this.remainingAttempts = 5,
  });

  PinState copyWith({
    bool? isLoading,
    String? error,
    bool? isSet,
    bool? isVerified,
    int? remainingAttempts,
  }) {
    return PinState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSet: isSet ?? this.isSet,
      isVerified: isVerified ?? this.isVerified,
      remainingAttempts: remainingAttempts ?? this.remainingAttempts,
    );
  }
}

/// PIN notifier for managing PIN state
class PinNotifier extends StateNotifier<PinState> {
  PinNotifier() : super(const PinState());

  /// Initialize PIN state
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final isSet = await PinService.isPinSet();
      final isSessionVerified = await PinService.isSessionVerified();
      final remainingAttempts = await PinService.getRemainingAttempts();

      state = state.copyWith(
        isLoading: false,
        isSet: isSet,
        isVerified: isSessionVerified,
        remainingAttempts: remainingAttempts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Set PIN
  Future<bool> setPin(String pin) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await PinService.setPin(pin);

      if (success) {
        // Refresh state after successful PIN set
        await initialize();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to set PIN',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await PinService.verifyPin(pin);

      if (success) {
        // Refresh state after successful PIN verification
        await initialize();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid PIN',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Clear PIN session (on logout)
  Future<void> clearSession() async {
    await PinService.clearPinSession();
    state = state.copyWith(
      isVerified: false,
      remainingAttempts: 5,
    );
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// PIN provider
final pinProvider = StateNotifierProvider<PinNotifier, PinState>((ref) {
  return PinNotifier();
});
