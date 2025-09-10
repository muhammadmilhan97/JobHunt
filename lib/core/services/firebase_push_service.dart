import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
// no-op: keep imports minimal
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import 'auth_service.dart';

/// Service for handling Firebase Cloud Messaging (FCM) push notifications
class FirebasePushService {
  static String? _fcmToken;
  static bool _isInitialized = false;
  static bool _permissionGranted = false;
  static Map<String, String>? _pendingDeepLink; // {kind,id}

  /// Get the current FCM token
  static String? get fcmToken => _fcmToken;

  /// Check if notification permission is granted
  static bool get isPermissionGranted => _permissionGranted;

  /// Stream of foreground messages for UI to listen to
  static Stream<RemoteMessage> get foregroundMessageStream =>
      FirebaseMessaging.onMessage;

  /// Initialize FCM service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission for notifications
      await requestPermission();

      // Get initial token
      await _refreshToken();

      // Listen to token refresh
      FirebaseService.messaging.onTokenRefresh.listen((newToken) {
        log('FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        // Add token to Firestore array when user is authenticated
        if (AuthService.isAuthenticated) {
          _addTokenToFirestore(newToken);
        }
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message clicks
      FirebaseMessaging.onMessageOpenedApp
          .listen(_handleBackgroundMessageClick);

      // Handle initial message (app opened from terminated state)
      final initialMessage =
          await FirebaseService.messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleBackgroundMessageClick(initialMessage);
      }

      _isInitialized = true;
      // Wire accessors for router without importing this class there
      pendingDeepLinkAccessor = () => _pendingDeepLink;
      pendingDeepLinkClearer = () => _pendingDeepLink = null;
      log('Firebase Push Service initialized successfully');
    } catch (e) {
      log('Error initializing Firebase Push Service: $e');
    }
  }

  /// Request notification permission
  static Future<bool> requestPermission() async {
    try {
      final settings = await FirebaseService.messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      _permissionGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      log('FCM Permission status: ${settings.authorizationStatus}');
      log('Permission granted: $_permissionGranted');

      return _permissionGranted;
    } catch (e) {
      log('Error requesting FCM permission: $e');
      return false;
    }
  }

  /// Refresh FCM token
  static Future<void> _refreshToken() async {
    try {
      final token = await FirebaseService.messaging.getToken();
      if (token != null) {
        _fcmToken = token;
        log('FCM Token obtained: $token');

        // Add token to Firestore when user is authenticated
        if (AuthService.isAuthenticated) {
          await _addTokenToFirestore(token);
        }
      }
    } catch (e) {
      log('Error getting FCM token: $e');
    }
  }

  /// Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    log('Received foreground message: ${message.messageId}');
    log('Title: ${message.notification?.title}');
    log('Body: ${message.notification?.body}');
    log('Data: ${message.data}');

    // Create notification document in Firestore
    if (AuthService.isAuthenticated && message.notification != null) {
      _createNotificationDocument(message);
    }

