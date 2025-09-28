import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/email_template.dart';
import 'error_reporter.dart';
import 'email_logging_service.dart';
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

  /// Send a single email with logging and retry
  static Future<bool> sendEmail({
    required String to,
    required String toName,
    required String subject,
    required String htmlContent,
    String? textContent,
    String? fromEmail,
    String? fromName,
    String? emailType,
    Map<String, dynamic>? metadata,
  }) async {
    if (!isInitialized) {
      ErrorReporter.reportError(
        'EmailService not initialized',
        'EmailService initialization error',
      );
      await EmailLoggingService.logEmailSend(
        type: emailType ?? 'generic',
        to: to,
        templateId: 'unknown',
        status: 'failed',
        error: 'EmailService not initialized',
        metadata: metadata,
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

      // Log successful email send
      await EmailLoggingService.logEmailSend(
        type: emailType ?? 'generic',
        to: to,
        templateId: subject,
        status: 'sent',
        metadata: metadata,
      );

      return true;
    } catch (e) {
      ErrorReporter.reportError(
        'Email send failed',
        'Cloud Function email send failed: ${e.toString()}',
      );

      // Log failed email send
      await EmailLoggingService.logEmailSend(
        type: emailType ?? 'generic',
        to: to,
        templateId: subject,
        status: 'failed',
        error: e.toString(),
        metadata: metadata,
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

  /// Send OTP verification email (SKIPPED - Using PIN instead)
  static Future<bool> sendOtpEmail({
    required String to,
    required String toName,
    required String otpCode,
  }) async {
    // OTP emails are skipped as we use PIN authentication
    if (kDebugMode) {
      print('OTP email skipped - using PIN authentication instead');
    }
    return true;
  }

  /// Send welcome email (now handled by approval emails)
  static Future<bool> sendWelcomeEmail({
    required String to,
    required String toName,
    required String userRole,
  }) async {
    // Welcome emails are now handled by the approval process
    if (kDebugMode) {
      print('Welcome email handled by approval process');
    }
    return true;
  }

  /// Send account-created (pending approval) email - Job Seeker
  static Future<bool> sendAccountCreatedJobSeekerEmail({
    required String to,
    required String toName,
  }) async {
    final template = EmailTemplate.accountCreatedJobSeeker(
      recipientName: toName,
      email: to,
    );

    return await sendEmail(
      to: to,
      toName: toName,
      subject: 'Welcome to JobHunt - Account Created',
      htmlContent: template,
      textContent: EmailTemplate.getTextVersion(template),
      emailType: 'account_created_job_seeker',
      metadata: {'role': 'job_seeker'},
    );
  }

  /// Send account-created (pending approval) email - Employer
  static Future<bool> sendAccountCreatedEmployerEmail({
    required String to,
    required String toName,
    required String companyName,
  }) async {
    final template = EmailTemplate.accountCreatedEmployer(
      recipientName: toName,
      companyName: companyName,
      email: to,
    );

    return await sendEmail(
      to: to,
      toName: toName,
      subject: 'Welcome to JobHunt - Employer Account Created',
      htmlContent: template,
      textContent: EmailTemplate.getTextVersion(template),
      emailType: 'account_created_employer',
      metadata: {'role': 'employer', 'companyName': companyName},
    );
  }

  /// Send approval email (now includes welcome content for employers)
  static Future<bool> sendApprovalEmail({
    required String to,
    required String toName,
    required String userRole,
  }) async {
    // Use the new beautiful templates based on role
    if (userRole.toLowerCase() == 'employer') {
      // For employers, we need company name - this should be passed from the calling code
      return await sendAccountApprovedEmployerEmail(
        to: to,
        toName: toName,
        companyName: 'Your Company', // This should be passed from calling code
      );
    } else {
      return await sendAccountApprovedJobSeekerEmail(
        to: to,
        toName: toName,
      );
    }
  }

  /// Send rejection email
  static Future<bool> sendRejectionEmail({
    required String to,
    required String toName,
    required String userRole,
    required String reason,
  }) async {
    return await sendAccountRejectedEmail(
      to: to,
      toName: toName,
      reason: reason,
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
    return await sendApplicationStatusUpdateEmail(
      to: to,
      toName: toName,
      jobTitle: jobTitle,
      companyName: companyName,
      status: status,
      applicationId: 'unknown', // This should be passed from calling code
    );
  }

  /// Send job alerts to multiple recipients
  static Future<bool> sendJobAlerts({
    required List<EmailRecipient> recipients,
    required List<Map<String, dynamic>> newJobs,
  }) async {
    // Convert to the new format
    final jobs = newJobs
        .map((job) => <String, String>{
              'title': (job['title'] ?? 'Job Title').toString(),
              'company': (job['company'] ?? 'Company').toString(),
              'location': (job['location'] ?? 'Location').toString(),
              'salary': (job['salary'] ?? 'Salary').toString(),
              'url': (job['url'] ?? 'https://jobhunt.pk/jobs').toString(),
            })
        .toList();

    // Send individual emails using the new template
    for (final recipient in recipients) {
      await sendJobAlertsEmail(
        to: recipient.email,
        toName: recipient.name,
        jobs: jobs,
      );
    }
    return true;
  }

  /// Send weekly digest to a single recipient
  static Future<bool> sendWeeklyDigest({
    required String to,
    required String toName,
    required String category,
    required List<Map<String, dynamic>> jobs,
  }) async {
    // Convert to the new format
    final featuredJobs = jobs
        .map((job) => <String, String>{
              'title': (job['title'] ?? 'Job Title').toString(),
              'company': (job['company'] ?? 'Company').toString(),
              'location': (job['location'] ?? 'Location').toString(),
              'salary': (job['salary'] ?? 'Salary').toString(),
              'type': (job['type'] ?? 'Full-time').toString(),
              'url': (job['url'] ?? 'https://jobhunt.pk/jobs').toString(),
            })
        .toList();

    final stats = {
      'newJobs': jobs.length,
      'companiesHiring': jobs.map((j) => j['company']).toSet().length,
      'avgApplications': 15, // Mock data
      'hotSkills': 'Flutter, React, Python',
      'remotePercentage': 45,
      'salaryIncrease': 12,
      'topSkills': 'Flutter, React, Python',
      'hiringTimeline': 14,
      'userApplications': 3, // Mock data
    };

    final trendingCompanies = [
      {'name': 'TechCorp', 'openings': '5'},
      {'name': 'StartupXYZ', 'openings': '3'},
      {'name': 'BigCompany', 'openings': '8'},
    ];

    return await sendWeeklyJobDigestEmail(
      to: to,
      toName: toName,
      stats: stats,
      featuredJobs: featuredJobs,
      trendingCompanies: trendingCompanies,
    );
  }

  // ===== NEW BEAUTIFUL EMAIL TEMPLATES =====

  /// Send account approved email - Job Seeker
  static Future<bool> sendAccountApprovedJobSeekerEmail({
    required String to,
    required String toName,
  }) async {
    final template = EmailTemplate.accountApprovedJobSeeker(
      recipientName: toName,
    );

    return await sendEmail(
      to: to,
      toName: toName,
      subject: 'Account Approved! 🎉',
      htmlContent: template,
      textContent: EmailTemplate.getTextVersion(template),
      emailType: 'account_approved_job_seeker',
      metadata: {'role': 'job_seeker'},
    );
  }

  /// Send account approved email - Employer
  static Future<bool> sendAccountApprovedEmployerEmail({
    required String to,
    required String toName,
    required String companyName,
  }) async {
    final template = EmailTemplate.accountApprovedEmployer(
      recipientName: toName,
      companyName: companyName,
    );

    return await sendEmail(
      to: to,
      toName: toName,
      subject: 'Account Approved! 🎉',
      htmlContent: template,
      textContent: EmailTemplate.getTextVersion(template),
      emailType: 'account_approved_employer',
      metadata: {'role': 'employer', 'companyName': companyName},
    );
  }

  /// Send account rejected email
  static Future<bool> sendAccountRejectedEmail({
    required String to,
    required String toName,
    required String reason,
  }) async {
    final template = EmailTemplate.accountRejected(
      recipientName: toName,
      reason: reason,
    );

    return await sendEmail(
      to: to,
      toName: toName,
      subject: 'Account Review Update',
      htmlContent: template,
      textContent: EmailTemplate.getTextVersion(template),
      emailType: 'account_rejected',
      metadata: {'reason': reason},
    );
  }

  /// Send job posting confirmation email
  static Future<bool> sendJobPostingConfirmationEmail({
    required String to,
    required String toName,
    required String companyName,
    required String jobTitle,
    required String jobId,
    required String location,
    required String salary,
    required String jobType,
  }) async {
    final template = EmailTemplate.jobPostingConfirmation(
      recipientName: toName,
      companyName: companyName,
      jobTitle: jobTitle,
      jobId: jobId,
      location: location,
      salary: salary,
      jobType: jobType,
    );

    return await sendEmail(
      to: to,
      toName: toName,
      subject: 'Job Posted Successfully! 🎉',
      htmlContent: template,
      textContent: EmailTemplate.getTextVersion(template),
      emailType: 'job_posting_confirmation',
      metadata: {
        'jobId': jobId,
        'jobTitle': jobTitle,
        'companyName': companyName,
      },
    );
  }

  /// Send application status update email
  static Future<bool> sendApplicationStatusUpdateEmail({
    required String to,
    required String toName,
    required String jobTitle,
    required String companyName,
    required String status,
    required String applicationId,
    String? interviewDate,
    String? interviewTime,
    String? notes,
  }) async {
    final template = EmailTemplate.applicationStatusUpdate(
      recipientName: toName,
      jobTitle: jobTitle,
      companyName: companyName,
      status: status,
      applicationId: applicationId,
      interviewDate: interviewDate,
      interviewTime: interviewTime,
      notes: notes,
    );

    return await sendEmail(
      to: to,
      toName: toName,
      subject: 'Application Status Update',
      htmlContent: template,
      textContent: EmailTemplate.getTextVersion(template),
      emailType: 'application_status_update',
      metadata: {
        'applicationId': applicationId,
        'jobTitle': jobTitle,
        'status': status,
      },
    );
  }

  /// Send job alerts email
  static Future<bool> sendJobAlertsEmail({
    required String to,
    required String toName,
    required List<Map<String, String>> jobs,
  }) async {
    final template = EmailTemplate.jobAlerts(
      recipientName: toName,
      jobs: jobs,
    );

    return await sendEmail(
      to: to,
      toName: toName,
      subject: 'New Jobs Matching Your Profile! 🔥',
      htmlContent: template,
      textContent: EmailTemplate.getTextVersion(template),
      emailType: 'job_alerts',
      metadata: {'jobCount': jobs.length},
    );
  }

  /// Send weekly job digest email
  static Future<bool> sendWeeklyJobDigestEmail({
    required String to,
    required String toName,
    required Map<String, dynamic> stats,
    required List<Map<String, String>> featuredJobs,
    required List<Map<String, String>> trendingCompanies,
  }) async {
    final template = EmailTemplate.weeklyJobDigest(
      recipientName: toName,
      stats: stats,
      featuredJobs: featuredJobs,
      trendingCompanies: trendingCompanies,
    );

    return await sendEmail(
      to: to,
      toName: toName,
      subject: 'Weekly Job Digest 📊',
      htmlContent: template,
      textContent: EmailTemplate.getTextVersion(template),
      emailType: 'weekly_digest',
      metadata: {'featuredJobsCount': featuredJobs.length},
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
