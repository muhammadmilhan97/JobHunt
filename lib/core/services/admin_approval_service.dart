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

      // Send single combined approval + welcome email (role-specific)
      await _sendApprovalEmail(
        email: userEmail,
        userName: userName,
        userRole: userRole,
        approverName: approverName,
      );

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

    // Use the new beautiful templates based on role
    if (userRole.toLowerCase() == 'employer') {
      // For employers, we need company name - get from user data
      try {
        final userQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        String companyName = userName; // Default fallback
        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs.first.data();
          companyName = userData['companyName'] ?? userData['name'] ?? userName;
        }

        await EmailService.sendAccountApprovedEmployerEmail(
          to: email,
          toName: userName,
          companyName: companyName,
        );
      } catch (e) {
        // Fallback to job seeker template if we can't get company name
        await EmailService.sendAccountApprovedJobSeekerEmail(
          to: email,
          toName: userName,
        );
      }
    } else {
      // For job seekers
      await EmailService.sendAccountApprovedJobSeekerEmail(
        to: email,
        toName: userName,
      );
    }
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

    // Use the new beautiful rejection template
    await EmailService.sendAccountRejectedEmail(
      to: email,
      toName: userName,
      reason: rejectionReason,
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
