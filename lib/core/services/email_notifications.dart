import 'package:flutter/foundation.dart';
import '../models/email_template.dart';
import 'vercel_email_service.dart';

class EmailNotifications {
  static const String _vercelBase =
      'https://jobhunt-email-j9a89tm1a-muhammad-milhans-projects.vercel.app';

  static String _brandHtml({
    required String title,
    required String bodyHtml,
    String? ctaText,
    String? ctaUrl,
  }) {
    final button = (ctaText != null && ctaUrl != null)
        ? '<a href="$ctaUrl" style="display:inline-block;padding:12px 20px;background:#2563EB;color:#ffffff;text-decoration:none;border-radius:6px;font-weight:600">$ctaText</a>'
        : '';

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>$title</title>
  <style>
    body{margin:0;padding:0;background:#f6f7fb;font-family:Inter,Segoe UI,Arial,sans-serif;color:#111827}
    .container{max-width:640px;margin:0 auto;padding:24px}
    .card{background:#ffffff;border-radius:12px;box-shadow:0 6px 16px rgba(0,0,0,.06);overflow:hidden}
    .header{background:linear-gradient(90deg,#2563EB,#4F46E5);padding:20px 24px;color:#ffffff}
    .logo{display:flex;align-items:center;gap:12px;font-weight:800;font-size:18px}
    .content{padding:24px}
    h1{margin:0 0 8px 0;font-size:22px}
    p{line-height:1.6;margin:0 0 14px 0;color:#374151}
    .footer{padding:18px 24px;border-top:1px solid #E5E7EB;color:#6B7280;font-size:12px}
  </style>
</head>
<body>
  <div class="container">
    <div class="card">
      <div class="header">
        <div class="logo">JobHunt</div>
      </div>
      <div class="content">
        <h1>$title</h1>
        $bodyHtml
        $button
      </div>
      <div class="footer">
        You are receiving this email from JobHunt. If this wasn’t you, please ignore.
      </div>
    </div>
  </div>
</body>
</html>
''';
  }

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
  }) async {
    final template = EmailTemplates.jobPostingConfirmation(
      recipientName: name,
      jobTitle: jobTitle,
      companyName: company,
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
