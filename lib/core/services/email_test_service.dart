import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailTestService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Test email sending with Gmail SMTP
  static Future<Map<String, dynamic>> testEmail({
    required String to,
    required String subject,
    required String message,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'error': 'User not authenticated',
        };
      }

      final callable = _functions.httpsCallable('testEmail');
      final result = await callable.call({
        'to': to,
        'subject': subject,
        'message': message,
      });

      return {
        'success': true,
        'data': result.data,
      };
    } catch (e) {
      // Handle specific Firebase Functions errors
      String errorMessage = e.toString();
      if (errorMessage.contains('NOT_FOUND')) {
        errorMessage = 'Cloud Functions not deployed yet. Please deploy functions first.';
      } else if (errorMessage.contains('UNAVAILABLE')) {
        errorMessage = 'Cloud Functions service is unavailable. Please try again later.';
      } else if (errorMessage.contains('DEADLINE_EXCEEDED')) {
        errorMessage = 'Request timed out. Please try again.';
      }
      
      return {
        'success': false,
        'error': errorMessage,
      };
    }
  }
}
