import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'firebase_service.dart';
import 'analytics_service.dart';
import 'email_service.dart';
import 'pin_service.dart';
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
          final userData = userDoc.data()!;
          final role = userData['role'] ?? 'unknown';
          final approvalStatus = userData['approvalStatus'] ?? 'pending';

          // Check if user is approved
          if (approvalStatus != 'approved') {
            await _auth.signOut(); // Sign out the user
            throw Exception(_getApprovalStatusMessage(approvalStatus));
          }

          await AnalyticsService.logLogin(role: role);
          await AnalyticsService.setUserProperties(
            userId: credential.user!.uid,
            role: role,
            city: userData['city'],
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
          // Admin approval status (pending by default)
          'approvalStatus': 'pending',
          'approvedAt': null,
          'approvedBy': null,
          'rejectionReason': null,
          // Email notification preferences (default to enabled)
          'emailNotifications': true,
          'weeklyDigest': role == 'job_seeker',
          'instantAlerts': role == 'job_seeker',
          'jobPostingNotifications': role == 'employer',
        });

        // Send admin notification email about new registration
        if (EmailConfig.isConfigured) {
          try {
            await _sendAdminNotificationEmail(
              userEmail: email,
              userName: name,
              userRole: role,
            );
          } catch (e) {
            // Don't fail registration if email fails, just log it
            print('Failed to send admin notification email: $e');
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

      // Clear PIN data
      await PinService.clearPinData();

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

  /// Get user-friendly approval status message
  static String _getApprovalStatusMessage(String status) {
    switch (status) {
      case 'pending':
        return 'Your account is pending admin approval. Please wait for approval before signing in.';
      case 'rejected':
        return 'Your account has been rejected. Please contact support for more information.';
      default:
        return 'Your account is not approved. Please contact support.';
    }
  }

  /// Send admin notification email about new user registration
  static Future<void> _sendAdminNotificationEmail({
    required String userEmail,
    required String userName,
    required String userRole,
  }) async {
    try {
      final roleDisplayName = _getRoleDisplayName(userRole);

      await EmailService.sendEmail(
        to: EmailConfig
            .supportEmail, // Send to your configured support/admin inbox
        toName: 'JobHunt Admin',
        subject: 'New User Registration - Approval Required',
        htmlContent: '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>New User Registration</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
    <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
        <h2 style="color: #2563EB;">New User Registration</h2>
        
        <p>A new user has registered and is awaiting approval:</p>
        
        <div style="background-color: #f8f9fa; padding: 15px; border-radius: 8px; margin: 20px 0;">
            <strong>User Details:</strong><br>
            <strong>Name:</strong> $userName<br>
            <strong>Email:</strong> $userEmail<br>
            <strong>Role:</strong> $roleDisplayName<br>
            <strong>Status:</strong> Pending Approval
        </div>
        
        <p>Please review and approve this registration in the admin panel.</p>
        
        <p>Best regards,<br>JobHunt System</p>
    </div>
</body>
</html>
        ''',
        textContent: '''
New User Registration - Approval Required

A new user has registered and is awaiting approval:

Name: $userName
Email: $userEmail
Role: $roleDisplayName
Status: Pending Approval

Please review and approve this registration in the admin panel.

Best regards,
JobHunt System
        ''',
      );

      print('✅ Admin notification email sent for new user: $userName');
    } catch (e) {
      print('❌ Failed to send admin notification email: $e');
    }
  }

  /// Get role display name for emails
  static String _getRoleDisplayName(String role) {
    switch (role) {
      case 'job_seeker':
        return 'Job Seeker';
      case 'employer':
        return 'Employer';
      case 'admin':
        return 'Administrator';
      default:
        return 'User';
    }
  }
}
