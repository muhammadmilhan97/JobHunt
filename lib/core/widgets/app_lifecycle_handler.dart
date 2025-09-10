import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../services/firebase_push_service.dart';
import '../services/firebase_service.dart';
import '../providers/notification_providers.dart';

/// Widget that handles app lifecycle events and manages FCM token refresh
class AppLifecycleHandler extends ConsumerStatefulWidget {
  final Widget child;

  const AppLifecycleHandler({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppLifecycleHandler> createState() =>
      _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends ConsumerState<AppLifecycleHandler>
    with WidgetsBindingObserver {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Defer initialization to after first frame to avoid provider writes during build
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeServices());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Initialize Firebase services when app starts
  Future<void> _initializeServices() async {
    if (_initialized) return; // Prevent multiple initializations

    try {
      _initialized = true;

      // Use Future.microtask to defer provider writes until after build
      Future.microtask(() async {
        try {
          // Initialize FCM with notification provider
          final notificationNotifier =
              ref.read(notificationNotifierProvider.notifier);
          await notificationNotifier.initializeAndSaveToken();

          // Listen to auth state changes to manage FCM token
          FirebaseService.authStateChanges.listen((user) async {
            if (user != null) {
              // User logged in - save FCM token to Firestore
              await notificationNotifier.saveTokenAfterLogin();
              log('User authenticated: ${user.uid}');
            } else {
              // User logged out - remove FCM token from Firestore
              await notificationNotifier.removeTokenBeforeLogout();
              log('User signed out');
            }
          });

          log('App lifecycle handler initialized');
        } catch (e) {
          log('Error in microtask initialization: $e');
        }
      });
    } catch (e) {
      log('Error initializing app lifecycle handler: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        log('App resumed');
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        log('App paused');
        break;
      case AppLifecycleState.detached:
        log('App detached');
        break;
      case AppLifecycleState.inactive:
        log('App inactive');
        break;
      case AppLifecycleState.hidden:
        log('App hidden');
        break;
    }
  }

  /// Handle app resume events
  void _onAppResumed() {
    // Refresh FCM token when app resumes
    _refreshFCMToken();
  }

  /// Refresh FCM token and update in Firestore if user is authenticated
  Future<void> _refreshFCMToken() async {
    try {
      // Re-initialize push service to refresh token
      final notificationNotifier =
          ref.read(notificationNotifierProvider.notifier);
      await notificationNotifier.initializeAndSaveToken();
    } catch (e) {
      log('Error refreshing FCM token: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
