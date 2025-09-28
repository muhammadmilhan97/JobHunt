import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailLoggingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference<Map<String, dynamic>> _emailLogsCollection =
      _firestore.collection('email_logs');

  /// Log email send attempt
  static Future<void> logEmailSend({
    required String type,
    required String to,
    required String templateId,
    required String status,
    String? error,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _emailLogsCollection.add({
        'type':
            type, // 'account_created', 'approval', 'job_posting_confirmation', etc.
        'to': to,
        'templateId': templateId,
        'status': status, // 'sent', 'failed', 'retry'
        'error': error,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
    } catch (e) {
      // Don't fail email sending if logging fails
      print('Failed to log email: $e');
    }
  }

  /// Get email logs for debugging
  static Future<List<Map<String, dynamic>>> getEmailLogs({
    String? type,
    String? status,
    int limit = 50,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _emailLogsCollection
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('Failed to get email logs: $e');
      return [];
    }
  }

  /// Retry failed emails
  static Future<void> retryFailedEmails() async {
    try {
      final failedEmails = await getEmailLogs(status: 'failed');

      for (final emailLog in failedEmails) {
        // Implement retry logic based on email type
        final type = emailLog['type'] as String;
        final to = emailLog['to'] as String;
        final metadata = emailLog['metadata'] as Map<String, dynamic>? ?? {};

        // Log retry attempt
        await logEmailSend(
          type: type,
          to: to,
          templateId: emailLog['templateId'] as String,
          status: 'retry',
          metadata: metadata,
        );

        // TODO: Implement actual retry logic based on email type
        print('Retrying email: $type to $to');
      }
    } catch (e) {
      print('Failed to retry emails: $e');
    }
  }
}
