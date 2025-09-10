import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'firebase_service.dart';
import 'analytics_service.dart';
import 'email_service.dart';
// import 'otp_service.dart';
import '../config/email_config.dart';
import '../models/models.dart';

/// Service for handling Firebase Authentication
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Get current user ID
  static String? get currentUserId => currentUser?.uid;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Stream of authentication state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user role and log analytics
      if (credential.user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (userDoc.exists) {
          final role = userDoc.data()?['role'] ?? 'unknown';
          await AnalyticsService.logLogin(role: role);
          await AnalyticsService.setUserProperties(
            userId: credential.user!.uid,
            role: role,
            city: userDoc.data()?['city'],
          );
        }
      }

      return credential;
    } catch (e) {
      rethrow;
    }
  }

  /// Create user with email and password
  static Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          // Email notification preferences (default to enabled)
          'emailNotifications': true,
          'weeklyDigest': role == 'job_seeker',
          'instantAlerts': role == 'job_seeker',
          'jobPostingNotifications': role == 'employer',
        });

        // Send welcome email if email service is configured
        if (EmailConfig.isConfigured && EmailConfig.enableWelcomeEmails) {
          try {
            await EmailService.sendWelcomeEmail(
              to: email,
              toName: name,
              userRole: role,
            );
          } catch (e) {
            // Don't fail registration if email fails, just log it
            print('Failed to send welcome email: $e');
          }
        }

        // Log analytics
        await AnalyticsService.logSignUp(role: role);
        await AnalyticsService.setUserProperties(
          userId: credential.user!.uid,
          role: role,
        );
      }

      return credential;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out current user
  static Future<void> signOut() async {
    try {
      // Clear analytics user properties before signing out
      await AnalyticsService.clearUserProperties();

      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile
  static Future<void> updateUserProfile({
    required String name,
    String? photoURL,
  }) async {
    try {
      await currentUser?.updateDisplayName(name);
      if (photoURL != null) {
        await currentUser?.updatePhotoURL(photoURL);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update user email
  static Future<void> updateEmail(String newEmail) async {
    try {
      await currentUser?.verifyBeforeUpdateEmail(newEmail);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user password
  static Future<void> updatePassword(String newPassword) async {
    try {
      await currentUser?.updatePassword(newPassword);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user account
  static Future<void> deleteUser() async {
    try {
      // Clear analytics user properties before deleting
      await AnalyticsService.clearUserProperties();

      await currentUser?.delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Get user profile from Firestore
  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile in Firestore
  static Future<void> updateUserProfileInFirestore({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user profile from Firestore
  static Future<UserProfile?> getCurrentUserProfile() async {
    try {
      if (!isAuthenticated) return null;

      final doc = await _firestore.collection('users').doc(currentUserId).get();

      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Update user role in Firestore
  static Future<void> updateUserRole(String role) async {
    try {
      if (!isAuthenticated) throw Exception('User not authenticated');

      await _firestore.collection('users').doc(currentUserId).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
