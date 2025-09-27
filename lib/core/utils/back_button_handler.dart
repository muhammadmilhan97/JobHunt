import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Simple back button handler for the entire app
class BackButtonHandler {
  /// Handle back button with simple logic: pop if possible, otherwise show exit dialog
  static void handleBackButton(BuildContext context) {
    final router = GoRouter.of(context);

    // Simple logic: if we can pop, pop. Otherwise show exit dialog.
    if (router.canPop()) {
      router.pop();
    } else {
      _showExitConfirmation(context);
    }
  }

  /// Show exit confirmation dialog
  static void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App?'),
        content: const Text('Are you sure you want to exit the application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Exit the app
              SystemNavigator.pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  /// Create a PopScope widget with simple back button handling
  static Widget createPopScope({
    required BuildContext context,
    required Widget child,
    bool canPop = false,
  }) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (didPop) return;
        handleBackButton(context);
      },
      child: child,
    );
  }
}
