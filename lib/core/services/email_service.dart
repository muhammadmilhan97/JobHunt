import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/email_template.dart';
import 'error_reporter.dart';

class EmailService {
  static const String _baseUrl = 'https://api.sendgrid.com/v3';
  static String? _apiKey;
  static bool _isInitialized = false;

  /// Initialize the EmailService with SendGrid API key
  static void initialize(String apiKey) {
    _apiKey = apiKey;
    _isInitialized = true;
    if (kDebugMode) {
      print('EmailService initialized successfully');
    }
  }

  /// Check if the service is properly initialized
  static bool get isInitialized => _isInitialized && _apiKey != null;

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
            'email': fromEmail ?? 'noreply@jobhunt.app',
            'name': fromName ?? 'JobHunt Team',
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
          print('Email sent successfully to $to');
        }
        return true;
      } else {
        ErrorReporter.reportError(
          'SendGrid API error: ${response.statusCode}',
          'Failed to send email via SendGrid API',
        );
        return false;
      }
    } catch (e, stackTrace) {
      ErrorReporter.reportError(
        'Failed to send email',
        'Exception occurred while sending email: ${e.toString()}',
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
            'email': fromEmail ?? 'noreply@jobhunt.app',
            'name': fromName ?? 'JobHunt Team',
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
          'Failed to send bulk emails via SendGrid API',
        );
        return false;
      }
    } catch (e, stackTrace) {
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
