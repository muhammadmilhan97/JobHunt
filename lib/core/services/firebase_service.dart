import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Central Firebase service providing static access to all Firebase services
class FirebaseService {
  // Private constructor to prevent instantiation
  FirebaseService._();

  /// Firebase Auth instance
  static FirebaseAuth get auth => FirebaseAuth.instance;

  /// Cloud Firestore instance
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Firebase Cloud Messaging instance
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;

  /// Firebase Storage instance
  static FirebaseStorage get storage => FirebaseStorage.instance;

  /// Firebase Analytics instance
  static FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

  /// Get current user
  static User? get currentUser => auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Stream of authentication state changes
  static Stream<User?> get authStateChanges => auth.authStateChanges();

  /// Sign out current user
  static Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Get user document reference
  static DocumentReference<Map<String, dynamic>> getUserDoc(String uid) {
    return firestore.collection('users').doc(uid);
  }

  /// Get jobs collection reference
  static CollectionReference<Map<String, dynamic>> get jobsCollection {
    return firestore.collection('jobs');
  }

  /// Get applications collection reference
  static CollectionReference<Map<String, dynamic>> get applicationsCollection {
    return firestore.collection('applications');
  }

  /// Get companies collection reference
  static CollectionReference<Map<String, dynamic>> get companiesCollection {
    return firestore.collection('companies');
  }
}

class FirebasePushServicePendingLink {
  static Map<String, String>? get() => pendingDeepLinkAccessor?.call();
  static void clear() => pendingDeepLinkClearer?.call();
}

// These are late-bound by FirebasePushService at runtime to avoid circular deps
typedef _DeepLinkGetter = Map<String, String>? Function();
typedef _DeepLinkClear = void Function();
_DeepLinkGetter? pendingDeepLinkAccessor;
_DeepLinkClear? pendingDeepLinkClearer;
