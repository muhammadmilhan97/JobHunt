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
        state = state.copyWith(
          isLoading: false,
          isSet: true,
          isVerified: true,
          remainingAttempts: 5,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to set PIN',
        );
      }

      return success;
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
      final remainingAttempts = await PinService.getRemainingAttempts();

      if (success) {
        state = state.copyWith(
          isLoading: false,
          isVerified: true,
          remainingAttempts: remainingAttempts,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: remainingAttempts > 0
              ? 'Incorrect PIN. $remainingAttempts attempts remaining.'
              : 'Too many failed attempts. Please sign out and sign in again.',
          remainingAttempts: remainingAttempts,
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Change PIN
  Future<bool> changePin(String oldPin, String newPin) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await PinService.changePin(oldPin, newPin);

      if (success) {
        state = state.copyWith(
          isLoading: false,
          remainingAttempts: 5,
        );
      } else {
        final remainingAttempts = await PinService.getRemainingAttempts();
        state = state.copyWith(
          isLoading: false,
          error: 'Incorrect current PIN',
          remainingAttempts: remainingAttempts,
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Reset PIN
  Future<bool> resetPin() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await PinService.resetPin();

      if (success) {
        state = state.copyWith(
          isLoading: false,
          isSet: false,
          isVerified: false,
          remainingAttempts: 5,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to reset PIN',
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear PIN data on logout
  Future<void> clearPinData() async {
    await PinService.clearPinData();
    state = const PinState();
  }
}

/// PIN provider
final pinProvider = StateNotifierProvider<PinNotifier, PinState>(
  (ref) => PinNotifier(),
);

/// Provider to check if PIN verification is required
final pinVerificationRequiredProvider = FutureProvider<bool>((ref) async {
  final pinState = ref.watch(pinProvider);
  if (!pinState.isSet) return false;

  return !pinState.isVerified;
});
