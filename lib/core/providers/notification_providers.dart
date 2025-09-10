// import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_push_service.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';

/// Provider for FCM permission status
final fcmPermissionProvider = StateProvider<bool>((ref) {
  return FirebasePushService.isPermissionGranted;
});

/// Provider for current FCM token
final fcmTokenProvider = StateProvider<String?>((ref) {
  return FirebasePushService.fcmToken;
});

/// Provider for foreground messages stream
final foregroundMessageProvider = StreamProvider<RemoteMessage>((ref) {
  return FirebasePushService.foregroundMessageStream;
});

/// Notification state for UI feedback
class NotificationState {
  final bool isLoading;
  final String? error;
  final bool permissionRequested;
  final bool tokenSaved;

  const NotificationState({
    this.isLoading = false,
    this.error,
    this.permissionRequested = false,
    this.tokenSaved = false,
  });

  NotificationState copyWith({
    bool? isLoading,
    String? error,
    bool? permissionRequested,
    bool? tokenSaved,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      permissionRequested: permissionRequested ?? this.permissionRequested,
      tokenSaved: tokenSaved ?? this.tokenSaved,
    );
  }
}

/// Notification notifier for handling FCM operations
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState());

  /// Request notification permission
  Future<void> requestPermission() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final granted = await FirebasePushService.requestPermission();
      state = state.copyWith(
        isLoading: false,
        permissionRequested: true,
        error: granted ? null : 'Notification permission denied',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to request permission: $e',
      );
    }
  }

  /// Initialize FCM and save token if user is authenticated
  Future<void> initializeAndSaveToken() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Initialize FCM service
      await FirebasePushService.initialize();

      // Save token if user is authenticated
      if (AuthService.isAuthenticated) {
        await FirebasePushService.saveTokenToFirestore();
        state = state.copyWith(
          isLoading: false,
          tokenSaved: true,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize FCM: $e',
      );
    }
  }

  /// Save FCM token to Firestore (call after login)
  Future<void> saveTokenAfterLogin() async {
    if (!AuthService.isAuthenticated) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await FirebasePushService.saveTokenToFirestore();
      state = state.copyWith(
        isLoading: false,
        tokenSaved: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save FCM token: $e',
      );
    }
  }

  /// Remove FCM token from Firestore (call before logout)
  Future<void> removeTokenBeforeLogout() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await FirebasePushService.removeTokenFromFirestore();
      state = state.copyWith(
        isLoading: false,
        tokenSaved: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to remove FCM token: $e',
      );
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void reset() {
    state = const NotificationState();
  }
}

/// Provider for notification notifier
final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});

/// Provider for in-app notification display
final inAppNotificationProvider = StateProvider<RemoteMessage?>((ref) {
  return null;
});

/// Provider to listen to foreground messages and update in-app notification
final foregroundMessageListenerProvider = Provider<void>((ref) {
  // Don't modify state during build - just listen
  ref.listen(foregroundMessageProvider, (previous, next) {
    next.whenData((message) {
      // Use Future.microtask to defer state modification
      Future.microtask(() {
        ref.read(inAppNotificationProvider.notifier).state = message;

        // Auto-clear after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (ref.read(inAppNotificationProvider) == message) {
            ref.read(inAppNotificationProvider.notifier).state = null;
          }
        });
      });
    });
  });
});

/// Provider for unread notifications count (from Firestore)
final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  if (!AuthService.isAuthenticated) {
    return Stream.value(0);
  }

  return FirebaseService.firestore
      .collection('users')
      .doc(AuthService.currentUserId)
      .collection('notifications')
      .where('read', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});
