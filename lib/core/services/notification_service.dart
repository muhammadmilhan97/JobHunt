import 'dart:developer';
import 'package:flutter/services.dart';

/// Service for managing notification channels and local notifications
class NotificationService {
  static const MethodChannel _channel =
      MethodChannel('com.jobhunt.app/notifications');
  static bool _isInitialized = false;

  /// Initialize notification channels (Android only)
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _createNotificationChannels();
      _isInitialized = true;
      log('Notification service initialized');
    } catch (e) {
      log('Error initializing notification service: $e');
    }
  }

  /// Create notification channels for Android
  static Future<void> _createNotificationChannels() async {
    try {
      // This would typically be done in native Android code
      // For now, we'll use a method channel approach
      await _channel.invokeMethod('createNotificationChannels', {
        'channels': [
          {
            'id': 'jobhunt_default_channel',
            'name': 'JobHunt Notifications',
            'description': 'General notifications for JobHunt app',
            'importance': 'high',
            'enableVibration': true,
            'enableLights': true,
          },
          {
            'id': 'job_alerts_channel',
            'name': 'Job Alerts',
            'description': 'Notifications for new job opportunities',
            'importance': 'high',
            'enableVibration': true,
            'enableLights': true,
          },
          {
            'id': 'application_updates_channel',
            'name': 'Application Updates',
            'description': 'Updates on your job applications',
            'importance': 'high',
            'enableVibration': true,
            'enableLights': true,
          },
          {
            'id': 'messages_channel',
            'name': 'Messages',
            'description': 'Messages from employers',
            'importance': 'high',
            'enableVibration': true,
            'enableLights': true,
          },
        ],
      });
      log('Notification channels created successfully');
    } catch (e) {
      // Fallback: channels will be created automatically by FCM
      log('Method channel not available, using default FCM channels: $e');
    }
  }

  /// Show local notification (for testing purposes)
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? channelId,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _channel.invokeMethod('showNotification', {
        'title': title,
        'body': body,
        'channelId': channelId ?? 'jobhunt_default_channel',
        'data': data ?? {},
      });
    } catch (e) {
      log('Error showing local notification: $e');
    }
  }
}
