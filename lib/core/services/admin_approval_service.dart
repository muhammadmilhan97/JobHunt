import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_service.dart';
import 'error_reporter.dart';
import '../config/email_config.dart';
import '../models/result.dart';

/// Service for handling admin approval workflow
class AdminApprovalService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get all pending users for approval
  static Future<Result<List<Map<String, dynamic>>>> getPendingUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('approvalStatus', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      final users = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      return Result.success(users);
    } catch (e) {
      ErrorReporter.reportError('Failed to fetch pending users', e.toString());
      return Result.failure('Failed to fetch pending users: $e');
    }
  }

  /// Get all users with their approval status
  static Future<Result<List<Map<String, dynamic>>>>
      getAllUsersWithStatus() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      final users = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      return Result.success(users);
    } catch (e) {
      ErrorReporter.reportError('Failed to fetch users', e.toString());
      return Result.failure('Failed to fetch users: $e');
    }
  }

  /// Approve a user
  static Future<Result<void>> approveUser({
    required String userId,
    String? approverName,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Result.failure('Admin not authenticated');
      }

      // Get user data before approval
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return Result.failure('User not found');
      }

      final userData = userDoc.data()!;
      final userEmail = userData['email'] as String;
      final userName = userData['name'] as String;
      final userRole = userData['role'] as String;

      // Update user approval status
      await _firestore.collection('users').doc(userId).update({
        'approvalStatus': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': currentUser.uid,
        'rejectionReason': null, // Clear any previous rejection reason
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send approval email
      await _sendApprovalEmail(
        email: userEmail,
        userName: userName,
        userRole: userRole,
        approverName: approverName,
      );

      // Optionally send welcome email after approval (not at registration)
      try {
        if (EmailConfig.isConfigured && EmailConfig.enableWelcomeEmails) {
          await EmailService.sendWelcomeEmail(
            to: userEmail,
            toName: userName,
            userRole: userRole,
          );
        }
      } catch (e) {
        // Do not fail approval on email failure; just log
        ErrorReporter.reportError(
            'Failed to send welcome email after approval', e.toString());
      }

      return Result.success(null);
    } catch (e) {
      ErrorReporter.reportError('Failed to approve user', e.toString());
      return Result.failure('Failed to approve user: $e');
    }
  }

  /// Reject a user
  static Future<Result<void>> rejectUser({
    required String userId,
    required String rejectionReason,
    String? approverName,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Result.failure('Admin not authenticated');
      }

      // Get user data before rejection
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return Result.failure('User not found');
      }

      final userData = userDoc.data()!;
      final userEmail = userData['email'] as String;
      final userName = userData['name'] as String;
      final userRole = userData['role'] as String;

      // Update user approval status
      await _firestore.collection('users').doc(userId).update({
        'approvalStatus': 'rejected',
        'approvedAt': null,
        'approvedBy': currentUser.uid,
        'rejectionReason': rejectionReason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send rejection email
      await _sendRejectionEmail(
        email: userEmail,
        userName: userName,
        userRole: userRole,
        rejectionReason: rejectionReason,
        approverName: approverName,
      );

      return Result.success(null);
    } catch (e) {
      ErrorReporter.reportError('Failed to reject user', e.toString());
      return Result.failure('Failed to reject user: $e');
    }
  }

  /// Reset user approval status to pending
  static Future<Result<void>> resetUserApproval(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'approvalStatus': 'pending',
        'approvedAt': null,
        'approvedBy': null,
        'rejectionReason': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return Result.success(null);
    } catch (e) {
      ErrorReporter.reportError('Failed to reset user approval', e.toString());
      return Result.failure('Failed to reset user approval: $e');
    }
  }

  /// Check if user is approved
  static Future<Result<bool>> isUserApproved(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return Result.failure('User not found');
      }

      final approvalStatus = userDoc.data()?['approvalStatus'] as String?;
      return Result.success(approvalStatus == 'approved');
    } catch (e) {
      ErrorReporter.reportError(
          'Failed to check user approval status', e.toString());
      return Result.failure('Failed to check approval status: $e');
    }
  }

  /// Send approval email
  static Future<void> _sendApprovalEmail({
    required String email,
    required String userName,
    required String userRole,
    String? approverName,
  }) async {
    if (!EmailService.isInitialized) return;

    final roleDisplayName = _getRoleDisplayName(userRole);
    final approverText =
        approverName != null ? 'by $approverName' : 'by the admin team';

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account Approved - JobHunt</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { text-align: center; padding: 20px 0; border-bottom: 2px solid #28a745; }
        .logo { font-size: 24px; font-weight: bold; color: #28a745; }
        .content { padding: 30px 0; }
        .success { background-color: #d4edda; border: 1px solid #c3e6cb; padding: 15px; border-radius: 5px; margin: 20px 0; color: #155724; }
        .button { display: inline-block; padding: 12px 30px; background-color: #28a745; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
        .footer { text-align: center; padding: 20px 0; border-top: 1px solid #eee; color: #666; font-size: 14px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">JobHunt</div>
        </div>
        
        <div class="content">
            <h2>🎉 Account Approved!</h2>
            <p>Hello $userName,</p>
            
            <div class="success">
                <strong>Great news!</strong> Your JobHunt account has been approved $approverText.
            </div>
            
            <p>Your account as a <strong>$roleDisplayName</strong> has been successfully reviewed and approved. You can now access all features of the JobHunt platform.</p>
            
            <p><strong>What's next?</strong></p>
            <ul>
                <li>Sign in to your JobHunt account</li>
                <li>Complete your profile setup</li>
                <li>Start exploring job opportunities</li>
                <li>Connect with potential employers</li>
            </ul>
            
            <a href="${EmailConfig.appDomain}" class="button">Access JobHunt</a>
            
            <p>Welcome to the JobHunt community! We're excited to help you on your career journey.</p>
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
      subject: 'Account Approved - Welcome to JobHunt! 🎉',
      htmlContent: htmlContent,
      textContent: '''
Hello $userName,

Great news! Your JobHunt account has been approved $approverText.

Your account as a $roleDisplayName has been successfully reviewed and approved. You can now access all features of the JobHunt platform.

What's next:
- Sign in to your JobHunt account
- Complete your profile setup
- Start exploring job opportunities
- Connect with potential employers

Welcome to the JobHunt community!

Best regards,
The JobHunt Team
      ''',
    );
  }

  /// Send rejection email
  static Future<void> _sendRejectionEmail({
    required String email,
    required String userName,
    required String userRole,
    required String rejectionReason,
    String? approverName,
  }) async {
    if (!EmailService.isInitialized) return;

    final roleDisplayName = _getRoleDisplayName(userRole);
    final approverText =
        approverName != null ? 'by $approverName' : 'by the admin team';

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account Review Update - JobHunt</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { text-align: center; padding: 20px 0; border-bottom: 2px solid #dc3545; }
        .logo { font-size: 24px; font-weight: bold; color: #dc3545; }
        .content { padding: 30px 0; }
        .warning { background-color: #f8d7da; border: 1px solid #f5c6cb; padding: 15px; border-radius: 5px; margin: 20px 0; color: #721c24; }
        .button { display: inline-block; padding: 12px 30px; background-color: #007bff; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; }
        .footer { text-align: center; padding: 20px 0; border-top: 1px solid #eee; color: #666; font-size: 14px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">JobHunt</div>
        </div>
        
        <div class="content">
            <h2>Account Review Update</h2>
            <p>Hello $userName,</p>
            
            <p>Thank you for your interest in joining JobHunt as a $roleDisplayName.</p>
            
            <div class="warning">
                <strong>Account Status:</strong> After careful review $approverText, we are unable to approve your account at this time.
            </div>
            
            <p><strong>Reason:</strong> $rejectionReason</p>
            
            <p><strong>What you can do:</strong></p>
            <ul>
                <li>Review our terms of service and community guidelines</li>
                <li>Ensure all provided information is accurate and complete</li>
                <li>Contact our support team if you have questions</li>
                <li>You may reapply after addressing the concerns mentioned above</li>
            </ul>
            
            <a href="${EmailConfig.supportEmail}" class="button">Contact Support</a>
            
            <p>We appreciate your understanding and encourage you to reach out if you have any questions.</p>
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
      subject: 'Account Review Update - JobHunt',
      htmlContent: htmlContent,
      textContent: '''
Hello $userName,

Thank you for your interest in joining JobHunt as a $roleDisplayName.

After careful review $approverText, we are unable to approve your account at this time.

Reason: $rejectionReason

What you can do:
- Review our terms of service and community guidelines
- Ensure all provided information is accurate and complete
- Contact our support team if you have questions
- You may reapply after addressing the concerns mentioned above

We appreciate your understanding.

Best regards,
The JobHunt Team
      ''',
    );
  }

  /// Get role display name
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
