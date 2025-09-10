import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:math';
import 'email_service.dart';
import 'error_reporter.dart';
import '../config/email_config.dart';
import '../models/result.dart';

/// Service for handling password reset functionality
class PasswordResetService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send password reset email using Firebase Auth
  static Future<Result<void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      // Check if user exists in our database
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .get();

      if (userQuery.docs.isEmpty) {
        return Result.failure('No account found with this email address.');
      }

      final userData = userQuery.docs.first.data();
      final userName = userData['name'] ?? 'User';

      // Send Firebase password reset email
      await _auth.sendPasswordResetEmail(email: email.toLowerCase().trim());

      // Send custom password reset notification email
      await _sendPasswordResetNotificationEmail(
        email: email,
        userName: userName,
      );

      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email address.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Please try again later.';
          break;
        default:
          errorMessage =
              'Failed to send password reset email. Please try again.';
      }

      ErrorReporter.reportError(
        'Password reset error: ${e.code}',
        e.toString(),
      );

      return Result.failure(errorMessage);
    } catch (e) {
      ErrorReporter.reportError(
        'Unexpected password reset error',
        e.toString(),
      );
      return Result.failure('An unexpected error occurred. Please try again.');
    }
  }

  /// Generate a secure password reset token (for custom implementation if needed)
  static String _generateResetToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Create password reset token record in Firestore (for custom implementation)
  static Future<Result<String>> createPasswordResetToken({
    required String email,
  }) async {
    try {
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .get();

      if (userQuery.docs.isEmpty) {
        return Result.failure('No account found with this email address.');
      }

      final userId = userQuery.docs.first.id;
      final token = _generateResetToken();
      final expiresAt = DateTime.now().add(const Duration(hours: 1));

      // Store reset token in Firestore
      await _firestore.collection('password_resets').doc(token).set({
        'userId': userId,
        'email': email.toLowerCase().trim(),
        'token': token,
        'expiresAt': expiresAt,
        'used': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return Result.success(token);
    } catch (e) {
      ErrorReporter.reportError(
        'Failed to create password reset token',
        e.toString(),
      );
      return Result.failure('Failed to create password reset token.');
    }
  }

  /// Verify password reset token
  static Future<Result<String>> verifyResetToken(String token) async {
    try {
      final tokenDoc =
          await _firestore.collection('password_resets').doc(token).get();

      if (!tokenDoc.exists) {
        return Result.failure('Invalid or expired reset token.');
      }

      final data = tokenDoc.data()!;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final used = data['used'] as bool;

      if (used) {
        return Result.failure('This reset token has already been used.');
      }

      if (DateTime.now().isAfter(expiresAt)) {
        return Result.failure(
            'Reset token has expired. Please request a new one.');
      }

      return Result.success(data['userId'] as String);
    } catch (e) {
      ErrorReporter.reportError(
        'Failed to verify reset token',
        e.toString(),
      );
      return Result.failure('Failed to verify reset token.');
    }
  }

  /// Reset password with token (custom implementation)
  static Future<Result<void>> resetPasswordWithToken({
    required String token,
    required String newPassword,
  }) async {
    try {
      final verifyResult = await verifyResetToken(token);
      if (verifyResult.isFailure) {
        return Result.failure(verifyResult.errorMessage!);
      }

      final userId = verifyResult.data!;

      // Get user email from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return Result.failure('User account not found.');
      }

      final email = userDoc.data()!['email'] as String;

      // Update password in Firebase Auth
      final user = await _auth.currentUser;
      if (user != null && user.email == email) {
        await user.updatePassword(newPassword);
      } else {
        // If user is not currently signed in, we need to sign them in first
        // This is a limitation of Firebase Auth - password updates require authentication
        return Result.failure('Please sign in first to reset your password.');
      }

      // Mark token as used
      await _firestore.collection('password_resets').doc(token).update({
        'used': true,
        'usedAt': FieldValue.serverTimestamp(),
      });

      // Send confirmation email
      await _sendPasswordResetConfirmationEmail(
        email: email,
        userName: userDoc.data()!['name'] ?? 'User',
      );

      return Result.success(null);
    } catch (e) {
      ErrorReporter.reportError(
        'Failed to reset password',
        e.toString(),
      );
      return Result.failure('Failed to reset password. Please try again.');
    }
  }

  /// Send password reset notification email
  static Future<void> _sendPasswordResetNotificationEmail({
    required String email,
    required String userName,
  }) async {
    if (!EmailService.isInitialized) return;

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Password Reset Request</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { text-align: center; padding: 20px 0; border-bottom: 2px solid #007bff; }
        .logo { font-size: 24px; font-weight: bold; color: #007bff; }
        .content { padding: 30px 0; }
        .button { display: inline-block; padding: 12px 30px; background-color: #007bff; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
        .footer { text-align: center; padding: 20px 0; border-top: 1px solid #eee; color: #666; font-size: 14px; }
        .warning { background-color: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">JobHunt</div>
        </div>
        
        <div class="content">
            <h2>Password Reset Request</h2>
            <p>Hello $userName,</p>
            
            <p>We received a request to reset the password for your JobHunt account associated with this email address.</p>
            
            <div class="warning">
                <strong>Security Notice:</strong> We've sent a password reset email to your inbox. Please check your email and follow the instructions to reset your password.
            </div>
            
            <p><strong>What to do next:</strong></p>
            <ul>
                <li>Check your email inbox for a password reset email from Firebase</li>
                <li>Click the reset link in that email</li>
                <li>Create a new secure password</li>
                <li>Sign in with your new password</li>
            </ul>
            
            <p><strong>Security Tips:</strong></p>
            <ul>
                <li>Use a strong password with at least 8 characters</li>
                <li>Include uppercase, lowercase, numbers, and symbols</li>
                <li>Don't reuse passwords from other accounts</li>
                <li>Consider using a password manager</li>
            </ul>
            
            <p>If you didn't request this password reset, please ignore this email. Your password will remain unchanged.</p>
            
            <p>If you have any concerns about your account security, please contact our support team immediately.</p>
        </div>
        
        <div class="footer">
            <p>Best regards,<br>The JobHunt Team</p>
            <p>
                <a href="${EmailConfig.supportEmail}">Contact Support</a> | 
                <a href="${EmailConfig.appDomain}">Visit JobHunt</a>
            </p>
            <p style="font-size: 12px; color: #999;">
                This is an automated message. Please do not reply to this email.
            </p>
        </div>
    </div>
</body>
</html>
    ''';

    await EmailService.sendEmail(
      to: email,
      toName: userName,
      subject: 'Password Reset Request - JobHunt',
      htmlContent: htmlContent,
      textContent: '''
Hello $userName,

We received a request to reset the password for your JobHunt account.

We've sent a password reset email to your inbox. Please check your email and follow the instructions to reset your password.

If you didn't request this password reset, please ignore this email.

Best regards,
The JobHunt Team
      ''',
    );
  }

  /// Send password reset confirmation email
  static Future<void> _sendPasswordResetConfirmationEmail({
    required String email,
    required String userName,
  }) async {
    if (!EmailService.isInitialized) return;

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Password Reset Successful</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { text-align: center; padding: 20px 0; border-bottom: 2px solid #28a745; }
        .logo { font-size: 24px; font-weight: bold; color: #28a745; }
        .content { padding: 30px 0; }
        .success { background-color: #d4edda; border: 1px solid #c3e6cb; padding: 15px; border-radius: 5px; margin: 20px 0; color: #155724; }
        .footer { text-align: center; padding: 20px 0; border-top: 1px solid #eee; color: #666; font-size: 14px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">JobHunt</div>
        </div>
        
        <div class="content">
            <h2>Password Reset Successful</h2>
            <p>Hello $userName,</p>
            
            <div class="success">
                <strong>Success!</strong> Your password has been successfully reset.
            </div>
            
            <p>Your JobHunt account password has been changed successfully. You can now sign in with your new password.</p>
            
            <p><strong>Security Reminder:</strong></p>
            <ul>
                <li>Keep your password secure and don't share it with anyone</li>
                <li>Sign out of JobHunt on shared devices</li>
                <li>Contact us immediately if you notice any suspicious activity</li>
            </ul>
            
            <p>If you didn't make this change, please contact our support team immediately.</p>
        </div>
        
        <div class="footer">
            <p>Best regards,<br>The JobHunt Team</p>
            <p>
                <a href="${EmailConfig.supportEmail}">Contact Support</a> | 
                <a href="${EmailConfig.appDomain}">Visit JobHunt</a>
            </p>
        </div>
    </div>
</body>
</html>
    ''';

    await EmailService.sendEmail(
      to: email,
      toName: userName,
      subject: 'Password Reset Successful - JobHunt',
      htmlContent: htmlContent,
      textContent: '''
Hello $userName,

Your JobHunt account password has been successfully reset.

You can now sign in with your new password.

If you didn't make this change, please contact our support team immediately.

Best regards,
The JobHunt Team
      ''',
    );
  }

  /// Clean up expired reset tokens
  static Future<void> cleanupExpiredTokens() async {
    try {
      final expiredTokens = await _firestore
          .collection('password_resets')
          .where('expiresAt', isLessThan: Timestamp.now())
          .get();

      final batch = _firestore.batch();
      for (final doc in expiredTokens.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      ErrorReporter.reportError(
          'Failed to cleanup expired reset tokens', e.toString());
    }
  }
}
