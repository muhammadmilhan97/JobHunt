import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/email_template.dart';
import 'error_reporter.dart';
import '../config/email_config.dart';

class EmailService {
  static bool _isInitialized = false;
  static FirebaseFunctions? _functions;

  /// Initialize the EmailService (Cloud Functions/Gmail SMTP)
  static void initialize([String? _unused]) {
    _isInitialized = true;
    try {
      _functions = FirebaseFunctions.instance;
    } catch (_) {
      _functions = null;
    }
    if (kDebugMode) {
      print('EmailService initialized (Cloud Functions via Gmail SMTP)');
    }
  }

  /// Check if the service is properly initialized
  static bool get isInitialized => _isInitialized;

  /// Send a single email
  static Future<bool> sendEmail({
    required String to,
    required String toName,
    required String subject,
    required String htmlContent,
    String? textContent,
    String? fromEmail,
    String? fromName,
  }) async {
    if (!isInitialized) {
      ErrorReporter.reportError(
        'EmailService not initialized',
        'EmailService initialization error',
      );
      return false;
    }

    // Use Cloud Functions callable for SMTP via Gmail
    try {
      final callable = (_functions ?? FirebaseFunctions.instance)
          .httpsCallable('sendEmailViaHttps');
      final result = await callable.call({
        'to': to,
        'toName': toName,
        'subject': subject,
        'htmlContent': htmlContent,
        'textContent': textContent,
        'fromEmail': fromEmail ?? EmailConfig.defaultFromEmail,
        'fromName': fromName ?? EmailConfig.defaultFromName,
      });
      if (kDebugMode) {
        print('Email sent via Cloud Function to $to: ${result.data}');
      }
      return true;
    } catch (e) {
      ErrorReporter.reportError(
        'Email send failed',
        'Cloud Function email send failed: ${e.toString()}',
      );
      return false;
    }
  }

  /// Send bulk emails (for job alerts)
  static Future<bool> sendBulkEmails({
    required List<EmailRecipient> recipients,
    required String subject,
    required String htmlTemplate,
    String? textTemplate,
    String? fromEmail,
    String? fromName,
  }) async {
    if (!isInitialized) {
      ErrorReporter.reportError(
        'EmailService not initialized',
        'EmailService initialization error',
      );
      return false;
    }

    // Loop through recipients and call sendEmail via Cloud Function
    var allSucceeded = true;
    for (final recipient in recipients) {
      final ok = await sendEmail(
        to: recipient.email,
        toName: recipient.name,
        subject: subject,
        htmlContent: htmlTemplate,
        textContent: textTemplate,
        fromEmail: fromEmail,
        fromName: fromName,
      );
      if (!ok) allSucceeded = false;
      // Gentle pacing to avoid rapid-fire callable invocations
      await Future.delayed(const Duration(milliseconds: 50));
    }
    if (kDebugMode) {
      print(
          'Bulk emails attempted for ${recipients.length} recipients. Success: $allSucceeded');
    }
    return allSucceeded;
  }

  /// Send OTP verification email
  static Future<bool> sendOtpEmail({
    required String to,
    required String toName,
    required String otpCode,
  }) async {
    final template = EmailTemplates.otpVerification(
      recipientName: toName,
      otpCode: otpCode,
    );

    return await sendEmail(
      to: to,
      toName: toName,
      subject: template.subject,
      htmlContent: template.htmlContent,
      textContent: template.textContent,
    );
  }

  /// Send welcome email
  static Future<bool> sendWelcomeEmail({
    required String to,
    required String toName,
    required String userRole,
  }) async {
    final template = EmailTemplates.welcome(
      recipientName: toName,
      userRole: userRole,
    );

    return await sendEmail(
      to: to,
      toName: toName,
      subject: template.subject,
      htmlContent: template.htmlContent,
      textContent: template.textContent,
    );
  }

  /// Send account-created (pending approval) email
  static Future<bool> sendAccountCreatedEmail({
    required String to,
    required String toName,
    required String userRole,
  }) async {
    final template = EmailTemplates.accountCreated(
      recipientName: toName,
      userRole: userRole,
    );

    return await sendEmail(
      to: to,
      toName: toName,
      subject: template.subject,
      htmlContent: template.htmlContent,
      textContent: template.textContent,
    );
  }

  /// Send approval email
  static Future<bool> sendApprovalEmail({
    required String to,
    required String toName,
    required String userRole,
  }) async {
    final template = EmailTemplates.approval(
      recipientName: toName,
      userRole: userRole,
    );

    final sent = await sendEmail(
      to: to,
      toName: toName,
      subject: template.subject,
      htmlContent: template.htmlContent,
      textContent: template.textContent,
    );

    // Also send welcome email after approval
    if (sent) {
      await sendWelcomeEmail(to: to, toName: toName, userRole: userRole);
    }

    return sent;
  }

  /// Send rejection email
  static Future<bool> sendRejectionEmail({
    required String to,
    required String toName,
    required String userRole,
    required String reason,
  }) async {
    final template = EmailTemplates.rejection(
      recipientName: toName,
      userRole: userRole,
      reason: reason,
    );

    return await sendEmail(
      to: to,
      toName: toName,
      subject: template.subject,
      htmlContent: template.htmlContent,
      textContent: template.textContent,
    );
  }

  /// Send application status email
  static Future<bool> sendApplicationStatusEmail({
    required String to,
    required String toName,
    required String jobTitle,
    required String companyName,
    required String status,
  }) async {
    final template = EmailTemplates.applicationStatus(
      recipientName: toName,
      jobTitle: jobTitle,
      companyName: companyName,
      status: status,
    );

    return await sendEmail(
      to: to,
      toName: toName,
      subject: template.subject,
      htmlContent: template.htmlContent,
      textContent: template.textContent,
    );
  }

  /// Send job posting confirmation email
  static Future<bool> sendJobPostingConfirmation({
    required String to,
    required String toName,
    required String jobTitle,
    required String companyName,
  }) async {
    final template = EmailTemplates.jobPostingConfirmation(
      recipientName: toName,
      jobTitle: jobTitle,
      companyName: companyName,
    );

    return await sendEmail(
      to: to,
      toName: toName,
      subject: template.subject,
      htmlContent: template.htmlContent,
      textContent: template.textContent,
    );
  }

  /// Send job alerts to multiple recipients
  static Future<bool> sendJobAlerts({
    required List<EmailRecipient> recipients,
    required List<Map<String, dynamic>> newJobs,
  }) async {
    final template = EmailTemplates.jobAlert(newJobs: newJobs);

    return await sendBulkEmails(
      recipients: recipients,
      subject: template.subject,
      htmlTemplate: template.htmlContent,
      textTemplate: template.textContent,
    );
  }

  /// Send weekly digest to a single recipient
  static Future<bool> sendWeeklyDigest({
    required String to,
    required String toName,
    required String category,
    required List<Map<String, dynamic>> jobs,
  }) async {
    final template = EmailTemplates.weeklyDigest(
      recipientName: toName,
      category: category,
      jobs: jobs,
    );

    return await sendEmail(
      to: to,
      toName: toName,
      subject: template.subject,
      htmlContent: template.htmlContent,
      textContent: template.textContent,
    );
  }
}

class EmailRecipient {
  final String email;
  final String name;
  final Map<String, String> substitutions;

  const EmailRecipient({
    required this.email,
    required this.name,
    this.substitutions = const {},
  });
}
