import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling analytics events throughout the app
class AnalyticsService {
  static bool _isInitialized = false;
  static bool _analyticsEnabled = true;
  static FirebaseAnalytics? _analytics;

  /// Initialize the analytics service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Check if analytics should be enabled
    await _loadAnalyticsPreference();

    // Only initialize Firebase Analytics in production and if enabled
    if (!kDebugMode && _analyticsEnabled) {
      _analytics = FirebaseAnalytics.instance;
    }

    _isInitialized = true;
  }

  /// Load analytics preference from SharedPreferences
  static Future<void> _loadAnalyticsPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _analyticsEnabled = prefs.getBool('analytics_enabled') ?? true;
    } catch (e) {
      // Default to enabled if preference can't be loaded
      _analyticsEnabled = true;
    }
  }

  /// Set analytics enabled/disabled preference
  static Future<void> setAnalyticsEnabled(bool enabled) async {
    _analyticsEnabled = enabled;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('analytics_enabled', enabled);
    } catch (e) {
      // Log error but don't fail
      print('Failed to save analytics preference: $e');
    }
  }

  /// Check if analytics is currently enabled
  static bool get isEnabled => _analyticsEnabled && !kDebugMode;

  /// Log a custom event
  static Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    if (!isEnabled || _analytics == null) return;

    try {
      await _analytics!.logEvent(
        name: name,
        parameters: parameters?.cast<String, Object>(),
      );
    } catch (e) {
      // Don't throw errors for analytics failures
      print('Analytics error: $e');
    }
  }

  /// Log user sign up
  static Future<void> logSignUp({required String role}) async {
    await logEvent(
      name: 'sign_up',
      parameters: {
        'method': 'email',
        'role': role,
      },
    );
  }

  /// Log user login
  static Future<void> logLogin({required String role}) async {
    await logEvent(
      name: 'login',
      parameters: {
        'method': 'email',
        'role': role,
      },
    );
  }

  /// Log job view
  static Future<void> logJobView({
    required String jobId,
    String? category,
    String? city,
  }) async {
    await logEvent(
      name: 'job_view',
      parameters: {
        'job_id': jobId,
        if (category != null) 'category': category,
        if (city != null) 'city': city,
      },
    );
  }

  /// Log job application
  static Future<void> logApply({required String jobId}) async {
    await logEvent(
      name: 'job_apply',
      parameters: {
        'job_id': jobId,
      },
    );
  }

  /// Log job save/favorite
  static Future<void> logSave({
    required String jobId,
    required bool isSaved,
  }) async {
    await logEvent(
      name: isSaved ? 'job_save' : 'job_unsave',
      parameters: {
        'job_id': jobId,
      },
    );
  }

  /// Log application status change
  static Future<void> logStatusChange({
    required String jobId,
    required String status,
    String? previousStatus,
  }) async {
    await logEvent(
      name: 'application_status_change',
      parameters: {
        'job_id': jobId,
        'new_status': status,
        if (previousStatus != null) 'previous_status': previousStatus,
      },
    );
  }

  /// Log job post
  static Future<void> logJobPost({
    required String jobId,
    String? category,
    String? city,
  }) async {
    await logEvent(
      name: 'job_post',
      parameters: {
        'job_id': jobId,
        if (category != null) 'category': category,
        if (city != null) 'city': city,
      },
    );
  }

  /// Log job edit
  static Future<void> logJobEdit({required String jobId}) async {
    await logEvent(
      name: 'job_edit',
      parameters: {
        'job_id': jobId,
      },
    );
  }

  /// Log job delete
  static Future<void> logJobDelete({required String jobId}) async {
    await logEvent(
      name: 'job_delete',
      parameters: {
        'job_id': jobId,
      },
    );
  }

  /// Log search
  static Future<void> logSearch({
    String? query,
    String? category,
    String? city,
    String? type,
  }) async {
    await logEvent(
      name: 'job_search',
      parameters: {
        if (query != null) 'query': query,
        if (category != null) 'category': category,
        if (city != null) 'city': city,
        if (type != null) 'type': type,
      },
    );
  }

  /// Log filter usage
  static Future<void> logFilter({
    String? category,
    String? city,
    String? type,
    int? minSalary,
    int? maxSalary,
  }) async {
    await logEvent(
      name: 'job_filter',
      parameters: {
        if (category != null) 'category': category,
        if (city != null) 'city': city,
        if (type != null) 'type': type,
        if (minSalary != null) 'min_salary': minSalary,
        if (maxSalary != null) 'max_salary': maxSalary,
      },
    );
  }

  /// Log profile update
  static Future<void> logProfileUpdate({
    required String field,
    String? value,
  }) async {
    await logEvent(
      name: 'profile_update',
      parameters: {
        'field': field,
        if (value != null) 'value': value,
      },
    );
  }

  /// Log CV upload
  static Future<void> logCvUpload({required bool success}) async {
    await logEvent(
      name: success ? 'cv_upload_success' : 'cv_upload_failure',
    );
  }

  /// Log notification interaction
  static Future<void> logNotificationInteraction({
    required String notificationId,
    required String action,
  }) async {
    await logEvent(
      name: 'notification_interaction',
      parameters: {
        'notification_id': notificationId,
        'action': action,
      },
    );
  }

  /// Set user properties
  static Future<void> setUserProperties({
    String? userId,
    String? role,
    String? city,
  }) async {
    if (!isEnabled || _analytics == null) return;

    try {
      if (userId != null) {
        await _analytics!.setUserId(id: userId);
      }
      if (role != null) {
        await _analytics!.setUserProperty(name: 'user_role', value: role);
      }
      if (city != null) {
        await _analytics!.setUserProperty(name: 'user_city', value: city);
      }
    } catch (e) {
      print('Failed to set user properties: $e');
    }
  }

  /// Clear user properties (on logout)
  static Future<void> clearUserProperties() async {
    if (!isEnabled || _analytics == null) return;

    try {
      await _analytics!.setUserId(id: null);
      await _analytics!.setUserProperty(name: 'user_role', value: null);
      await _analytics!.setUserProperty(name: 'user_city', value: null);
    } catch (e) {
      print('Failed to clear user properties: $e');
    }
  }
}
