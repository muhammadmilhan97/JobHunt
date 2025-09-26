class EmailTemplate {
  final String subject;
  final String htmlContent;
  final String? textContent;

  const EmailTemplate({
    required this.subject,
    required this.htmlContent,
    this.textContent,
  });
}

class EmailTemplates {
  // Brand colors and styling
  static const String _primaryColor = '#2563eb';
  static const String _secondaryColor = '#f8fafc';
  static const String _textColor = '#374151';
  static const String _logoUrl =
      'https://res.cloudinary.com/dd09znqy6/image/upload/v1758813785/JobHunt_Logo_vvzell.png';

  /// Base HTML template with branding
  static String _baseTemplate({
    required String title,
    required String content,
  }) {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            line-height: 1.6;
            color: $_textColor;
            margin: 0;
            padding: 0;
            background-color: #f9fafb;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header {
            background: linear-gradient(135deg, $_primaryColor 0%, #1d4ed8 100%);
            padding: 40px 20px;
            text-align: center;
        }
        .logo {
            max-width: 120px;
            height: auto;
            margin-bottom: 20px;
        }
        .header h1 {
            color: white;
            margin: 0;
            font-size: 28px;
            font-weight: 600;
        }
        .content {
            padding: 40px 20px;
        }
        .content h2 {
            color: $_primaryColor;
            margin-top: 0;
            font-size: 24px;
            font-weight: 600;
        }
        .content p {
            margin: 16px 0;
            font-size: 16px;
        }
        .button {
            display: inline-block;
            background-color: $_primaryColor;
            color: white;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 6px;
            font-weight: 600;
            margin: 20px 0;
        }
        .otp-code {
            background-color: $_secondaryColor;
            border: 2px dashed $_primaryColor;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            margin: 20px 0;
            font-size: 32px;
            font-weight: bold;
            letter-spacing: 8px;
            color: $_primaryColor;
        }
        .job-card {
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            padding: 20px;
            margin: 16px 0;
            background-color: #fafafa;
        }
        .job-title {
            font-size: 18px;
            font-weight: 600;
            color: $_primaryColor;
            margin: 0 0 8px 0;
        }
        .job-company {
            font-size: 16px;
            color: #6b7280;
            margin: 0 0 8px 0;
        }
        .job-location {
            font-size: 14px;
            color: #9ca3af;
            margin: 0;
        }
        .footer {
            background-color: $_secondaryColor;
            padding: 30px 20px;
            text-align: center;
            border-top: 1px solid #e5e7eb;
        }
        .footer p {
            margin: 8px 0;
            font-size: 14px;
            color: #6b7280;
        }
        .social-links {
            margin: 20px 0;
        }
        .social-links a {
            display: inline-block;
            margin: 0 10px;
            color: $_primaryColor;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <img src="$_logoUrl" alt="JobHunt Logo" class="logo">
            <h1>JobHunt</h1>
        </div>
        <div class="content">
            $content
        </div>
        <div class="footer">
            <p><strong>JobHunt Team</strong></p>
            <p>Connecting talent with opportunity</p>
            <div class="social-links">
                <a href="#">LinkedIn</a>
                <a href="#">Twitter</a>
                <a href="#">Facebook</a>
            </div>
            <p>© 2024 JobHunt. All rights reserved.</p>
            <p>If you no longer wish to receive these emails, you can <a href="#" style="color: $_primaryColor;">unsubscribe here</a>.</p>
        </div>
    </div>
</body>
</html>
''';
  }

  /// OTP Verification Email Template
  static EmailTemplate otpVerification({
    required String recipientName,
    required String otpCode,
  }) {
    final content = '''
        <h2>Verify Your Email Address</h2>
        <p>Hello $recipientName,</p>
        <p>Thank you for signing up with JobHunt! To complete your registration and secure your account, please verify your email address using the verification code below:</p>
        
        <div class="otp-code">$otpCode</div>
        
        <p>This verification code will expire in <strong>10 minutes</strong> for security reasons.</p>
        <p>If you didn't create a JobHunt account, please ignore this email or contact our support team if you have concerns.</p>
        
        <p>Best regards,<br>The JobHunt Team</p>
    ''';

    return EmailTemplate(
      subject: 'Verify Your JobHunt Account - Code: $otpCode',
      htmlContent: _baseTemplate(
        title: 'Verify Your Email',
        content: content,
      ),
      textContent: '''
Hello $recipientName,

Thank you for signing up with JobHunt! Please verify your email address using this code:

$otpCode

This code will expire in 10 minutes.

If you didn't create a JobHunt account, please ignore this email.

Best regards,
The JobHunt Team
''',
    );
  }

  /// Account Created (Pending Approval)
  static EmailTemplate accountCreated({
    required String recipientName,
    required String userRole,
  }) {
    final content = '''
        <h2>Account Created ✅</h2>
        <p>Hello $recipientName,</p>
        <p>Thanks for registering as a <strong>${userRole.replaceAll('_', ' ')}</strong> on JobHunt.</p>
        <p>Your account is currently <strong>pending admin approval</strong>. We'll email you once it's approved.</p>
        <a href="#" class="button">Open JobHunt</a>
        <p style="color:#6b7280;font-size:14px;">If you didn't create this account, please ignore this email.</p>
    ''';

    return EmailTemplate(
      subject: 'Welcome to JobHunt — Account Created',
      htmlContent: _baseTemplate(
        title: 'Welcome to JobHunt',
        content: content,
      ),
      textContent:
          'Hello $recipientName, your ${userRole.replaceAll('_', ' ')} account was created and is pending approval.',
    );
  }

  /// Admin Approval
  static EmailTemplate approval({
    required String recipientName,
    required String userRole,
  }) {
    final content = '''
        <h2>🎉 Account Approved!</h2>
        <p>Hello $recipientName,</p>
        <p>Your account as a <strong>${userRole.replaceAll('_', ' ')}</strong> has been approved. You can now sign in and start using JobHunt.</p>
        <a href="#" class="button">Open JobHunt</a>
        <p>We’re excited to have you onboard.</p>
    ''';

    return EmailTemplate(
      subject: 'Account Approved - Welcome to JobHunt!',
      htmlContent: _baseTemplate(
        title: 'Account Approved',
        content: content,
      ),
      textContent:
          'Hello $recipientName, your ${userRole.replaceAll('_', ' ')} account has been approved.',
    );
  }

  /// Admin Rejection
  static EmailTemplate rejection({
    required String recipientName,
    required String userRole,
    required String reason,
  }) {
    final content = '''
        <h2>Account Review Update</h2>
        <p>Hello $recipientName,</p>
        <p>Thank you for your interest in joining JobHunt as a <strong>${userRole.replaceAll('_', ' ')}</strong>.</p>
        <p>After careful review, we’re unable to approve your account at this time.</p>
        <p><strong>Reason:</strong> $reason</p>
        <p>If you believe this is a mistake, please reply to this email.</p>
    ''';

    return EmailTemplate(
      subject: 'JobHunt Account Update',
      htmlContent: _baseTemplate(
        title: 'Account Review Update',
        content: content,
      ),
      textContent:
          'Hello $recipientName, your ${userRole.replaceAll('_', ' ')} account was not approved. Reason: $reason',
    );
  }

  /// Application Status Update
  static EmailTemplate applicationStatus({
    required String recipientName,
    required String jobTitle,
    required String companyName,
    required String status,
  }) {
    final content = '''
        <h2>Application Status Update</h2>
        <p>Hello $recipientName,</p>
        <p>Your application for <strong>$jobTitle</strong> at <strong>$companyName</strong> has been updated to <strong>$status</strong>.</p>
        <a href="#" class="button">View Application</a>
        <p>Good luck!</p>
    ''';

    return EmailTemplate(
      subject: 'Update on Your Application for "$jobTitle"',
      htmlContent: _baseTemplate(
        title: 'Application Status Update',
        content: content,
      ),
      textContent:
          'Hello $recipientName, your application for $jobTitle at $companyName is now $status.',
    );
  }

  /// Welcome Email Template
  static EmailTemplate welcome({
    required String recipientName,
    required String userRole,
  }) {
    String roleSpecificContent = '';
    String ctaButton = '';

    switch (userRole.toLowerCase()) {
      case 'job_seeker':
        roleSpecificContent = '''
        <p>As a job seeker, you now have access to:</p>
        <ul>
            <li>🔍 Advanced job search with smart filters</li>
            <li>💼 Personalized job recommendations</li>
            <li>📧 Job alerts delivered to your inbox</li>
            <li>📄 Easy application management</li>
            <li>⭐ Save jobs to your favorites</li>
        </ul>
        <p>Ready to find your dream job? Start exploring opportunities now!</p>
        ''';
        ctaButton = '<a href="#" class="button">Browse Jobs</a>';
        break;

      case 'employer':
        roleSpecificContent = '''
        <p>As an employer, you can now:</p>
        <ul>
            <li>📝 Post job openings with detailed descriptions</li>
            <li>👥 Manage applications from qualified candidates</li>
            <li>🎯 Target the right talent with advanced filters</li>
            <li>📊 Track your job posting performance</li>
            <li>💬 Communicate directly with applicants</li>
        </ul>
        <p>Ready to find your next great hire? Post your first job today!</p>
        ''';
        ctaButton = '<a href="#" class="button">Post a Job</a>';
        break;

      case 'admin':
        roleSpecificContent = '''
        <p>Welcome to the JobHunt admin panel. You now have access to:</p>
        <ul>
            <li>👥 User management and moderation</li>
            <li>📋 Job posting oversight</li>
            <li>📊 Platform analytics and insights</li>
            <li>⚙️ System configuration tools</li>
        </ul>
        ''';
        ctaButton = '<a href="#" class="button">Access Admin Panel</a>';
        break;
    }

    final content = '''
        <h2>Welcome to JobHunt! 🎉</h2>
        <p>Hello $recipientName,</p>
        <p>Welcome to JobHunt - where talent meets opportunity! We're thrilled to have you join our growing community of professionals.</p>
        
        $roleSpecificContent
        
        $ctaButton
        
        <p>If you have any questions or need assistance getting started, don't hesitate to reach out to our support team. We're here to help you succeed!</p>
        
        <p>Welcome aboard!<br>The JobHunt Team</p>
    ''';

    return EmailTemplate(
      subject: 'Welcome to JobHunt - Let\'s Get Started! 🚀',
      htmlContent: _baseTemplate(
        title: 'Welcome to JobHunt',
        content: content,
      ),
      textContent: '''
Hello $recipientName,

Welcome to JobHunt - where talent meets opportunity! We're thrilled to have you join our community.

$roleSpecificContent

If you have any questions, please don't hesitate to contact our support team.

Welcome aboard!
The JobHunt Team
''',
    );
  }

  /// Job Posting Confirmation Email Template
  static EmailTemplate jobPostingConfirmation({
    required String recipientName,
    required String jobTitle,
    required String companyName,
  }) {
    final content = '''
        <h2>Job Posted Successfully! ✅</h2>
        <p>Hello $recipientName,</p>
        <p>Great news! Your job posting has been successfully published on JobHunt.</p>
        
        <div class="job-card">
            <div class="job-title">$jobTitle</div>
            <div class="job-company">$companyName</div>
            <p style="margin: 12px 0 0 0; color: #059669; font-weight: 600;">✅ Live and accepting applications</p>
        </div>
        
        <p><strong>What happens next?</strong></p>
        <ul>
            <li>📧 Qualified job seekers will be notified about your posting</li>
            <li>📱 Applications will start coming in through your dashboard</li>
            <li>🔔 You'll receive email notifications for new applications</li>
            <li>📊 Track your job's performance in your employer dashboard</li>
        </ul>
        
        <a href="#" class="button">View Job Posting</a>
        
        <p>Pro tip: Jobs with detailed descriptions and clear requirements typically receive higher quality applications!</p>
        
        <p>Best of luck with your hiring!<br>The JobHunt Team</p>
    ''';

    return EmailTemplate(
      subject: 'Job Posted: $jobTitle at $companyName',
      htmlContent: _baseTemplate(
        title: 'Job Posted Successfully',
        content: content,
      ),
      textContent: '''
Hello $recipientName,

Great news! Your job posting has been successfully published on JobHunt.

Job Title: $jobTitle
Company: $companyName
Status: Live and accepting applications

What happens next:
- Qualified job seekers will be notified
- Applications will come through your dashboard
- You'll receive notifications for new applications

Best of luck with your hiring!
The JobHunt Team
''',
    );
  }

  /// Job Alert Email Template
  static EmailTemplate jobAlert({
    required List<Map<String, dynamic>> newJobs,
  }) {
    final jobsHtml = newJobs.map((job) => '''
        <div class="job-card">
            <div class="job-title">${job['title'] ?? 'Job Title'}</div>
            <div class="job-company">${job['companyName'] ?? 'Company'}</div>
            <div class="job-location">📍 ${job['location'] ?? 'Location'}</div>
            <p style="margin: 12px 0 8px 0; color: #374151;">${job['description'] ?? ''}</p>
            <a href="${job['url'] ?? '#'}" class="button" style="font-size: 14px; padding: 8px 16px;">View Details</a>
        </div>
    ''').join('');

    final content = '''
        <h2>🔥 New Jobs Match Your Preferences!</h2>
        <p>Hello there,</p>
        <p>We found ${newJobs.length} new job${newJobs.length > 1 ? 's' : ''} that match your preferences. Don't miss out on these exciting opportunities!</p>
        
        $jobsHtml
        
        <p style="text-align: center; margin: 30px 0;">
            <a href="#" class="button">View All Jobs</a>
        </p>
        
        <p><strong>💡 Quick Tips for Job Applications:</strong></p>
        <ul>
            <li>Apply early - employers often review applications as they come in</li>
            <li>Customize your cover letter for each position</li>
            <li>Ensure your profile is complete and up-to-date</li>
        </ul>
        
        <p>Happy job hunting!<br>The JobHunt Team</p>
        
        <p style="font-size: 14px; color: #6b7280; border-top: 1px solid #e5e7eb; padding-top: 20px; margin-top: 30px;">
            You're receiving this because you've enabled job alerts. You can update your preferences or unsubscribe in your account settings.
        </p>
    ''';

    return EmailTemplate(
      subject:
          '🎯 ${newJobs.length} New Job${newJobs.length > 1 ? 's' : ''} Match Your Preferences',
      htmlContent: _baseTemplate(
        title: 'New Job Alerts',
        content: content,
      ),
      textContent: '''
New Jobs Match Your Preferences!

We found ${newJobs.length} new job${newJobs.length > 1 ? 's' : ''} that match your preferences:

${newJobs.map((job) => '''
${job['title'] ?? 'Job Title'}
${job['companyName'] ?? 'Company'}
Location: ${job['location'] ?? 'Location'}
${job['description'] ?? ''}
---
''').join('\n')}

View all jobs: [Link]

Happy job hunting!
The JobHunt Team
''',
    );
  }

  /// Weekly Digest Email Template
  static EmailTemplate weeklyDigest({
    required String recipientName,
    required String category,
    required List<Map<String, dynamic>> jobs,
  }) {
    final jobsHtml = jobs.map((job) => '''
        <div class="job-card">
            <div class="job-title">${job['title'] ?? 'Job Title'}</div>
            <div class="job-company">${job['companyName'] ?? job['company'] ?? 'Company'}</div>
            ${job['location'] != null ? '<div class="job-location">📍 ${job['location']}</div>' : ''}
            ${job['salaryRange'] != null ? '<p style="margin: 8px 0 0 0; color:#374151;">💰 ${job['salaryRange']}</p>' : ''}
            <a href="${job['url'] ?? '#'}" class="button" style="font-size: 14px; padding: 8px 16px;">View Details</a>
        </div>
    ''').join('');

    final content = '''
        <h2>🗓️ Your Weekly Job Digest</h2>
        <p>Hello $recipientName,</p>
        <p>Here are ${jobs.length} new jobs in <strong>$category</strong> that match your preferences.</p>

        $jobsHtml

        <p style="text-align: center; margin: 30px 0;">
            <a href="#" class="button">Browse More Jobs</a>
        </p>

        <p>Good luck with your applications!<br>The JobHunt Team</p>
    ''';

    return EmailTemplate(
      subject: '🗓️ Weekly Digest: ${jobs.length} new $category jobs for you',
      htmlContent: _baseTemplate(
        title: 'Weekly Job Digest',
        content: content,
      ),
      textContent: '''
Hello $recipientName,

Here are ${jobs.length} new jobs in $category:

${jobs.map((job) => '''
- ${job['title'] ?? 'Job Title'} at ${job['companyName'] ?? job['company'] ?? 'Company'}${job['location'] != null ? ' — ' + job['location'] : ''}
''').join('')}

Browse more jobs in the app.

— JobHunt Team
''',
    );
  }
}
