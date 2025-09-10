import 'package:flutter/material.dart';

/// A widget that displays an error message with a retry button
class ErrorView extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryText;

  const ErrorView({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? 'Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A widget that displays a network error with retry functionality
class NetworkErrorView extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NetworkErrorView({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      title: 'Connection Error',
      message: message ??
          'Unable to connect to the server. Please check your internet connection and try again.',
      onRetry: onRetry,
      icon: Icons.wifi_off,
      retryText: 'Try Again',
    );
  }
}

/// A widget that displays a generic error with retry functionality
class GenericErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const GenericErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      title: 'Something went wrong',
      message: message,
      onRetry: onRetry,
      icon: Icons.error_outline,
      retryText: 'Retry',
    );
  }
}
