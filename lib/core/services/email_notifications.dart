import 'package:flutter/foundation.dart';
import '../models/email_template.dart';
import 'vercel_email_service.dart';

class EmailNotifications {
  static const String _vercelBase =
      'https://jobhunt-email-j9a89tm1a-muhammad-milhans-projects.vercel.app';

  static Future<void> _send({
    required String to,
    required String subject,
    required String html,
    String? text,
  }) async {
    if (to.isEmpty) return;
    try {
      await VercelEmailService.send(
        endpoint: '$_vercelBase/api/send-email',
        to: to,
        subject: subject,
        html: html,
        text: text,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('EmailNotifications error: $e');
      }
    }
  }

  static Future<void> onAccountCreated({
    required String to,
    required String name,
    required String role,
  }) async {
    String html;
    String subject;
    String text;

    if (role.toLowerCase() == 'employer') {
      html = EmailTemplate.accountCreatedEmployer(
        recipientName: name,
        companyName: name, // Default fallback
        email: to,
      );
      subject = 'Welcome to JobHunt - Employer Account Created';
    } else {
      html = EmailTemplate.accountCreatedJobSeeker(
        recipientName: name,
        email: to,
      );
      subject = 'Welcome to JobHunt - Account Created';
    }

    text = EmailTemplate.getTextVersion(html);

    await _send(
      to: to,
      subject: subject,
      html: html,
      text: text,
    );
  }

  static Future<void> onApproved({
    required String to,
    required String name,
    required String role,
  }) async {
    String html;
    String subject;
    String text;

    if (role.toLowerCase() == 'employer') {
      html = EmailTemplate.accountApprovedEmployer(
        recipientName: name,
        companyName: name, // Default fallback
      );
      subject = 'Account Approved! 🎉';
    } else {
      html = EmailTemplate.accountApprovedJobSeeker(
        recipientName: name,
      );
      subject = 'Account Approved! 🎉';
    }

    text = EmailTemplate.getTextVersion(html);

    await _send(
      to: to,
      subject: subject,
      html: html,
      text: text,
    );
  }

  static Future<void> onRejected({
    required String to,
    required String name,
    required String role,
    required String reason,
  }) async {
    final html = EmailTemplate.accountRejected(
      recipientName: name,
      reason: reason,
    );
    final subject = 'Account Review Update';
    final text = EmailTemplate.getTextVersion(html);

    await _send(
      to: to,
      subject: subject,
      html: html,
      text: text,
    );
  }

  static Future<void> onWelcome({
    required String to,
    required String name,
    required String role,
  }) async {
    // Welcome emails are now handled by the approval process
    // This method is kept for backward compatibility but does nothing
    if (kDebugMode) {
      print('Welcome email handled by approval process');
    }
  }

  static Future<void> onJobPosted({
    required String to,
    required String name,
    required String jobTitle,
    required String company,
    required String jobId,
  }) async {
    final html = EmailTemplate.jobPostingConfirmation(
      recipientName: name,
      companyName: company,
      jobTitle: jobTitle,
      jobId: jobId,
      location: 'Location', // Default fallback
      salary: 'Salary Range', // Default fallback
      jobType: 'Full-time', // Default fallback
    );
    final subject = 'Job Posted Successfully! 🎉';
    final text = EmailTemplate.getTextVersion(html);

    await _send(
      to: to,
      subject: subject,
      html: html,
      text: text,
    );
  }

  static Future<void> onApplicationStatus({
    required String to,
    required String name,
    required String jobTitle,
    required String company,
    required String status,
  }) async {
    final html = EmailTemplate.applicationStatusUpdate(
      recipientName: name,
      jobTitle: jobTitle,
      companyName: company,
      status: status,
      applicationId: 'unknown', // Default fallback
    );
    final subject = 'Application Status Update';
    final text = EmailTemplate.getTextVersion(html);

    await _send(
      to: to,
      subject: subject,
      html: html,
      text: text,
    );
  }
}
