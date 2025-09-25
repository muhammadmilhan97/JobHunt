import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/email_template.dart';
import 'error_reporter.dart';
import '../config/email_config.dart';

class EmailService {
  static const String _baseUrl = 'https://api.sendgrid.com/v3';
  static String? _apiKey;
  static bool _isInitialized = false;
  static FirebaseFunctions? _functions;

  /// Initialize the EmailService
  /// SendGrid path kept for backward compatibility; not required for SMTP via CF.
  static void initialize([String? apiKey]) {
    _apiKey = apiKey;
    _isInitialized = true;
    try {
      _functions = FirebaseFunctions.instance;
    } catch (_) {
      _functions = null;
    }
    if (kDebugMode) {
      print('EmailService initialized (Cloud Functions + optional SendGrid)');
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

    // Prefer Cloud Functions callable for SMTP via Gmail
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
      // Fallback to SendGrid (legacy) if configured
      if (_apiKey?.isNotEmpty == true) {
        try {
          final response = await http.post(
            Uri.parse('$_baseUrl/mail/send'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'personalizations': [
                {
                  'to': [
                    {
                      'email': to,
                      'name': toName,
                    }
                  ],
                }
              ],
              'from': {
                'email': fromEmail ?? EmailConfig.defaultFromEmail,
                'name': fromName ?? EmailConfig.defaultFromName,
              },
              'subject': subject,
              'content': [
                if (textContent != null)
                  {
                    'type': 'text/plain',
                    'value': textContent,
                  },
                {
                  'type': 'text/html',
                  'value': htmlContent,
                },
              ],
            }),
          );
          if (response.statusCode == 202) {
            if (kDebugMode) {
              print('Email sent successfully to $to via SendGrid fallback');
            }
            return true;
          }
        } catch (_) {}
      }
      ErrorReporter.reportError(
        'Email send failed',
        'Both Cloud Function and SendGrid fallback failed: ${e.toString()}',
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

    try {
      final personalizations = recipients
          .map((recipient) => {
                'to': [
                  {
                    'email': recipient.email,
                    'name': recipient.name,
                  }
                ],
                'substitutions': recipient.substitutions,
              })
          .toList();

      final response = await http.post(
        Uri.parse('$_baseUrl/mail/send'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': personalizations,
          'from': {
            'email': fromEmail ?? EmailConfig.defaultFromEmail,
            'name': fromName ?? EmailConfig.defaultFromName,
          },
          'subject': subject,
          'content': [
            if (textTemplate != null)
              {
                'type': 'text/plain',
                'value': textTemplate,
              },
            {
              'type': 'text/html',
              'value': htmlTemplate,
            },
          ],
        }),
      );

      if (response.statusCode == 202) {
        if (kDebugMode) {
          print(
              'Bulk emails sent successfully to ${recipients.length} recipients');
        }
        return true;
      } else {
        ErrorReporter.reportError(
          'SendGrid bulk email API error: ${response.statusCode}',
          'Failed to send bulk emails via SendGrid API. Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      ErrorReporter.reportError(
        'Failed to send bulk emails',
        'Exception occurred while sending bulk emails: ${e.toString()}',
      );
      return false;
    }
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