    // Show in-app banner (this will be handled by the UI listener)
    // The UI can listen to the foreground message stream
  }

  /// Handle background message clicks
  static void _handleBackgroundMessageClick(RemoteMessage message) {
    log('Message clicked: ${message.messageId}');
    log('Data: ${message.data}');
    final kind = message.data['deep_link_kind'] as String?;
    final id = message.data['deep_link_id'] as String?;
    if (kind != null && id != null) {
      _pendingDeepLink = {'kind': kind, 'id': id};
    }
  }

  /// Add FCM token to Firestore array (avoids duplicates)
  static Future<void> _addTokenToFirestore(String token) async {
    if (!AuthService.isAuthenticated) {
      return;
    }

    try {
      final userDoc = FirebaseService.getUserDoc(AuthService.currentUserId!);

      // Get current tokens to check for duplicates
      final userSnapshot = await userDoc.get();
      final userData = userSnapshot.data();

      if (userData != null) {
        final List<dynamic> currentTokens = userData['fcmTokens'] ?? [];

        // Check if token already exists
        final tokenExists = currentTokens.any(
            (tokenData) => tokenData is Map && tokenData['token'] == token);

        if (!tokenExists) {
          // Add token to array
          await userDoc.update({
            'fcmTokens': FieldValue.arrayUnion([
              {
                'token': token,
                'platform': defaultTargetPlatform.name,
                'addedAt': FieldValue.serverTimestamp(),
              }
            ]),
            'lastTokenUpdate': FieldValue.serverTimestamp(),
          });
          log('FCM token added to Firestore array');
        } else {
          log('FCM token already exists in array');
        }
      } else {
        // User document doesn't exist, create with token
        await userDoc.set({
          'fcmTokens': [
            {
              'token': token,
              'platform': defaultTargetPlatform.name,
              'addedAt': FieldValue.serverTimestamp(),
            }
          ],
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        log('FCM token added to new user document');
      }
    } catch (e) {
      log('Error adding FCM token to Firestore: $e');
    }
  }

  /// Create notification document in Firestore
  static Future<void> _createNotificationDocument(RemoteMessage message) async {
    if (!AuthService.isAuthenticated || message.notification == null) {
      return;
    }

    try {
      final notificationsCollection = FirebaseService.firestore
          .collection('users')
          .doc(AuthService.currentUserId)
          .collection('notifications');

      await notificationsCollection.add({
        'title': message.notification!.title ?? '',
        'body': message.notification!.body ?? '',
        'data': message.data,
        'messageId': message.messageId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
        'receivedAt': DateTime.now().toIso8601String(),
        'deep_link_kind': message.data['deep_link_kind'],
        'deep_link_id': message.data['deep_link_id'],
      });

      log('Notification document created in Firestore');
    } catch (e) {
      log('Error creating notification document: $e');
    }
  }

  /// Save FCM token to Firestore (call this when user logs in) - Updated to use array
  static Future<void> saveTokenToFirestore() async {
    if (!AuthService.isAuthenticated || _fcmToken == null) {
      return;
    }

    await _addTokenToFirestore(_fcmToken!);
  }

  /// Remove current FCM token from Firestore array (call this when user logs out)
  static Future<void> removeTokenFromFirestore() async {
    if (!AuthService.isAuthenticated || _fcmToken == null) {
      return;
    }

    try {
      final userDoc = FirebaseService.getUserDoc(AuthService.currentUserId!);

      // Get current tokens to find the one to remove
      final userSnapshot = await userDoc.get();
      final userData = userSnapshot.data();

      if (userData != null) {
        final List<dynamic> currentTokens = userData['fcmTokens'] ?? [];

        // Find and remove the token
        final tokenToRemove = currentTokens.firstWhere(
          (tokenData) => tokenData is Map && tokenData['token'] == _fcmToken,
          orElse: () => null,
        );

        if (tokenToRemove != null) {
          await userDoc.update({
            'fcmTokens': FieldValue.arrayRemove([tokenToRemove]),
            'lastTokenUpdate': FieldValue.serverTimestamp(),
          });
          log('FCM token removed from Firestore array');
        } else {
          log('FCM token not found in array');
        }
      }
    } catch (e) {
      log('Error removing FCM token from Firestore: $e');
    }
  }

  /// Get unread notifications count stream
  static Stream<int> getUnreadNotificationsCount() {
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
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    if (!AuthService.isAuthenticated) return;

    try {
      await FirebaseService.firestore
          .collection('users')
          .doc(AuthService.currentUserId)
          .collection('notifications')
          .doc(notificationId)
          .update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error marking notification as read: $e');
    }
  }

  /// Get notifications stream
  static Stream<List<Map<String, dynamic>>> getNotificationsStream() {
    if (!AuthService.isAuthenticated) {
      return Stream.value([]);
    }

    return FirebaseService.firestore
        .collection('users')
        .doc(AuthService.currentUserId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  /// Send notification to specific user (server-side implementation needed)
  static Future<void> sendNotificationToUser({
    required String targetUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // This would typically be implemented on the server side
    // Here's the structure for reference:
    /*
    {
      "to": "<FCM_TOKEN>",
      "notification": {
        "title": title,
        "body": body
      },
      "data": data
    }
    */
    log('TODO: Implement server-side notification sending');
  }
}

/// Handle background messages (top-level function required)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling background message: ${message.messageId}');
  log('Title: ${message.notification?.title}');
  log('Body: ${message.notification?.body}');
  log('Data: ${message.data}');
}
