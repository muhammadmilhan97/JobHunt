import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Global error reporter service
class ErrorReporter {
  static bool _isInitialized = false;

  /// Initialize the error reporter
  static void initialize() {
    if (_isInitialized) return;

    // Set up global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      reportError(
        'Flutter Error',
        details.exception.toString(),
        details.stack,
        details.library,
      );
    };

    _isInitialized = true;
    developer.log('ErrorReporter initialized');
  }

  /// Report an error
  static void reportError(
    String title,
    String message, [
    StackTrace? stackTrace,
    String? library,
  ]) {
    final errorInfo = {
      'title': title,
      'message': message,
      'library': library ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
      'platform': defaultTargetPlatform.name,
    };

    if (kDebugMode) {
      // In development, log to console
      developer.log(
        'ERROR: $title - $message',
        name: 'ErrorReporter',
        error: stackTrace,
      );

      // Print formatted error info
      print('🚨 Error Report:');
      errorInfo.forEach((key, value) {
        print('  $key: $value');
      });
      if (stackTrace != null) {
        print('  stackTrace: $stackTrace');
      }
    } else {
      // In production, send to crash reporting service
      _sendToCrashReporting(errorInfo, stackTrace);
    }
  }

  /// Report an exception
  static void reportException(
    Object exception, [
    StackTrace? stackTrace,
    String? context,
  ]) {
    reportError(
      context ?? 'Exception',
      exception.toString(),
      stackTrace,
    );
  }

  /// Report a network error
  static void reportNetworkError(
    String endpoint,
    int? statusCode,
    String message, [
    StackTrace? stackTrace,
  ]) {
    reportError(
      'Network Error',
      'Failed to call $endpoint (${statusCode ?? 'unknown'}): $message',
      stackTrace,
      'network',
    );
  }

  /// Report a Firebase error
  static void reportFirebaseError(
    String operation,
    String message, [
    StackTrace? stackTrace,
  ]) {
    reportError(
      'Firebase Error',
      'Failed to $operation: $message',
      stackTrace,
      'firebase',
    );
  }

  /// Report a validation error
  static void reportValidationError(
    String field,
    String message, [
    StackTrace? stackTrace,
  ]) {
    reportError(
      'Validation Error',
      'Field "$field": $message',
      stackTrace,
      'validation',
    );
  }

  /// Send error to crash reporting service (production only)
  static void _sendToCrashReporting(
    Map<String, dynamic> errorInfo,
    StackTrace? stackTrace,
  ) {
    // TODO: Implement crash reporting service integration
    // Examples: Firebase Crashlytics, Sentry, Bugsnag, etc.

    // For now, just log to console in production
    developer.log(
      'Production Error: ${errorInfo['title']} - ${errorInfo['message']}',
      name: 'ErrorReporter',
      error: stackTrace,
    );
  }

  /// Set user context for error reporting
  static void setUserContext({
    String? userId,
    String? userRole,
    Map<String, dynamic>? additionalData,
  }) {
    // TODO: Set user context for crash reporting service
    if (kDebugMode) {
      developer.log(
        'User Context: userId=$userId, role=$userRole, data=$additionalData',
        name: 'ErrorReporter',
      );
    }
  }

  /// Log a non-error event for debugging
  static void logEvent(
    String event,
    Map<String, dynamic>? parameters,
  ) {
    if (kDebugMode) {
      developer.log(
        'Event: $event ${parameters ?? {}}',
        name: 'ErrorReporter',
      );
    }
  }
}

/// Extension to easily report errors from any object
extension ErrorReporting on Object {
  /// Report this object as an error
  void reportAsError([
    StackTrace? stackTrace,
    String? context,
  ]) {
    ErrorReporter.reportException(this, stackTrace, context);
  }
}
