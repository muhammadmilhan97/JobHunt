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
    final template = EmailTemplates.accountCreated(
      recipientName: name,
      userRole: role,
    );
    final html = template.htmlContent;
    await _send(
      to: to,
      subject: template.subject,
      html: html,
      text: template.textContent ??
          'Hello $name, your account has been created and is pending admin approval. We will notify you once approved.',
    );
  }

  static Future<void> onApproved({
    required String to,
    required String name,
    required String role,
  }) async {
    final template = EmailTemplates.approval(
      recipientName: name,
      userRole: role,
    );
    final html = template.htmlContent;
    await _send(
      to: to,
      subject: template.subject,
      html: html,
      text: template.textContent ??
          'Hello $name, your account as a $role has been approved.',
    );
    await onWelcome(to: to, name: name, role: role);
  }

  static Future<void> onRejected({
    required String to,
    required String name,
    required String role,
    required String reason,
  }) async {
    final template = EmailTemplates.rejection(
      recipientName: name,
      userRole: role,
      reason: reason,
    );
    final html = template.htmlContent;
    await _send(
      to: to,
      subject: template.subject,
      html: html,
      text: template.textContent ??
          'Hello $name, we are unable to approve your account. Reason: $reason',
    );
  }

  static Future<void> onWelcome({
    required String to,
    required String name,
    required String role,
  }) async {
    final template = EmailTemplates.welcome(
      recipientName: name,
      userRole: role,
    );
    final html = template.htmlContent;
    await _send(
      to: to,
      subject: 'Welcome to JobHunt',
      html: html,
      text: template.textContent ??
          'Hello $name, welcome to JobHunt! Explore jobs and complete your profile.',
    );
  }

  static Future<void> onJobPosted({
    required String to,
    required String name,
    required String jobTitle,
    required String company,
    required String jobId,
  }) async {
    final template = EmailTemplates.jobPostingConfirmation(
      recipientName: name,
      jobTitle: jobTitle,
      companyName: company,
      jobId: jobId,
    );
    final html = template.htmlContent;
    await _send(
      to: to,
      subject: template.subject,
      html: html,
      text: template.textContent ??
          'Hello $name, your job $jobTitle at $company has been posted.',
    );
  }

  static Future<void> onApplicationStatus({
    required String to,
    required String name,
    required String jobTitle,
    required String company,
    required String status,
  }) async {
    final template = EmailTemplates.applicationStatus(
      recipientName: name,
      jobTitle: jobTitle,
      companyName: company,
      status: status,
    );
    final html = template.htmlContent;
    await _send(
      to: to,
      subject: template.subject,
      html: html,
      text: template.textContent ??
          'Hello $name, your application for $jobTitle at $company is now $status.',
    );
  }
}
