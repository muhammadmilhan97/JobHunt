import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';

/// Notification model for UI
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool read;
  final DateTime createdAt;
  final String? receivedAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.data,
    required this.read,
    required this.createdAt,
    this.receivedAt,
  });

  factory NotificationItem.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return NotificationItem(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      data: data['data']?.cast<String, dynamic>(),
      read: data['read'] ?? false,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      receivedAt: data['receivedAt'] as String?,
    );
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    bool? read,
    DateTime? createdAt,
    String? receivedAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }
}

/// Provider for user's notifications stream
final userNotificationsProvider = StreamProvider<List<NotificationItem>>((ref) {
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
      .map((snapshot) => snapshot.docs
          .map((doc) => NotificationItem.fromFirestore(doc))
          .toList());
});

/// Provider for unread notifications count
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

/// Notification service for UI operations
class NotificationUIService {
  /// Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
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
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  static Future<void> markAllAsRead() async {
    if (!AuthService.isAuthenticated) return;

    try {
      final unreadNotifications = await FirebaseService.firestore
          .collection('users')
          .doc(AuthService.currentUserId)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .get();

      final batch = FirebaseService.firestore.batch();

      for (final doc in unreadNotifications.docs) {
        batch.update(doc.reference, {
          'read': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// Delete notification
  static Future<void> deleteNotification(String notificationId) async {
    if (!AuthService.isAuthenticated) return;

    try {
      await FirebaseService.firestore
          .collection('users')
          .doc(AuthService.currentUserId)
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  /// Delete all notifications
  static Future<void> deleteAllNotifications() async {
    if (!AuthService.isAuthenticated) return;

    try {
      final notifications = await FirebaseService.firestore
          .collection('users')
          .doc(AuthService.currentUserId)
          .collection('notifications')
          .get();

      final batch = FirebaseService.firestore.batch();

      for (final doc in notifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error deleting all notifications: $e');
      rethrow;
    }
  }
}

/// Notification state notifier for handling operations
class NotificationNotifier extends StateNotifier<AsyncValue<void>> {
  NotificationNotifier() : super(const AsyncValue.data(null));

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    state = const AsyncValue.loading();

    try {
      await NotificationUIService.markAsRead(notificationId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    state = const AsyncValue.loading();

    try {
      await NotificationUIService.markAllAsRead();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    state = const AsyncValue.loading();

    try {
      await NotificationUIService.deleteNotification(notificationId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    state = const AsyncValue.loading();

    try {
      await NotificationUIService.deleteAllNotifications();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

/// Provider for notification notifier
final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, AsyncValue<void>>((ref) {
  return NotificationNotifier();
});
