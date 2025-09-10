import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'email_service.dart';
import 'error_reporter.dart';

class OtpService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate a 6-digit OTP code
  static String generateOtpCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Send OTP to user's email and store in Firestore
  static Future<bool> sendOtp({
    required String email,
    required String userName,
    required String purpose, // 'email_verification', 'password_reset', etc.
  }) async {
    try {
      final otpCode = generateOtpCode();
      final expiresAt = DateTime.now().add(const Duration(minutes: 10));

      // Store OTP in Firestore
      await _firestore.collection('otps').doc(email).set({
        'code': otpCode,
        'email': email,
        'purpose': purpose,
        'expiresAt': expiresAt,
        'createdAt': FieldValue.serverTimestamp(),
        'verified': false,
        'attempts': 0,
      });

      // Send email
      final emailSent = await EmailService.sendOtpEmail(
        to: email,
        toName: userName,
        otpCode: otpCode,
      );

      if (!emailSent) {
        // Clean up if email failed
        await _firestore.collection('otps').doc(email).delete();
        return false;
      }

      if (kDebugMode) {
        print('OTP sent to $email: $otpCode (expires at $expiresAt)');
      }

      return true;
    } catch (e, stackTrace) {
      ErrorReporter.reportError(
        'Failed to send OTP',
        'Exception occurred while sending OTP: ${e.toString()}',
      );
      return false;
    }
  }

  /// Verify OTP code
  static Future<OtpVerificationResult> verifyOtp({
    required String email,
    required String otpCode,
    required String purpose,
  }) async {
    try {
      final otpDoc = await _firestore.collection('otps').doc(email).get();

      if (!otpDoc.exists) {
        return OtpVerificationResult.notFound;
      }

      final otpData = otpDoc.data()!;
      final storedCode = otpData['code'] as String;
      final storedPurpose = otpData['purpose'] as String;
      final expiresAt = (otpData['expiresAt'] as Timestamp).toDate();
      final verified = otpData['verified'] as bool;
      final attempts = (otpData['attempts'] as int?) ?? 0;

      // Check if already verified
      if (verified) {
        return OtpVerificationResult.alreadyUsed;
      }

      // Check if expired
      if (DateTime.now().isAfter(expiresAt)) {
        await _firestore.collection('otps').doc(email).delete();
        return OtpVerificationResult.expired;
      }

      // Check if purpose matches
      if (storedPurpose != purpose) {
        return OtpVerificationResult.invalidPurpose;
      }

      // Check attempts limit (max 5 attempts)
      if (attempts >= 5) {
        await _firestore.collection('otps').doc(email).delete();
        return OtpVerificationResult.tooManyAttempts;
      }

      // Increment attempts
      await _firestore.collection('otps').doc(email).update({
        'attempts': attempts + 1,
      });

      // Verify code
      if (storedCode == otpCode) {
        // Mark as verified
        await _firestore.collection('otps').doc(email).update({
          'verified': true,
          'verifiedAt': FieldValue.serverTimestamp(),
        });

        if (kDebugMode) {
          print('OTP verified successfully for $email');
        }

        return OtpVerificationResult.success;
      } else {
        return OtpVerificationResult.invalid;
      }
    } catch (e, stackTrace) {
      ErrorReporter.reportError(
        'Failed to verify OTP',
        'Exception occurred while verifying OTP: ${e.toString()}',
      );
      return OtpVerificationResult.error;
    }
  }

  /// Clean up expired OTPs (call this periodically)
  static Future<void> cleanupExpiredOtps() async {
    try {
      final expiredQuery = await _firestore
          .collection('otps')
          .where('expiresAt', isLessThan: DateTime.now())
          .get();

      final batch = _firestore.batch();
      for (final doc in expiredQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (kDebugMode && expiredQuery.docs.isNotEmpty) {
        print('Cleaned up ${expiredQuery.docs.length} expired OTPs');
      }
    } catch (e, stackTrace) {
      ErrorReporter.reportError(
        'Failed to cleanup expired OTPs',
        'Exception occurred while cleaning up expired OTPs: ${e.toString()}',
      );
    }
  }

  /// Resend OTP (with rate limiting)
  static Future<OtpResendResult> resendOtp({
    required String email,
    required String userName,
    required String purpose,
  }) async {
    try {
      final otpDoc = await _firestore.collection('otps').doc(email).get();

      if (otpDoc.exists) {
        final otpData = otpDoc.data()!;
        final createdAt = (otpData['createdAt'] as Timestamp).toDate();
        final timeSinceCreation = DateTime.now().difference(createdAt);

        // Rate limit: allow resend only after 1 minute
        if (timeSinceCreation.inMinutes < 1) {
          return OtpResendResult.rateLimited;
        }
      }

      // Send new OTP
      final success = await sendOtp(
        email: email,
        userName: userName,
        purpose: purpose,
      );

      return success ? OtpResendResult.success : OtpResendResult.failed;
    } catch (e, stackTrace) {
      ErrorReporter.reportError(
        'Failed to resend OTP',
        'Exception occurred while resending OTP: ${e.toString()}',
      );
      return OtpResendResult.failed;
    }
  }
}

enum OtpVerificationResult {
  success,
  invalid,
  expired,
  notFound,
  alreadyUsed,
  invalidPurpose,
  tooManyAttempts,
  error,
}

enum OtpResendResult {
  success,
  rateLimited,
  failed,
}

extension OtpVerificationResultExtension on OtpVerificationResult {
  String get message {
    switch (this) {
      case OtpVerificationResult.success:
        return 'OTP verified successfully';
      case OtpVerificationResult.invalid:
        return 'Invalid OTP code';
      case OtpVerificationResult.expired:
        return 'OTP code has expired';
      case OtpVerificationResult.notFound:
        return 'OTP not found. Please request a new one';
      case OtpVerificationResult.alreadyUsed:
        return 'OTP has already been used';
      case OtpVerificationResult.invalidPurpose:
        return 'Invalid OTP purpose';
      case OtpVerificationResult.tooManyAttempts:
        return 'Too many attempts. Please request a new OTP';
      case OtpVerificationResult.error:
        return 'Error verifying OTP. Please try again';
    }
  }

  bool get isSuccess => this == OtpVerificationResult.success;
}

extension OtpResendResultExtension on OtpResendResult {
  String get message {
    switch (this) {
      case OtpResendResult.success:
        return 'OTP sent successfully';
      case OtpResendResult.rateLimited:
        return 'Please wait before requesting another OTP';
      case OtpResendResult.failed:
        return 'Failed to send OTP. Please try again';
    }
  }

  bool get isSuccess => this == OtpResendResult.success;
}
