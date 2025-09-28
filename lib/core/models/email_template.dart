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
  static const String _logoUrl =
      'https://res.cloudinary.com/dd09znqy6/image/upload/v1758813785/JobHunt_Logo_vvzell.png';

  /// OTP Verification Email Template
  static EmailTemplate otpVerification({
    required String recipientName,
    required String otpCode,
  }) {
    final content = '''
        <h2 style="font-size: 28px; font-weight: 700; margin: 0 0 12px; color: var(--text-primary);">Verify your email, $recipientName</h2>
        <p style="font-size: 16px; line-height: 1.6; margin: 0 0 16px;">Use the one-time code below to verify your JobHunt account. For your security, this code expires in <strong>10 minutes</strong>.</p>
        
        <div style="background: #F8FAFC; border: 2px dashed var(--primary-color); border-radius: 8px; padding: 20px; text-align: center; font-size: 32px; font-weight: 800; letter-spacing: 8px; color: var(--primary-color); margin: 20px 0;">$otpCode</div>
        
        <p style="font-size: 16px; line-height: 1.6; margin: 0 0 16px;">If you didn't request this, you can safely ignore this email—your account will remain secure.</p>
        
        <p style="font-size: 13px; color: #6B7280;">Trouble with the button? Copy and paste this link into your browser:<br>https://jobhunt.app/verify</p>
    ''';

    return EmailTemplate(
      subject: 'Verify Your JobHunt Account — Code: $otpCode',
      htmlContent: '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Verify Your JobHunt Account</title>
<style>
:root{
/* Primary Blue */
--primary-color:#2563EB;--primary-50:#EFF6FF;--primary-100:#DBEAFE;--primary-200:#BFDBFE;--primary-300:#93C5FD;--primary-400:#60A5FA;--primary-500:#2563EB;--primary-600:#1D4ED8;--primary-700:#1E40AF;--primary-800:#1E3A8A;--primary-900:#1E3A8A;
/* Secondary/Status */
--secondary-color:#10B981;--success-50:#ECFDF5;--success-100:#D1FAE5;--success-500:#10B981;--success-600:#059669;--error-color:#EF4444;
/* Surface & Text */
--surface-color:#F8FAFC;--surface-light:#FFFFFF;--surface-dark:#1E293B;
--text-primary:#111827;--text-secondary:#374151;--text-muted:#6B7280;--text-light:#9CA3AF;
}
body{margin:0;background:#F3F4F6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Oxygen,Ubuntu,Cantarell,sans-serif;color:var(--text-secondary);}
.container{max-width:600px;margin:0 auto;background:#FFFFFF;border-radius:12px;overflow:hidden;box-shadow:0 4px 6px rgba(0,0,0,0.1);}
.header{background:linear-gradient(135deg,#2563EB 0%,#1D4ED8 100%);padding:40px 20px;text-align:center;color:#fff;}
.header .logo{width:44px;height:auto;margin-bottom:12px}
.content{padding:40px 20px;color:var(--text-secondary);}
.h1{font-size:28px;font-weight:700;margin:0 0 12px;color:var(--text-primary);}
.p{font-size:16px;line-height:1.6;margin:0 0 16px}
.otp-box{background:#F8FAFC;border:2px dashed var(--primary-color);border-radius:8px;padding:20px;text-align:center;font-size:32px;font-weight:800;letter-spacing:8px;color:var(--primary-color);margin:20px 0}
.btn{background:#2563EB;color:#fff;padding:14px 28px;border-radius:8px;font-weight:600;text-decoration:none;display:inline-block;}
.subtle{font-size:13px;color:#6B7280}
.footer{background:#F8FAFC;padding:30px 20px;text-align:center;color:#6B7280;border-top:1px solid #E5E7EB;}
</style>
</head>
<body>
  <div class="container">
    <div class="header">
      <img class="logo" src="$_logoUrl" alt="JobHunt Logo">
      <h1 style="margin:0;font-weight:700">JobHunt</h1>
    </div>
    <div class="content">
      $content
    </div>
    <div class="footer">
      <p><strong>JobHunt Team</strong></p>
      <p>Connecting talent with opportunity</p>
      <p>© 2025 JobHunt. All rights reserved.</p>
    </div>
  </div>
</body>
</html>
''',
      textContent: '''
Hello $recipientName,

Use the one-time code below to verify your JobHunt account. For your security, this code expires in 10 minutes.

$otpCode

If you didn't request this, you can safely ignore this email—your account will remain secure.

Best regards,
The JobHunt Team
''',
    );
  }

  /// Account Created (Pending Approval) - Role-specific
  static EmailTemplate accountCreated({
    required String recipientName,
    required String userRole,
  }) {
    String content;
    String subject;

    if (userRole.toLowerCase() == 'employer') {
      content = '''
        <h2 style="font-size: 28px; font-weight: 700; margin: 0 0 8px; color: var(--text-primary);">Welcome to JobHunt, $recipientName!</h2>
        <p style="font-size: 16px; line-height: 1.6; margin: 0 0 14px;">Your employer account has been created and is currently <strong>pending admin approval</strong>.</p>
        
        <div style="background: #FFFFFF; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 24px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <div style="display: inline-block; background: #DBEAFE; color: #1E40AF; border-radius: 999px; padding: 6px 10px; font-weight: 600; font-size: 12px; margin-bottom: 8px;">What this means</div>
            <p style="font-size: 16px; line-height: 1.6; margin: 0 0 14px;">Our team is reviewing your company details to ensure quality job postings. You'll receive an approval email within 24 hours.</p>
        </div>
        
        <div style="background: #FFFFFF; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 24px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <div style="display: inline-block; background: #DBEAFE; color: #1E40AF; border-radius: 999px; padding: 6px 10px; font-weight: 600; font-size: 12px; margin-bottom: 8px;">Prepare for launch</div>
            <ul style="font-size: 16px; line-height: 1.6; margin: 0; padding-left: 18px;">
                <li>Complete your company profile and upload logo</li>
                <li>Prepare your first job posting details</li>
                <li>Review our employer guidelines and best practices</li>
            </ul>
        </div>
        
        <p style="font-size: 16px; line-height: 1.6; margin: 0 0 14px;"><a href="#" style="background: #2563EB; color: #fff; padding: 12px 22px; border-radius: 8px; font-weight: 600; text-decoration: none; display: inline-block;">View Company Profile</a></p>
        
        <p style="font-size: 13px; color: #6B7280;">If you didn't create this account, contact support immediately: support@jobhunt.app</p>
      ''';
      subject = 'We\'re reviewing your employer account';
    } else {
      content = '''
        <h2 style="font-size: 28px; font-weight: 700; margin: 0 0 8px; color: var(--text-primary);">Welcome aboard, $recipientName!</h2>
        <p style="font-size: 16px; line-height: 1.6; margin: 0 0 14px;">Your JobHunt account has been created and is currently <strong>pending admin approval</strong>.</p>
        
        <div style="background: #FFFFFF; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 24px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <div style="display: inline-block; background: #DBEAFE; color: #1E40AF; border-radius: 999px; padding: 6px 10px; font-weight: 600; font-size: 12px; margin-bottom: 8px;">What this means</div>
            <p style="font-size: 16px; line-height: 1.6; margin: 0 0 14px;">Our team is verifying your details to keep the community trustworthy and secure. You'll receive another email as soon as your account is approved (or if we need more information).</p>
        </div>
        
        <div style="background: #FFFFFF; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 24px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <div style="display: inline-block; background: #DBEAFE; color: #1E40AF; border-radius: 999px; padding: 6px 10px; font-weight: 600; font-size: 12px; margin-bottom: 8px;">What you can do now</div>
            <ul style="font-size: 16px; line-height: 1.6; margin: 0; padding-left: 18px;">
                <li>Complete your profile (photo, skills, experience)</li>
                <li>Set your job preferences (location, salary, categories)</li>
                <li>Enable notifications so you don't miss updates</li>
            </ul>
        </div>
        
        <p style="font-size: 16px; line-height: 1.6; margin: 0 0 14px;"><a href="#" style="background: #2563EB; color: #fff; padding: 12px 22px; border-radius: 8px; font-weight: 600; text-decoration: none; display: inline-block;">Open JobHunt</a></p>
        
        <p style="font-size: 13px; color: #6B7280;">If you didn't create this account, contact support immediately: support@jobhunt.app</p>
    ''';
      subject = 'Welcome to JobHunt — Account Created';
    }

    return EmailTemplate(
      subject: subject,
      htmlContent: '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Account Created — Pending Approval</title>
<style>
:root{--primary-color:#2563EB;--text-primary:#111827;--text-secondary:#374151;--text-muted:#6B7280;--surface:#FFFFFF}
body{margin:0;background:#F3F4F6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Oxygen,Ubuntu,Cantarell,sans-serif;color:var(--text-secondary);}
.container{max-width:600px;margin:0 auto;background:#FFFFFF;border-radius:12px;overflow:hidden;box-shadow:0 4px 6px rgba(0,0,0,0.1);}
.header{background:linear-gradient(135deg,#2563EB 0%,#1D4ED8 100%);padding:40px 20px;text-align:center;color:#fff;}
.header .logo{width:44px;margin-bottom:12px}
.content{padding:40px 20px}
.h1{font-size:28px;font-weight:700;margin:0 0 8px;color:var(--text-primary)}
.p{font-size:16px;line-height:1.6;margin:0 0 14px}
.card{background:#FFFFFF;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,.06);padding:24px;margin:16px 0;border:1px solid #E5E7EB}
.badge{display:inline-block;background:#DBEAFE;color:#1E40AF;border-radius:999px;padding:6px 10px;font-weight:600;font-size:12px;margin-bottom:8px}
.btn{background:#2563EB;color:#fff;padding:12px 22px;border-radius:8px;font-weight:600;text-decoration:none;display:inline-block}
.footer{background:#F8FAFC;padding:30px 20px;text-align:center;color:#6B7280;border-top:1px solid #E5E7EB}
</style>
</head>
<body>
<div class="container">
  <div class="header">
    <img class="logo" src="$_logoUrl" alt="JobHunt Logo">
    <h1 style="margin:0">JobHunt</h1>
  </div>
  <div class="content">
    $content
  </div>
  <div class="footer">
    <p><strong>JobHunt Team</strong></p>
    <p>Connecting talent with opportunity</p>
    <p>© 2025 JobHunt. All rights reserved.</p>
  </div>
</div>
</body>
</html>
''',
      textContent: '''
Hello $recipientName,

Welcome aboard! Your JobHunt account has been created and is currently pending admin approval.

What this means:
Our team is verifying your details to keep the community trustworthy and secure. You'll receive another email as soon as your account is approved (or if we need more information).

What you can do now:
- Complete your profile (photo, skills, experience)
- Set your job preferences (location, salary, categories)
- Enable notifications so you don't miss updates

If you didn't create this account, contact support immediately: support@jobhunt.app

Best regards,
The JobHunt Team
''',
    );
  }

  /// Admin Approval - Role-specific
  static EmailTemplate approval({
    required String recipientName,
    required String userRole,
  }) {
    if (userRole.toLowerCase() == 'employer') {
      return _employerApprovalTemplate(recipientName);
    } else {
      return _jobSeekerApprovalTemplate(recipientName);
    }
  }

  /// Employer-specific approval template (combined approval + welcome)
  static EmailTemplate _employerApprovalTemplate(String recipientName) {
    final content = '''
        <div style="background: linear-gradient(135deg, #10B981 0%, #059669 50%, #047857 100%); border-radius: 12px; padding: 40px 20px; text-align: center; color: #fff; margin: -20px 0 20px;">
            <h2 style="font-size: 28px; font-weight: 800; margin: 0 0 10px;">🎉 Your employer account is approved!</h2>
            <p style="font-size: 16px; line-height: 1.6; margin: 0;">Welcome to JobHunt, $recipientName! You're ready to start hiring.</p>
        </div>

        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 24px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <h3 style="margin: 0 0 8px; font-size: 18px; color: #2563EB;">Ready to hire? Here's what you can do:</h3>
            <ul style="font-size: 16px; line-height: 1.6; margin: 0; padding-left: 18px;">
                <li><strong>Post your first job</strong> - Reach thousands of qualified candidates</li>
                <li><strong>Complete your company profile</strong> - Add logo, description, and company details</li>
                <li><strong>Manage applicants</strong> - Review resumes and track application status</li>
                <li><strong>Set up notifications</strong> - Get alerts when candidates apply</li>
            </ul>
            <p style="font-size: 16px; line-height: 1.6; margin-top: 12px;"><a href="#" style="background: #2563EB; color: #fff; padding: 12px 22px; border-radius: 8px; font-weight: 700; text-decoration: none; display: inline-block;">Post Your First Job</a></p>
        </div>

        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 24px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <h3 style="margin: 0 0 8px; font-size: 18px; color: #2563EB;">Employer Resources</h3>
            <div style="display: flex; gap: 12px; margin: 8px 0;"><b style="min-width: 120px;">Help Center</b><span><a href="#">https://jobhunt.app/help/employers</a></span></div>
            <div style="display: flex; gap: 12px; margin: 8px 0;"><b style="min-width: 120px;">Company Profile</b><span><a href="#">https://jobhunt.app/employer/company</a></span></div>
            <div style="display: flex; gap: 12px; margin: 8px 0;"><b style="min-width: 120px;">Job Management</b><span><a href="#">https://jobhunt.app/employer/my-jobs</a></span></div>
        </div>
    ''';

    return EmailTemplate(
      subject: '🎉 Your employer account is approved',
      htmlContent: '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Account Approved</title>
<style>
:root{--primary:#2563EB;--text:#374151;--dark:#111827}
body{margin:0;background:#F3F4F6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Oxygen,Ubuntu,Cantarell,sans-serif;color:var(--text)}
.container{max-width:600px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 4px 6px rgba(0,0,0,.1)}
.header{background:linear-gradient(135deg,#2563EB,#1D4ED8);padding:40px 20px;text-align:center;color:#fff}
.header .logo{width:44px;margin-bottom:12px}
.content{padding:40px 20px}
.h1{font-size:28px;font-weight:700;margin:0 0 8px;color:var(--text-primary)}
.p{font-size:16px;line-height:1.6;margin:0 0 14px}
.card{background:#FFFFFF;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,.06);padding:24px;margin:16px 0;border:1px solid #E5E7EB}
.badge{display:inline-block;background:#DBEAFE;color:#1E40AF;border-radius:999px;padding:6px 10px;font-weight:600;font-size:12px;margin-bottom:8px}
.btn{background:#2563EB;color:#fff;padding:12px 22px;border-radius:8px;font-weight:600;text-decoration:none;display:inline-block}
.footer{background:#F8FAFC;padding:30px 20px;text-align:center;color:#6B7280;border-top:1px solid #E5E7EB}
</style>
</head>
<body>
<div class="container">
  <div class="header">
    <img class="logo" src="$_logoUrl" alt="JobHunt Logo">
    <h1 style="margin:0">JobHunt</h1>
  </div>
  <div class="content">
    $content
  </div>
  <div class="footer">
    <p><strong>JobHunt Team</strong></p>
    <p>Connecting talent with opportunity</p>
    <p>© 2025 JobHunt. All rights reserved.</p>
  </div>
</div>
</body>
</html>
''',
      textContent: '''
Hello $recipientName,

🎉 Your employer account is approved!

Welcome to JobHunt! You're ready to start hiring.

Ready to hire? Here's what you can do:
- Post your first job - Reach thousands of qualified candidates
- Complete your company profile - Add logo, description, and company details  
- Manage applicants - Review resumes and track application status
- Set up notifications - Get alerts when candidates apply

Employer Resources:
Help Center: https://jobhunt.app/help/employers
Company Profile: https://jobhunt.app/employer/company
Job Management: https://jobhunt.app/employer/my-jobs

Best regards,
The JobHunt Team
''',
    );
  }

  /// Job Seeker approval template (existing logic)
  static EmailTemplate _jobSeekerApprovalTemplate(String recipientName) {
    final content = '''
        <div style="background: linear-gradient(135deg, #8B5CF6 0%, #A855F7 50%, #C084FC 100%); border-radius: 12px; padding: 40px 20px; text-align: center; color: #fff; margin: -20px 0 20px;">
            <h2 style="font-size: 28px; font-weight: 800; margin: 0 0 10px;">🎉 Congratulations, $recipientName!</h2>
            <p style="font-size: 16px; line-height: 1.6; margin: 0;">Your account has been <strong>approved</strong>. You're all set to use JobHunt.</p>
        </div>

        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 24px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <h3 style="margin: 0 0 8px; font-size: 18px; color: #2563EB;">What's next?</h3>
            <ul style="font-size: 16px; line-height: 1.6; margin: 0; padding-left: 18px;">
                <li>Complete your profile and upload your resume</li>
                <li>Set your job preferences and salary expectations</li>
                <li>Browse and apply to jobs that match your skills</li>
                <li>Enable notifications to never miss an opportunity</li>
            </ul>
            <p style="font-size: 16px; line-height: 1.6; margin-top: 12px;"><a href="#" style="background: #2563EB; color: #fff; padding: 12px 22px; border-radius: 8px; font-weight: 700; text-decoration: none; display: inline-block;">Start Job Hunting</a></p>
        </div>
    ''';

    return EmailTemplate(
      subject: '🎉 Your account is approved - Welcome to JobHunt!',
      htmlContent: '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Account Approved</title>
<style>
:root{--primary:#2563EB;--text:#374151;--dark:#111827}
body{margin:0;background:#F3F4F6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Oxygen,Ubuntu,Cantarell,sans-serif;color:var(--text)}
.container{max-width:600px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 4px 6px rgba(0,0,0,.1)}
.header{background:linear-gradient(135deg,#2563EB,#1D4ED8);padding:40px 20px;text-align:center;color:#fff}
.header .logo{width:44px;margin-bottom:12px}
.content{padding:40px 20px}
.h1{font-size:28px;font-weight:700;margin:0 0 8px;color:var(--text-primary)}
.p{font-size:16px;line-height:1.6;margin:0 0 14px}
.card{background:#FFFFFF;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,.06);padding:24px;margin:16px 0;border:1px solid #E5E7EB}
.badge{display:inline-block;background:#DBEAFE;color:#1E40AF;border-radius:999px;padding:6px 10px;font-weight:600;font-size:12px;margin-bottom:8px}
.btn{background:#2563EB;color:#fff;padding:12px 22px;border-radius:8px;font-weight:600;text-decoration:none;display:inline-block}
.footer{background:#F8FAFC;padding:30px 20px;text-align:center;color:#6B7280;border-top:1px solid #E5E7EB}
</style>
</head>
<body>
<div class="container">
  <div class="header">
    <img class="logo" src="$_logoUrl" alt="JobHunt Logo">
    <h1 style="margin:0">JobHunt</h1>
  </div>
  <div class="content">
    $content
  </div>
  <div class="footer">
    <p><strong>JobHunt Team</strong></p>
    <p>Connecting talent with opportunity</p>
    <p>© 2025 JobHunt. All rights reserved.</p>
  </div>
</div>
</body>
</html>
''',
      textContent: '''
Hello $recipientName,

🎉 Congratulations! Your account has been approved.

You're all set to use JobHunt.

What's next?
- Complete your profile and upload your resume
- Set your job preferences and salary expectations
- Browse and apply to jobs that match your skills
- Enable notifications to never miss an opportunity

Best regards,
The JobHunt Team
''',
    );
  }

  /// Legacy approval method for backward compatibility
  static EmailTemplate legacyApproval({
    required String recipientName,
    required String userRole,
  }) {
    final content = '''
        <div style="background: linear-gradient(135deg, #8B5CF6 0%, #A855F7 50%, #C084FC 100%); border-radius: 12px; padding: 40px 20px; text-align: center; color: #fff; margin: -20px 0 20px;">
            <h2 style="font-size: 28px; font-weight: 800; margin: 0 0 10px;">🎉 Congratulations, $recipientName!</h2>
            <p style="font-size: 16px; line-height: 1.6; margin: 0;">Your account has been <strong>approved</strong>. You're all set to use JobHunt.</p>
        </div>

        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 24px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <h3 style="margin: 0 0 8px; font-size: 18px;">What's next?</h3>
            <ul style="font-size: 16px; line-height: 1.6; margin: 0; padding-left: 18px;">
                <li>Finish your profile and upload a polished CV</li>
                <li>Turn on job alerts to get roles that match your preferences</li>
                <li>Apply with one click and track application status in real time</li>
            </ul>
        </div>

        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 24px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <h3 style="margin: 0 0 8px; font-size: 18px;">Quick links</h3>
            <p style="font-size: 16px; line-height: 1.6; margin: 0 0 8px;"><a href="#" style="background: #2563EB; color: #fff; padding: 12px 22px; border-radius: 8px; font-weight: 700; text-decoration: none; display: inline-block;">Open JobHunt</a></p>
            <p style="font-size: 13px; color: #6B7280; margin: 8px 0 0;">Need help? Contact us at support@jobhunt.app.</p>
        </div>
    ''';

    return EmailTemplate(
      subject: '🎉 Welcome to JobHunt — Your Account is Approved!',
      htmlContent: '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Account Approved — Welcome to JobHunt</title>
<style>
:root{--primary:#2563EB;--green:#10B981;--text:#374151;--dark:#111827;}
body{margin:0;background:#F3F4F6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Oxygen,Ubuntu,Cantarell,sans-serif;color:var(--text);}
.container{max-width:600px;margin:0 auto;background:#FFFFFF;border-radius:12px;overflow:hidden;box-shadow:0 4px 6px rgba(0,0,0,.1);}
.header{background:linear-gradient(135deg,#2563EB 0%,#1D4ED8 100%);padding:40px 20px;text-align:center;color:#fff;}
.header .logo{width:44px;margin-bottom:12px}
.content{padding:0 20px 30px}
.banner{background:linear-gradient(135deg,#8B5CF6 0%,#A855F7 50%,#C084FC 100%);border-radius:12px;padding:40px 20px;text-align:center;color:#fff;margin:-20px 0 20px}
.h1{font-size:28px;font-weight:800;margin:0 0 10px}
.p{font-size:16px;line-height:1.6;margin:0 0 14px}
.card{background:#fff;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,.06);padding:24px;margin:16px 0;border:1px solid #E5E7EB}
.btn{background:#2563EB;color:#fff;padding:12px 22px;border-radius:8px;font-weight:700;text-decoration:none;display:inline-block}
.footer{background:#F8FAFC;padding:30px 20px;text-align:center;color:#6B7280;border-top:1px solid #E5E7EB}
</style>
</head>
<body>
<div class="container">
  <div class="header">
    <img class="logo" src="$_logoUrl" alt="JobHunt Logo">
    <h1 style="margin:0">JobHunt</h1>
  </div>
  <div class="content">
    $content
  </div>
  <div class="footer">
    <p><strong>JobHunt Team</strong></p>
    <p>Connecting talent with opportunity</p>
    <p>© 2025 JobHunt. All rights reserved.</p>
  </div>
</div>
</body>
</html>
''',
      textContent: '''
Congratulations, $recipientName!

Your account has been approved. You're all set to use JobHunt.

What's next?
- Finish your profile and upload a polished CV
- Turn on job alerts to get roles that match your preferences
- Apply with one click and track application status in real time

Quick links:
Open JobHunt: [Link]

Need help? Contact us at support@jobhunt.app.

Best regards,
The JobHunt Team
''',
    );
  }

  /// Admin Rejection
  static EmailTemplate rejection({
    required String recipientName,
    required String userRole,
    required String reason,
  }) {
    final content = '''
        <h2 style="font-size: 24px; font-weight: 700; margin: 0 0 10px;">Account review outcome</h2>
        <p style="font-size: 16px; line-height: 1.6; margin: 0 0 14px;">Hi $recipientName, thanks for applying to join JobHunt. After reviewing your submission, we're unable to approve your account at this time.</p>
        
        <div style="border-left: 4px solid var(--red); background: #FEF2F2; border-radius: 8px; padding: 14px 16px; margin: 14px 0;">
            <p style="font-size: 16px; line-height: 1.6; margin: 0;"><strong>Reason provided:</strong> $reason</p>
        </div>
        
        <p style="font-size: 16px; line-height: 1.6; margin: 0 0 14px;">You can update your details and request another review. Most resubmissions are approved when the missing or inaccurate information is corrected.</p>
        
        <p style="font-size: 16px; line-height: 1.6; margin: 0 0 14px;"><a href="#" style="background: #2563EB; color: #fff; padding: 12px 22px; border-radius: 8px; font-weight: 700; text-decoration: none; display: inline-block;">Update & Resubmit</a></p>
        
        <p style="font-size: 13px; color: #6B7280;">If you have questions, reply to this email or reach us at support@jobhunt.app.</p>
    ''';

    return EmailTemplate(
      subject: 'JobHunt Account Update',
      htmlContent: '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Account Review — Action Needed</title>
<style>
:root{--primary:#2563EB;--red:#EF4444;--text:#374151;--muted:#6B7280}
body{margin:0;background:#F3F4F6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Oxygen,Ubuntu,Cantarell,sans-serif;color:var(--text)}
.container{max-width:600px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 4px 6px rgba(0,0,0,.1)}
.header{background:linear-gradient(135deg,#2563EB,#1D4ED8);padding:40px 20px;text-align:center;color:#fff}
.header .logo{width:44px;margin-bottom:12px}
.content{padding:40px 20px}
.h1{font-size:24px;font-weight:700;margin:0 0 10px}
.p{font-size:16px;line-height:1.6;margin:0 0 14px}
.alert{border-left:4px solid var(--red);background:#FEF2F2;border-radius:8px;padding:14px 16px;margin:14px 0}
.btn{background:#2563EB;color:#fff;padding:12px 22px;border-radius:8px;font-weight:700;text-decoration:none;display:inline-block}
.footer{background:#F8FAFC;padding:30px 20px;text-align:center;color:#6B7280;border-top:1px solid #E5E7EB}
</style>
</head>
<body>
<div class="container">
  <div class="header">
    <img class="logo" src="$_logoUrl" alt="JobHunt Logo">
    <h1 style="margin:0">JobHunt</h1>
  </div>
  <div class="content">
    $content
  </div>
  <div class="footer">
    <p><strong>JobHunt Team</strong></p>
    <p>Connecting talent with opportunity</p>
    <p>© 2025 JobHunt. All rights reserved.</p>
  </div>
</div>
</body>
</html>
''',
      textContent: '''
Hi $recipientName,

Thanks for applying to join JobHunt. After reviewing your submission, we're unable to approve your account at this time.

Reason provided: $reason

You can update your details and request another review. Most resubmissions are approved when the missing or inaccurate information is corrected.

If you have questions, reply to this email or reach us at support@jobhunt.app.

Best regards,
The JobHunt Team
''',
    );
  }

  /// Application Status Update
  static EmailTemplate applicationStatus({
    required String recipientName,
    required String jobTitle,
    required String companyName,
    required String status,
    String? note,
  }) {
    String statusBadge = '';
    String statusMessage = '';
    String actionButton = '';

    switch (status.toLowerCase()) {
      case 'under review':
        statusBadge =
            '<span style="display: inline-block; border-radius: 999px; padding: 6px 10px; font-weight: 700; font-size: 12px; margin: 6px 0; background: #FEF3C7; color: #92400E;">Under Review</span>';
        statusMessage =
            'Your application is being reviewed. We\'ll notify you as soon as there\'s an update.';
        actionButton = 'Track Status';
        break;
      case 'shortlisted':
        statusBadge =
            '<span style="display: inline-block; border-radius: 999px; padding: 6px 10px; font-weight: 700; font-size: 12px; margin: 6px 0; background: #D1FAE5; color: #065F46;">Shortlisted</span>';
        statusMessage =
            'Great news! The employer wants to proceed. Keep an eye on your inbox for interview details or next steps.';
        actionButton = 'View in App';
        break;
      case 'rejected':
        statusBadge =
            '<span style="display: inline-block; border-radius: 999px; padding: 6px 10px; font-weight: 700; font-size: 12px; margin: 6px 0; background: #FEE2E2; color: #991B1B;">Not Selected</span>';
        statusMessage =
            'This one didn\'t work out, but we\'ve got more opportunities waiting. Tailor your resume to the role and try again.';
        actionButton = 'Find Similar Jobs';
        break;
      default:
        statusBadge =
            '<span style="display: inline-block; border-radius: 999px; padding: 6px 10px; font-weight: 700; font-size: 12px; margin: 6px 0; background: #F3F4F6; color: #374151;">$status</span>';
        statusMessage = 'Your application status has been updated.';
        actionButton = 'View Application';
    }

    final content = '''
        <h2 style="font-size: 24px; font-weight: 800; margin: 0 0 10px;">Your application status changed</h2>
        <p style="font-size: 16px; line-height: 1.6; margin: 0 0 14px;">Hi $recipientName, there's an update on your application for <strong>$jobTitle</strong> at <strong>$companyName</strong>.</p>

        $statusBadge

        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 20px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <div style="display: flex; gap: 8px; margin: 6px 0;"><b style="min-width: 140px;">Applied on</b><span>Today</span></div>
            <div style="display: flex; gap: 8px; margin: 6px 0;"><b style="min-width: 140px;">Current stage</b><span>$status</span></div>
            ${note != null ? '<div style="display: flex; gap: 8px; margin: 6px 0;"><b style="min-width: 140px;">Note</b><span>$note</span></div>' : ''}
            <div style="display: flex; gap: 8px; margin: 6px 0;"><b style="min-width: 140px;">Job link</b><span><a href="#">https://jobhunt.app/job/123</a></span></div>
        </div>

        <p style="font-size: 16px; line-height: 1.6; margin: 0 0 14px;">$statusMessage</p>
        <p style="font-size: 16px; line-height: 1.6; margin: 0 0 14px;"><a href="#" style="background: #2563EB; color: #fff; padding: 12px 22px; border-radius: 8px; font-weight: 700; text-decoration: none; display: inline-block;">$actionButton</a></p>
    ''';

    return EmailTemplate(
      subject: 'Update on Your Application for "$jobTitle"',
      htmlContent: '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Application Status Update</title>
<style>
:root{--primary:#2563EB;--green:#10B981;--amber:#F59E0B;--red:#EF4444;--text:#374151}
body{margin:0;background:#F3F4F6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Oxygen,Ubuntu,Cantarell,sans-serif;color:var(--text)}
.container{max-width:600px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 4px 6px rgba(0,0,0,.1)}
.header{background:linear-gradient(135deg,#2563EB,#1D4ED8);padding:40px 20px;text-align:center;color:#fff}
.header .logo{width:44px;margin-bottom:12px}
.content{padding:40px 20px}
.h1{font-size:24px;font-weight:800;margin:0 0 10px}
.p{font-size:16px;line-height:1.6;margin:0 0 14px}
.badge{display:inline-block;border-radius:999px;padding:6px 10px;font-weight:700;font-size:12px;margin:6px 0}
.badge--review{background:#FEF3C7;color:#92400E}
.badge--shortlisted{background:#D1FAE5;color:#065F46}
.badge--rejected{background:#FEE2E2;color:#991B1B}
.card{background:#fff;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,.06);padding:20px;margin:16px 0;border:1px solid #E5E7EB}
.kv{display:flex;gap:8px;margin:6px 0}
.kv b{min-width:140px}
.btn{background:#2563EB;color:#fff;padding:12px 22px;border-radius:8px;font-weight:700;text-decoration:none;display:inline-block}
.footer{background:#F8FAFC;padding:30px 20px;text-align:center;color:#6B7280;border-top:1px solid #E5E7EB}
</style>
</head>
<body>
<div class="container">
  <div class="header">
    <img class="logo" src="$_logoUrl" alt="JobHunt Logo">
    <h1 style="margin:0">JobHunt</h1>
  </div>
  <div class="content">
    $content
  </div>
  <div class="footer">
    <p><strong>JobHunt Team</strong></p>
    <p>Connecting talent with opportunity</p>
    <p>© 2025 JobHunt. All rights reserved.</p>
  </div>
</div>
</body>
</html>
''',
      textContent: '''
Your application status changed

Hi $recipientName, there's an update on your application for $jobTitle at $companyName.

Status: $status

Application Details:
- Applied on: Today
- Current stage: $status
${note != null ? '- Note: $note' : ''}
- Job link: https://jobhunt.app/job/123

$statusMessage

$actionButton: [Link]

Best regards,
The JobHunt Team
''',
    );
  }

  /// Job Posting Confirmation Email (Employer)
  static EmailTemplate jobPostingConfirmation({
    required String recipientName,
    required String jobTitle,
    required String companyName,
    required String jobId,
  }) {
    final content = '''
        <div style="background: linear-gradient(135deg, #10B981 0%, #059669 50%, #047857 100%); border-radius: 12px; padding: 40px 20px; text-align: center; color: #fff; margin: -20px 0 20px;">
            <h2 style="font-size: 28px; font-weight: 800; margin: 0 0 10px;">✅ Job Posted Successfully!</h2>
            <p style="font-size: 16px; line-height: 1.6; margin: 0;">Your job posting "$jobTitle" is now live and visible to job seekers.</p>
        </div>

        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 24px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <h3 style="margin: 0 0 8px; font-size: 18px; color: #2563EB;">Job Details</h3>
            <div style="display: flex; gap: 12px; margin: 8px 0;"><b style="min-width: 120px;">Job Title</b><span>$jobTitle</span></div>
            <div style="display: flex; gap: 12px; margin: 8px 0;"><b style="min-width: 120px;">Company</b><span>$companyName</span></div>
            <div style="display: flex; gap: 12px; margin: 8px 0;"><b style="min-width: 120px;">Status</b><span style="color: #10B981; font-weight: 600;">Live & Active</span></div>
            <div style="display: flex; gap: 12px; margin: 8px 0;"><b style="min-width: 120px;">Job ID</b><span style="font-family: monospace; background: #F3F4F6; padding: 2px 6px; border-radius: 4px;">$jobId</span></div>
        </div>

        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 24px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <h3 style="margin: 0 0 8px; font-size: 18px; color: #2563EB;">What happens next?</h3>
            <ul style="font-size: 16px; line-height: 1.6; margin: 0; padding-left: 18px;">
                <li><strong>Applications will start coming in</strong> - You'll receive email notifications for new applications</li>
                <li><strong>Review and manage applicants</strong> - Use the employer dashboard to track all applications</li>
                <li><strong>Update job status</strong> - Mark as filled or extend the posting as needed</li>
                <li><strong>Track performance</strong> - Monitor views, applications, and engagement</li>
            </ul>
            <p style="font-size: 16px; line-height: 1.6; margin-top: 12px;"><a href="#" style="background: #2563EB; color: #fff; padding: 12px 22px; border-radius: 8px; font-weight: 700; text-decoration: none; display: inline-block;">Manage This Job</a></p>
        </div>

        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 24px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <h3 style="margin: 0 0 8px; font-size: 18px; color: #2563EB;">Pro Tips for Success</h3>
            <ul style="font-size: 16px; line-height: 1.6; margin: 0; padding-left: 18px;">
                <li>Respond to applications within 24-48 hours for best results</li>
                <li>Keep your job description clear and detailed</li>
                <li>Set realistic salary expectations to attract quality candidates</li>
                <li>Use relevant keywords to improve job visibility</li>
            </ul>
        </div>
    ''';

    return EmailTemplate(
      subject: '✅ Job Posted: "$jobTitle" is now live',
      htmlContent: '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Job Posted Successfully</title>
<style>
:root{--primary:#2563EB;--text:#374151;--dark:#111827}
body{margin:0;background:#F3F4F6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Oxygen,Ubuntu,Cantarell,sans-serif;color:var(--text)}
.container{max-width:600px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 4px 6px rgba(0,0,0,.1)}
.header{background:linear-gradient(135deg,#2563EB,#1D4ED8);padding:40px 20px;text-align:center;color:#fff}
.header .logo{width:44px;margin-bottom:12px}
.content{padding:40px 20px}
.h1{font-size:28px;font-weight:700;margin:0 0 8px;color:var(--text-primary)}
.p{font-size:16px;line-height:1.6;margin:0 0 14px}
.card{background:#FFFFFF;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,.06);padding:24px;margin:16px 0;border:1px solid #E5E7EB}
.badge{display:inline-block;background:#DBEAFE;color:#1E40AF;border-radius:999px;padding:6px 10px;font-weight:600;font-size:12px;margin-bottom:8px}
.btn{background:#2563EB;color:#fff;padding:12px 22px;border-radius:8px;font-weight:600;text-decoration:none;display:inline-block}
.footer{background:#F8FAFC;padding:30px 20px;text-align:center;color:#6B7280;border-top:1px solid #E5E7EB}
</style>
</head>
<body>
<div class="container">
  <div class="header">
    <img class="logo" src="$_logoUrl" alt="JobHunt Logo">
    <h1 style="margin:0">JobHunt</h1>
  </div>
  <div class="content">
    $content
  </div>
  <div class="footer">
    <p><strong>JobHunt Team</strong></p>
    <p>Connecting talent with opportunity</p>
    <p>© 2025 JobHunt. All rights reserved.</p>
  </div>
</div>
</body>
</html>
''',
      textContent: '''
Hello $recipientName,

✅ Job Posted Successfully!

Your job posting "$jobTitle" is now live and visible to job seekers.

Job Details:
Job Title: $jobTitle
Company: $companyName
Status: Live & Active
Job ID: $jobId

What happens next?
- Applications will start coming in - You'll receive email notifications for new applications
- Review and manage applicants - Use the employer dashboard to track all applications
- Update job status - Mark as filled or extend the posting as needed
- Track performance - Monitor views, applications, and engagement

Pro Tips for Success:
- Respond to applications within 24-48 hours for best results
- Keep your job description clear and detailed
- Set realistic salary expectations to attract quality candidates
- Use relevant keywords to improve job visibility

Best regards,
The JobHunt Team
''',
    );
  }

  /// Welcome Email Template
  static EmailTemplate welcome({
    required String recipientName,
    required String userRole,
  }) {
    String roleSpecificContent = '';

    switch (userRole.toLowerCase()) {
      case 'job_seeker':
        roleSpecificContent = '''
        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 24px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <h3 style="margin: 0 0 8px; font-size: 18px;">For Job Seekers</h3>
            <ul style="font-size: 16px; line-height: 1.6; margin: 0; padding-left: 18px;">
                <li>Complete your profile & upload resume/CV</li>
                <li>Set your salary & location preferences</li>
                <li>Save jobs, enable alerts, and apply in one click</li>
            </ul>
            <p style="font-size: 16px; line-height: 1.6; margin-top: 12px;"><a href="#" style="background: #2563EB; color: #fff; padding: 12px 22px; border-radius: 8px; font-weight: 700; text-decoration: none; display: inline-block;">Find Jobs</a></p>
        </div>
        ''';
        break;

      case 'employer':
        roleSpecificContent = '''
        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 24px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <h3 style="margin: 0 0 8px; font-size: 18px;">For Employers</h3>
            <ul style="font-size: 16px; line-height: 1.6; margin: 0; padding-left: 18px;">
                <li>Post your first job in under 2 minutes</li>
                <li>Use filters to shortlist the best candidates</li>
                <li>Track applications and message candidates securely</li>
            </ul>
            <p style="font-size: 16px; line-height: 1.6; margin-top: 12px;"><a href="#" style="background: #2563EB; color: #fff; padding: 12px 22px; border-radius: 8px; font-weight: 700; text-decoration: none; display: inline-block;">Post a Job</a></p>
        </div>
        ''';
        break;

      case 'admin':
        roleSpecificContent = '''
        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 24px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <h3 style="margin: 0 0 8px; font-size: 18px;">For Administrators</h3>
            <ul style="font-size: 16px; line-height: 1.6; margin: 0; padding-left: 18px;">
                <li>User management and moderation</li>
                <li>Job posting oversight</li>
                <li>Platform analytics and insights</li>
                <li>System configuration tools</li>
            </ul>
            <p style="font-size: 16px; line-height: 1.6; margin-top: 12px;"><a href="#" style="background: #2563EB; color: #fff; padding: 12px 22px; border-radius: 8px; font-weight: 700; text-decoration: none; display: inline-block;">Access Admin Panel</a></p>
        </div>
        ''';
        break;
    }

    final content = '''
        <div style="background: linear-gradient(135deg, #8B5CF6, #A855F7, #C084FC); border-radius: 12px; padding: 40px 20px; text-align: center; color: #fff; margin: -20px 0 20px;">
            <h2 style="font-size: 28px; font-weight: 800; margin: 0 0 10px;">Welcome to JobHunt, $recipientName!</h2>
            <p style="font-size: 16px; line-height: 1.6; margin: 0;">Let's personalize your experience and get you productive in minutes.</p>
        </div>

        $roleSpecificContent

        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 24px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <h3 style="margin: 0 0 8px; font-size: 18px;">Helpful links</h3>
            <div style="display: flex; gap: 12px; margin: 8px 0;"><b style="min-width: 120px;">Help Center</b><span><a href="#">https://jobhunt.app/help</a></span></div>
            <div style="display: flex; gap: 12px; margin: 8px 0;"><b style="min-width: 120px;">Account</b><span><a href="#">https://jobhunt.app/account</a></span></div>
            <div style="display: flex; gap: 12px; margin: 8px 0;"><b style="min-width: 120px;">Notifications</b><span>Enable email & push for quicker updates</span></div>
        </div>
    ''';

    return EmailTemplate(
      subject: '🎉 Welcome to JobHunt — Your Account is Approved!',
      htmlContent: '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Welcome to JobHunt</title>
<style>
:root{--primary:#2563EB;--text:#374151;--dark:#111827}
body{margin:0;background:#F3F4F6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Oxygen,Ubuntu,Cantarell,sans-serif;color:var(--text)}
.container{max-width:600px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 4px 6px rgba(0,0,0,.1)}
.header{background:linear-gradient(135deg,#2563EB,#1D4ED8);padding:40px 20px;text-align:center;color:#fff}
.header .logo{width:44px;margin-bottom:12px}
.content{padding:0 20px 30px}
.banner{background:linear-gradient(135deg,#8B5CF6,#A855F7,#C084FC);border-radius:12px;padding:40px 20px;text-align:center;color:#fff;margin:-20px 0 20px}
.h1{font-size:28px;font-weight:800;margin:0 0 10px}
.p{font-size:16px;line-height:1.6;margin:0 0 14px}
.card{background:#fff;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,.06);padding:24px;margin:16px 0;border:1px solid #E5E7EB}
.kv{display:flex;gap:12px;margin:8px 0}
.kv b{min-width:120px}
.btn{background:#2563EB;color:#fff;padding:12px 22px;border-radius:8px;font-weight:700;text-decoration:none;display:inline-block}
.footer{background:#F8FAFC;padding:30px 20px;text-align:center;color:#6B7280;border-top:1px solid #E5E7EB}
</style>
</head>
<body>
<div class="container">
  <div class="header">
    <img class="logo" src="$_logoUrl" alt="JobHunt Logo">
    <h1 style="margin:0">JobHunt</h1>
  </div>
  <div class="content">
    $content
  </div>
  <div class="footer">
    <p><strong>JobHunt Team</strong></p>
    <p>Connecting talent with opportunity</p>
    <p>© 2025 JobHunt. All rights reserved.</p>
  </div>
</div>
</body>
</html>
''',
      textContent: '''
Welcome to JobHunt, $recipientName!

Let's personalize your experience and get you productive in minutes.

${userRole == 'job_seeker' ? '''
For Job Seekers:
- Complete your profile & upload resume/CV
- Set your salary & location preferences
- Save jobs, enable alerts, and apply in one click
''' : userRole == 'employer' ? '''
For Employers:
- Post your first job in under 2 minutes
- Use filters to shortlist the best candidates
- Track applications and message candidates securely
''' : '''
For Administrators:
- User management and moderation
- Job posting oversight
- Platform analytics and insights
- System configuration tools
'''}

Helpful links:
- Help Center: https://jobhunt.app/help
- Account: https://jobhunt.app/account
- Notifications: Enable email & push for quicker updates

Best regards,
The JobHunt Team
''',
    );
  }

  /// Job Alert Email Template
  static EmailTemplate jobAlert({
    required List<Map<String, dynamic>> newJobs,
  }) {
    final jobsHtml = newJobs.map((job) => '''
        <div style="border: 1px solid #E5E7EB; border-radius: 8px; padding: 16px; background: #FAFAFA; margin: 12px 0;">
            <p style="font-weight: 700; color: #111827; margin: 0 0 6px;">${job['title'] ?? 'Job Title'}</p>
            <p style="font-size: 14px; color: #6B7280; margin: 0 0 8px;">${job['companyName'] ?? 'Company'} • ${job['location'] ?? 'Location'} • ${job['salary'] ?? 'Competitive'}</p>
            <p style="font-size: 16px; line-height: 1.6; margin: 0 0 8px;">${job['description'] ?? 'Great opportunity for skilled professionals.'}</p>
            <a href="${job['url'] ?? '#'}" style="background: #2563EB; color: #fff; padding: 12px 22px; border-radius: 8px; font-weight: 700; text-decoration: none; display: inline-block;">View & Apply</a>
        </div>
    ''').join('');

    final content = '''
        <h2 style="font-size: 24px; font-weight: 800; margin: 0 0 10px;">New roles for you, Job Seeker</h2>
        <p style="font-size: 16px; line-height: 1.6; margin: 0 0 14px;">We found ${newJobs.length} new job${newJobs.length > 1 ? 's' : ''} that match your preferences.</p>

        $jobsHtml

        <p style="font-size: 16px; line-height: 1.6; margin: 0 0 14px;"><a href="#" style="background: #2563EB; color: #fff; padding: 12px 22px; border-radius: 8px; font-weight: 700; text-decoration: none; display: inline-block;">See All Matches</a></p>
        <p style="font-size: 12px; color: #6B7280;">You're receiving this alert because you enabled job notifications. <a href="#">Manage preferences</a>.</p>
    ''';

    return EmailTemplate(
      subject:
          '🎯 ${newJobs.length} New Job${newJobs.length > 1 ? 's' : ''} Match Your Preferences',
      htmlContent: '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Job Alerts</title>
<style>
:root{--primary:#2563EB;--text:#374151}
body{margin:0;background:#F3F4F6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Oxygen,Ubuntu,Cantarell,sans-serif;color:var(--text)}
.container{max-width:600px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 4px 6px rgba(0,0,0,.1)}
.header{background:linear-gradient(135deg,#2563EB,#1D4ED8);padding:40px 20px;text-align:center;color:#fff}
.header .logo{width:44px;margin-bottom:12px}
.content{padding:40px 20px}
.h1{font-size:24px;font-weight:800;margin:0 0 10px}
.p{font-size:16px;line-height:1.6;margin:0 0 14px}
.job{border:1px solid #E5E7EB;border-radius:8px;padding:16px;background:#FAFAFA;margin:12px 0}
.job .t{font-weight:700;color:#111827;margin:0 0 6px}
.meta{font-size:14px;color:#6B7280;margin:0 0 8px}
.btn{background:#2563EB;color:#fff;padding:12px 22px;border-radius:8px;font-weight:700;text-decoration:none;display:inline-block}
.small{font-size:12px;color:#6B7280}
.footer{background:#F8FAFC;padding:30px 20px;text-align:center;color:#6B7280;border-top:1px solid #E5E7EB}
</style>
</head>
<body>
<div class="container">
  <div class="header">
    <img class="logo" src="$_logoUrl" alt="JobHunt Logo">
    <h1 style="margin:0">JobHunt</h1>
  </div>
  <div class="content">
    $content
  </div>
  <div class="footer">
    <p><strong>JobHunt Team</strong></p>
    <p>Connecting talent with opportunity</p>
    <p>© 2025 JobHunt. All rights reserved.</p>
  </div>
</div>
</body>
</html>
''',
      textContent: '''
New roles for you, Job Seeker

We found ${newJobs.length} new job${newJobs.length > 1 ? 's' : ''} that match your preferences.

${newJobs.map((job) => '''
${job['title'] ?? 'Job Title'}
${job['companyName'] ?? 'Company'} • ${job['location'] ?? 'Location'} • ${job['salary'] ?? 'Competitive'}
${job['description'] ?? 'Great opportunity for skilled professionals.'}
View & Apply: ${job['url'] ?? '#'}
''').join('\n\n')}

See All Matches: [Link]

You're receiving this alert because you enabled job notifications. Manage preferences: [Link]

Best regards,
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
    final topJobsHtml = jobs.take(3).map((job) => '''
        <div style="border: 1px solid #E5E7EB; border-radius: 8px; padding: 16px; background: #FAFAFA; margin: 12px 0;">
            <p style="font-weight: 700; color: #111827; margin: 0 0 6px;">${job['title'] ?? 'Job Title'}</p>
            <p style="font-size: 14px; color: #6B7280; margin: 0 0 8px;">${job['companyName'] ?? job['company'] ?? 'Company'} • ${job['location'] ?? 'Location'} • ${job['salaryRange'] ?? 'Competitive'}</p>
            <p style="font-size: 16px; line-height: 1.6; margin: 0 0 8px;">${job['description'] ?? 'Great opportunity for skilled professionals.'}</p>
            <a href="${job['url'] ?? '#'}" style="background: #2563EB; color: #fff; padding: 12px 22px; border-radius: 8px; font-weight: 700; text-decoration: none; display: inline-block;">View & Apply</a>
        </div>
    ''').join('');

    final content = '''
        <h2 style="font-size: 24px; font-weight: 800; margin: 0 0 10px;">Your weekly roundup, $recipientName</h2>
        <p style="font-size: 16px; line-height: 1.6; margin: 0 0 14px;">This week we found <strong>${jobs.length}</strong> new $category job${jobs.length > 1 ? 's' : ''} that fit your preferences.</p>

        <div style="border-radius: 12px; border: 1px solid #E5E7EB; padding: 18px; margin: 16px 0; background: #FFFFFF;">
            <h3 style="margin: 0 0 8px; font-size: 18px;">Top picks for you</h3>
            $topJobsHtml
        </div>

        <div style="border-radius: 12px; border: 1px solid #E5E7EB; padding: 18px; margin: 16px 0; background: #FFFFFF;">
            <h3 style="margin: 0 0 8px; font-size: 18px;">By category</h3>
            <p style="font-size: 16px; line-height: 1.6; margin: 0;">• $category: ${jobs.length} jobs</p>
            <p style="font-size: 16px; line-height: 1.6; margin: 0;">• Remote: ${(jobs.length * 0.3).round()} jobs</p>
            <p style="font-size: 16px; line-height: 1.6; margin: 0;">• Full-time: ${(jobs.length * 0.8).round()} jobs</p>
        </div>

        <p style="font-size: 16px; line-height: 1.6; margin: 0 0 14px;"><a href="#" style="background: #2563EB; color: #fff; padding: 12px 22px; border-radius: 8px; font-weight: 700; text-decoration: none; display: inline-block;">Browse All New Jobs</a></p>
        <p style="font-size: 12px; color: #6B7280;">You're receiving this weekly digest because you enabled email updates. <a href="#">Manage preferences</a>.</p>
    ''';

    return EmailTemplate(
      subject: '🗓️ Weekly Digest: ${jobs.length} new $category jobs for you',
      htmlContent: '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Weekly Job Digest</title>
<style>
:root{--primary:#2563EB;--text:#374151}
body{margin:0;background:#F3F4F6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Oxygen,Ubuntu,Cantarell,sans-serif;color:var(--text)}
.container{max-width:600px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 4px 6px rgba(0,0,0,.1)}
.header{background:linear-gradient(135deg,#2563EB,#1D4ED8);padding:40px 20px;text-align:center;color:#fff}
.header .logo{width:44px;margin-bottom:12px}
.content{padding:40px 20px}
.h1{font-size:24px;font-weight:800;margin:0 0 10px}
.p{font-size:16px;line-height:1.6;margin:0 0 14px}
.section{border-radius:12px;border:1px solid #E5E7EB;padding:18px;margin:16px 0;background:#FFFFFF}
.job{border:1px solid #E5E7EB;border-radius:8px;padding:16px;background:#FAFAFA;margin:12px 0}
.job .t{font-weight:700;color:#111827;margin:0 0 6px}
.meta{font-size:14px;color:#6B7280;margin:0 0 8px}
.btn{background:#2563EB;color:#fff;padding:12px 22px;border-radius:8px;font-weight:700;text-decoration:none;display:inline-block}
.small{font-size:12px;color:#6B7280}
.footer{background:#F8FAFC;padding:30px 20px;text-align:center;color:#6B7280;border-top:1px solid #E5E7EB}
</style>
</head>
<body>
<div class="container">
  <div class="header">
    <img class="logo" src="$_logoUrl" alt="JobHunt Logo">
    <h1 style="margin:0">JobHunt</h1>
  </div>
  <div class="content">
    $content
  </div>
  <div class="footer">
    <p><strong>JobHunt Team</strong></p>
    <p>Connecting talent with opportunity</p>
    <p>© 2025 JobHunt. All rights reserved.</p>
  </div>
</div>
</body>
</html>
''',
      textContent: '''
Your weekly roundup, $recipientName

This week we found ${jobs.length} new $category job${jobs.length > 1 ? 's' : ''} that fit your preferences.

Top picks for you:
${jobs.take(3).map((job) => '''
${job['title'] ?? 'Job Title'}
${job['companyName'] ?? job['company'] ?? 'Company'} • ${job['location'] ?? 'Location'} • ${job['salaryRange'] ?? 'Competitive'}
${job['description'] ?? 'Great opportunity for skilled professionals.'}
View & Apply: ${job['url'] ?? '#'}
''').join('\n\n')}

By category:
• $category: ${jobs.length} jobs
• Remote: ${(jobs.length * 0.3).round()} jobs
• Full-time: ${(jobs.length * 0.8).round()} jobs

Browse All New Jobs: [Link]

You're receiving this weekly digest because you enabled email updates. Manage preferences: [Link]

Best regards,
The JobHunt Team
''',
    );
  }

  /// Employer Account Created Email Template
  static EmailTemplate employerAccountCreated({
    required String recipientName,
    required String companyName,
    String? ticketId,
  }) {
    final content = '''
        <h2 style="font-size: 28px; font-weight: 700; margin: 0 0 8px; color: #111827;">Thanks for joining, $recipientName!</h2>
        <p style="font-size: 16px; line-height: 1.6; margin: 0 0 14px;">Your employer account for <strong>$companyName</strong> has been created and is currently <strong>pending admin approval</strong>.</p>

        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 20px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <div style="display: inline-block; background: #DBEAFE; color: #1E40AF; border-radius: 999px; padding: 6px 10px; font-weight: 700; font-size: 12px; margin-bottom: 8px;">What this means</div>
            <p style="font-size: 16px; line-height: 1.6; margin-bottom: 6px;">We review all employer accounts to keep JobHunt safe and trusted for candidates.</p>
            <div style="display: flex; gap: 10px; font-size: 15px; margin: 6px 0;"><b style="min-width: 140px;">Status</b><span>In review</span></div>
            <div style="display: flex; gap: 10px; font-size: 15px; margin: 6px 0;"><b style="min-width: 140px;">Submitted on</b><span>Today</span></div>
            ${ticketId != null ? '<div style="display: flex; gap: 10px; font-size: 15px; margin: 6px 0;"><b style="min-width: 140px;">Reference ID</b><span>$ticketId</span></div>' : ''}
        </div>

        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 20px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <div style="display: inline-block; background: #DBEAFE; color: #1E40AF; border-radius: 999px; padding: 6px 10px; font-weight: 700; font-size: 12px; margin-bottom: 8px;">Speed up approval</div>
            <ul style="font-size: 16px; line-height: 1.6; margin: 0; padding-left: 18px;">
                <li>Ensure your <strong>company profile</strong> is complete (logo, website, about, address)</li>
                <li>Use a <strong>work email domain</strong> (e.g., hr@yourcompany.com)</li>
                <li>Upload any required <strong>verification documents</strong> (if requested)</li>
            </ul>
        </div>

        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 20px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <div style="display: inline-block; background: #DBEAFE; color: #1E40AF; border-radius: 999px; padding: 6px 10px; font-weight: 700; font-size: 12px; margin-bottom: 8px;">While you wait</div>
            <ul style="font-size: 16px; line-height: 1.6; margin: 0; padding-left: 18px;">
                <li>Draft your first job post (you can publish once approved)</li>
                <li>Set up your <strong>hiring preferences</strong> and screening questions</li>
                <li>Invite team members to collaborate on hiring</li>
            </ul>
        </div>

        <p style="font-size: 16px; line-height: 1.6; margin: 0 0 14px;"><a href="#" style="background: #2563EB; color: #fff; padding: 12px 22px; border-radius: 8px; font-weight: 700; text-decoration: none; display: inline-block;">Open Employer Dashboard</a></p>
        <p style="font-size: 13px; color: #6B7280;">Need help? Visit the <a href="#" style="color: #2563EB; text-decoration: none;">Help Center</a> or email us at support@jobhunt.app.</p>
    ''';

    return EmailTemplate(
      subject:
          'Welcome to JobHunt — Employer Account Created (Pending Approval)',
      htmlContent: '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width">
<title>Employer Account — Pending Approval</title>
<style>
:root{
  --primary-color:#2563EB;--primary-600:#1D4ED8;
  --surface:#FFFFFF;--bg:#F3F4F6;
  --text:#374151;--text-dark:#111827;--muted:#6B7280;
  --border:#E5E7EB;--success:#10B981;--error:#EF4444;
}
body{margin:0;background:var(--bg);font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Oxygen,Ubuntu,Cantarell,sans-serif;color:var(--text)}
.container{max-width:600px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 4px 6px rgba(0,0,0,.1)}
.header{background:linear-gradient(135deg,var(--primary-color) 0%,var(--primary-600) 100%);padding:40px 20px;text-align:center;color:#fff}
.header .logo{width:44px;height:auto;margin-bottom:12px}
.content{padding:40px 20px}
.h1{font-size:28px;font-weight:700;margin:0 0 8px;color:var(--text-dark)}
.p{font-size:16px;line-height:1.6;margin:0 0 14px}
.card{background:#fff;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,.06);padding:20px;margin:16px 0;border:1px solid var(--border)}
.badge{display:inline-block;background:#DBEAFE;color:#1E40AF;border-radius:999px;padding:6px 10px;font-weight:700;font-size:12px;margin-bottom:8px}
.kv{display:flex;gap:10px;font-size:15px;margin:6px 0}
.kv b{min-width:140px}
.btn{background:var(--primary-color);color:#fff;padding:12px 22px;border-radius:8px;font-weight:700;text-decoration:none;display:inline-block}
.link{color:var(--primary-color);text-decoration:none}
.footer{background:#F8FAFC;padding:30px 20px;text-align:center;color:var(--muted);border-top:1px solid var(--border)}
.small{font-size:13px;color:var(--muted)}
</style>
</head>
<body>
<div class="container">
  <div class="header">
    <img class="logo" src="$_logoUrl" alt="JobHunt Logo">
    <h1 style="margin:0">JobHunt</h1>
  </div>
  <div class="content">
    $content
  </div>
  <div class="footer">
    <p><strong>JobHunt Team</strong></p>
    <p>Connecting talent with opportunity</p>
    <p>© 2025 JobHunt. All rights reserved.</p>
  </div>
</div>
</body>
</html>
''',
      textContent: '''
Thanks for joining, $recipientName!

Your employer account for $companyName has been created and is currently pending admin approval.

What this means:
We review all employer accounts to keep JobHunt safe and trusted for candidates.

Account Details:
- Status: In review
- Submitted on: Today
${ticketId != null ? '- Reference ID: $ticketId' : ''}

Speed up approval:
- Ensure your company profile is complete (logo, website, about, address)
- Use a work email domain (e.g., hr@yourcompany.com)
- Upload any required verification documents (if requested)

While you wait:
- Draft your first job post (you can publish once approved)
- Set up your hiring preferences and screening questions
- Invite team members to collaborate on hiring

Open Employer Dashboard: [Link]

Need help? Visit the Help Center or email us at support@jobhunt.app.

Best regards,
The JobHunt Team
''',
    );
  }

  /// Employer Welcome Email Template
  static EmailTemplate employerWelcome({
    required String recipientName,
    required String companyName,
    String? companyWebsite,
  }) {
    final content = '''
        <div style="background: linear-gradient(135deg, #8B5CF6 0%, #A855F7 50%, #C084FC 100%); border-radius: 12px; padding: 40px 20px; text-align: center; color: #fff; margin: -20px 0 20px;">
            <h2 style="font-size: 28px; font-weight: 800; margin: 0 0 8px;">🎉 Congratulations, $recipientName!</h2>
            <p style="font-size: 16px; line-height: 1.6; margin: 0;">Your employer account for <strong>$companyName</strong> is approved and ready to hire.</p>
        </div>

        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 20px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <h3 style="margin: 0 0 8px; font-size: 18px;">Start hiring in minutes</h3>
            <ol style="font-size: 16px; line-height: 1.6; margin: 0; padding-left: 18px;">
                <li>Create your first job post (title, description, skills, salary, location)</li>
                <li>Set screening questions and must-have criteria</li>
                <li>Publish and share your job link to attract candidates fast</li>
            </ol>
            <p style="font-size: 16px; line-height: 1.6; margin-top: 10px;">
                <a href="#" style="background: #2563EB; color: #fff; padding: 12px 22px; border-radius: 8px; font-weight: 800; text-decoration: none; display: inline-block;">Post a Job</a>
                &nbsp;&nbsp;<a href="#" style="background: transparent; color: #2563EB; border: 2px solid #2563EB; padding: 10px 18px; border-radius: 8px; font-weight: 700; text-decoration: none; display: inline-block;">Open Employer Dashboard</a>
            </p>
        </div>

        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 20px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <h3 style="margin: 0 0 8px; font-size: 18px;">Best practices for great results</h3>
            <ul style="font-size: 16px; line-height: 1.6; margin: 0; padding-left: 18px;">
                <li>Write a clear, concise role summary with 5–7 key responsibilities</li>
                <li>List 4–6 specific, measurable requirements (skills, years, tech)</li>
                <li>Show a realistic salary range and perks to boost conversion</li>
                <li>Respond to shortlisted candidates within 24–48 hours</li>
            </ul>
        </div>

        <div style="background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,.06); padding: 20px; margin: 16px 0; border: 1px solid #E5E7EB;">
            <h3 style="margin: 0 0 8px; font-size: 18px;">Your account</h3>
            <div style="display: flex; gap: 10px; font-size: 15px; margin: 6px 0;"><b style="min-width: 140px;">Company</b><span>$companyName</span></div>
            ${companyWebsite != null ? '<div style="display: flex; gap: 10px; font-size: 15px; margin: 6px 0;"><b style="min-width: 140px;">Website</b><span><a href="$companyWebsite">$companyWebsite</a></span></div>' : ''}
            <div style="display: flex; gap: 10px; font-size: 15px; margin: 6px 0;"><b style="min-width: 140px;">Team members</b><span><a href="#">Invite collaborators</a></span></div>
            <div style="display: flex; gap: 10px; font-size: 15px; margin: 6px 0;"><b style="min-width: 140px;">Billing & receipts</b><span><a href="#">Manage billing</a></span></div>
        </div>

        <p style="font-size: 13px; color: #6B7280;">Need help? Visit the <a href="#" style="color: #2563EB; text-decoration: none;">Help Center</a> or email us at support@jobhunt.app.</p>
    ''';

    return EmailTemplate(
      subject: '🎉 Welcome to JobHunt — Employer Account Approved!',
      htmlContent: '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width">
<title>Employer Welcome — Account Approved</title>
<style>
:root{
  --primary:#2563EB;--primary-600:#1D4ED8;
  --text:#374151;--dark:#111827;--muted:#6B7280;--border:#E5E7EB;
}
body{margin:0;background:#F3F4F6;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Oxygen,Ubuntu,Cantarell,sans-serif;color:var(--text)}
.container{max-width:600px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 4px 6px rgba(0,0,0,.1)}
.header{background:linear-gradient(135deg,var(--primary) 0%,var(--primary-600) 100%);padding:40px 20px;text-align:center;color:#fff}
.header .logo{width:44px;height:auto;margin-bottom:12px}
.content{padding:0 20px 30px}
.banner{background:linear-gradient(135deg,#8B5CF6 0%,#A855F7 50%,#C084FC 100%);border-radius:12px;padding:40px 20px;text-align:center;color:#fff;margin:-20px 0 20px}
.h1{font-size:28px;font-weight:800;margin:0 0 8px}
.p{font-size:16px;line-height:1.6;margin:0 0 14px}
.card{background:#fff;border-radius:12px;box-shadow:0 4px 6px rgba(0,0,0,.06);padding:20px;margin:16px 0;border:1px solid var(--border)}
.list{padding-left:18px;margin:0}
.btn{background:var(--primary);color:#fff;padding:12px 22px;border-radius:8px;font-weight:800;text-decoration:none;display:inline-block}
.btn--ghost{background:transparent;color:var(--primary);border:2px solid var(--primary);padding:10px 18px;border-radius:8px;font-weight:700;text-decoration:none;display:inline-block}
.kv{display:flex;gap:10px;font-size:15px;margin:6px 0}
.kv b{min-width:140px}
.footer{background:#F8FAFC;padding:30px 20px;text-align:center;color:var(--muted);border-top:1px solid var(--border)}
.small{font-size:13px;color:var(--muted)}
</style>
</head>
<body>
<div class="container">
  <div class="header">
    <img class="logo" src="$_logoUrl" alt="JobHunt Logo">
    <h1 style="margin:0">JobHunt</h1>
  </div>

  <div class="content">
    $content
  </div>

  <div class="footer">
    <p><strong>JobHunt Team</strong></p>
    <p>Connecting talent with opportunity</p>
    <p>© 2025 JobHunt. All rights reserved.</p>
  </div>
</div>
</body>
</html>
''',
      textContent: '''
🎉 Congratulations, $recipientName!

Your employer account for $companyName is approved and ready to hire.

Start hiring in minutes:
1. Create your first job post (title, description, skills, salary, location)
2. Set screening questions and must-have criteria
3. Publish and share your job link to attract candidates fast

Post a Job: [Link]
Open Employer Dashboard: [Link]

Best practices for great results:
- Write a clear, concise role summary with 5–7 key responsibilities
- List 4–6 specific, measurable requirements (skills, years, tech)
- Show a realistic salary range and perks to boost conversion
- Respond to shortlisted candidates within 24–48 hours

Your account:
- Company: $companyName
${companyWebsite != null ? '- Website: $companyWebsite' : ''}
- Team members: Invite collaborators [Link]
- Billing & receipts: Manage billing [Link]

Need help? Visit the Help Center or email us at support@jobhunt.app.

Best regards,
The JobHunt Team
''',
    );
  }
}
