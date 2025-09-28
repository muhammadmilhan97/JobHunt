class EmailTemplate {
  // Base template with JobHunt branding
  static String _baseTemplate({
    required String title,
    required String content,
    required String role,
    String? actionButtonText,
    String? actionButtonUrl,
    String? additionalInfo,
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
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8fafc;
            line-height: 1.6;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        }
        .header {
            background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
            padding: 30px 20px;
            text-align: center;
            color: white;
        }
        .logo {
            width: 60px;
            height: 60px;
            background-color: white;
            border-radius: 12px;
            margin: 0 auto 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            font-weight: bold;
            color: #3b82f6;
        }
        .header h1 {
            margin: 0;
            font-size: 28px;
            font-weight: 700;
        }
        .header p {
            margin: 8px 0 0;
            font-size: 16px;
            opacity: 0.9;
        }
        .content {
            padding: 40px 30px;
        }
        .content h2 {
            color: #1f2937;
            font-size: 24px;
            margin: 0 0 20px;
            font-weight: 600;
        }
        .content p {
            color: #4b5563;
            font-size: 16px;
            margin: 0 0 20px;
        }
        .highlight-box {
            background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
            border-left: 4px solid #3b82f6;
            padding: 20px;
            margin: 25px 0;
            border-radius: 8px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin: 25px 0;
        }
        .info-item {
            background-color: #f9fafb;
            padding: 15px;
            border-radius: 8px;
            border: 1px solid #e5e7eb;
        }
        .info-label {
            font-weight: 600;
            color: #374151;
            font-size: 14px;
            margin-bottom: 5px;
        }
        .info-value {
            color: #1f2937;
            font-size: 16px;
        }
        .action-button {
            display: inline-block;
            background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
            color: white;
            padding: 15px 30px;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            font-size: 16px;
            margin: 25px 0;
            text-align: center;
            transition: transform 0.2s;
        }
        .action-button:hover {
            transform: translateY(-2px);
        }
        .footer {
            background-color: #f8fafc;
            padding: 30px;
            text-align: center;
            border-top: 1px solid #e5e7eb;
        }
        .footer p {
            color: #6b7280;
            font-size: 14px;
            margin: 5px 0;
        }
        .social-links {
            margin: 20px 0;
        }
        .social-links a {
            color: #3b82f6;
            text-decoration: none;
            margin: 0 10px;
            font-weight: 500;
        }
        .role-badge {
            display: inline-block;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .status-pending {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
        }
        .status-approved {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        }
        .status-rejected {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
        }
        @media (max-width: 600px) {
            .container {
                margin: 10px;
                border-radius: 8px;
            }
            .content {
                padding: 30px 20px;
            }
            .info-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">JH</div>
            <h1>$title</h1>
            <p>JobHunt - Your Career Journey Starts Here</p>
        </div>
        
        <div class="content">
            $content
            
            ${actionButtonText != null && actionButtonUrl != null ? '''
            <div style="text-align: center; margin: 30px 0;">
                <a href="$actionButtonUrl" class="action-button">$actionButtonText</a>
            </div>
            ''' : ''}
            
            ${additionalInfo != null ? '''
            <div class="highlight-box">
                $additionalInfo
            </div>
            ''' : ''}
        </div>
        
        <div class="footer">
            <p><strong>JobHunt Team</strong></p>
            <p>Connecting talent with opportunity</p>
            <div class="social-links">
                <a href="#">Website</a> | <a href="#">Support</a> | <a href="#">Privacy</a>
            </div>
            <p style="font-size: 12px; color: #9ca3af; margin-top: 20px;">
                This email was sent to you because you have an account with JobHunt. 
                If you no longer wish to receive these emails, you can unsubscribe.
            </p>
        </div>
    </div>
</body>
</html>
''';
  }

  // 1. Account Created (Pending Approval) - Job Seeker
  static String accountCreatedJobSeeker({
    required String recipientName,
    required String email,
  }) {
    return _baseTemplate(
      title: 'Welcome to JobHunt!',
      role: 'Job Seeker',
      content: '''
        <h2>Hello $recipientName! 👋</h2>
        
        <p>Welcome to <strong>JobHunt</strong> - Pakistan's premier job search platform! We're thrilled to have you join our community of talented professionals.</p>
        
        <div class="highlight-box">
            <h3 style="margin-top: 0; color: #1e40af;">📋 Your Account Status</h3>
            <p style="margin-bottom: 0;"><span class="role-badge status-pending">Pending Approval</span></p>
            <p>Your account is currently under review by our team. This process typically takes 24-48 hours.</p>
        </div>
        
        <h3>🎯 What's Next?</h3>
        <ul style="color: #4b5563; padding-left: 20px;">
            <li><strong>Complete Your Profile:</strong> Add your skills, experience, and career preferences</li>
            <li><strong>Upload Your CV:</strong> Make sure your resume is up-to-date and professional</li>
            <li><strong>Set Job Alerts:</strong> Get notified about jobs that match your criteria</li>
            <li><strong>Explore Opportunities:</strong> Browse thousands of job listings across Pakistan</li>
        </ul>
        
        <div class="info-grid">
            <div class="info-item">
                <div class="info-label">Email Address</div>
                <div class="info-value">$email</div>
            </div>
            <div class="info-item">
                <div class="info-label">Account Type</div>
                <div class="info-value">Job Seeker</div>
            </div>
        </div>
        
        <h3>💡 Pro Tips for Success</h3>
        <ul style="color: #4b5563; padding-left: 20px;">
            <li>Use relevant keywords in your profile to improve search visibility</li>
            <li>Keep your profile updated with recent achievements</li>
            <li>Apply to jobs that closely match your skills and experience</li>
            <li>Follow companies you're interested in for job updates</li>
        </ul>
      ''',
      actionButtonText: 'Complete Your Profile',
      actionButtonUrl: 'https://jobhunt.pk/profile',
      additionalInfo: '''
        <h4 style="margin-top: 0; color: #1e40af;">📞 Need Help?</h4>
        <p style="margin-bottom: 0;">Our support team is here to help you succeed. Contact us at <strong>support@jobhunt.pk</strong> or call <strong>+92-XXX-XXXXXXX</strong>.</p>
      ''',
    );
  }

  // 2. Account Created (Pending Approval) - Employer
  static String accountCreatedEmployer({
    required String recipientName,
    required String companyName,
    required String email,
  }) {
    return _baseTemplate(
      title: 'Welcome to JobHunt!',
      role: 'Employer',
      content: '''
        <h2>Hello $recipientName! 👋</h2>
        
        <p>Welcome to <strong>JobHunt</strong> - Pakistan's leading recruitment platform! We're excited to help $companyName find the best talent.</p>
        
        <div class="highlight-box">
            <h3 style="margin-top: 0; color: #1e40af;">📋 Your Account Status</h3>
            <p style="margin-bottom: 0;"><span class="role-badge status-pending">Pending Approval</span></p>
            <p>Your employer account is currently under review. Our team will verify your company details within 24-48 hours.</p>
        </div>
        
        <h3>🚀 What's Next?</h3>
        <ul style="color: #4b5563; padding-left: 20px;">
            <li><strong>Complete Company Profile:</strong> Add your company information, culture, and benefits</li>
            <li><strong>Upload Company Logo:</strong> Make your job postings stand out with your branding</li>
            <li><strong>Set Hiring Preferences:</strong> Define your ideal candidate criteria</li>
            <li><strong>Post Your First Job:</strong> Start attracting top talent immediately</li>
        </ul>
        
        <div class="info-grid">
            <div class="info-item">
                <div class="info-label">Company Name</div>
                <div class="info-value">$companyName</div>
            </div>
            <div class="info-item">
                <div class="info-label">Contact Email</div>
                <div class="info-value">$email</div>
            </div>
        </div>
        
        <h3>💼 Employer Benefits</h3>
        <ul style="color: #4b5563; padding-left: 20px;">
            <li>Access to thousands of qualified candidates</li>
            <li>Advanced filtering and search capabilities</li>
            <li>Real-time application tracking and analytics</li>
            <li>Dedicated account manager support</li>
        </ul>
      ''',
      actionButtonText: 'Complete Company Profile',
      actionButtonUrl: 'https://jobhunt.pk/employer/company',
      additionalInfo: '''
        <h4 style="margin-top: 0; color: #1e40af;">📞 Need Help?</h4>
        <p style="margin-bottom: 0;">Our employer success team is ready to help. Contact us at <strong>employers@jobhunt.pk</strong> or call <strong>+92-XXX-XXXXXXX</strong>.</p>
      ''',
    );
  }

  // 3. Account Approved - Job Seeker
  static String accountApprovedJobSeeker({
    required String recipientName,
  }) {
    return _baseTemplate(
      title: 'Account Approved! 🎉',
      role: 'Job Seeker',
      content: '''
        <h2>Congratulations $recipientName! 🎉</h2>
        
        <p>Great news! Your JobHunt account has been <strong>approved</strong> and you're now ready to start your job search journey.</p>
        
        <div class="highlight-box">
            <h3 style="margin-top: 0; color: #059669;">✅ Account Status</h3>
            <p style="margin-bottom: 0;"><span class="role-badge status-approved">Approved & Active</span></p>
            <p>You can now access all features and start applying to jobs immediately.</p>
        </div>
        
        <h3>🚀 Ready to Get Started?</h3>
        <ul style="color: #4b5563; padding-left: 20px;">
            <li><strong>Browse Jobs:</strong> Explore thousands of opportunities across Pakistan</li>
            <li><strong>Set Job Alerts:</strong> Get notified about new jobs matching your criteria</li>
            <li><strong>Apply with One Click:</strong> Submit applications quickly and easily</li>
            <li><strong>Track Applications:</strong> Monitor your application status in real-time</li>
        </ul>
        
        <h3>💡 Maximize Your Success</h3>
        <ul style="color: #4b5563; padding-left: 20px;">
            <li>Complete your profile to 100% for better visibility</li>
            <li>Upload a professional CV and cover letter template</li>
            <li>Set up job alerts for your preferred locations and roles</li>
            <li>Follow companies you're interested in working for</li>
        </ul>
      ''',
      actionButtonText: 'Start Job Search',
      actionButtonUrl: 'https://jobhunt.pk/jobs',
    );
  }

  // 4. Account Approved - Employer
  static String accountApprovedEmployer({
    required String recipientName,
    required String companyName,
  }) {
    return _baseTemplate(
      title: 'Account Approved! 🎉',
      role: 'Employer',
      content: '''
        <h2>Congratulations $recipientName! 🎉</h2>
        
        <p>Excellent! Your JobHunt employer account has been <strong>approved</strong> and $companyName is now ready to start recruiting top talent.</p>
        
        <div class="highlight-box">
            <h3 style="margin-top: 0; color: #059669;">✅ Account Status</h3>
            <p style="margin-bottom: 0;"><span class="role-badge status-approved">Approved & Active</span></p>
            <p>You can now post jobs, browse candidates, and access all employer features.</p>
        </div>
        
        <h3>🚀 Ready to Recruit?</h3>
        <ul style="color: #4b5563; padding-left: 20px;">
            <li><strong>Post Your First Job:</strong> Create compelling job listings that attract top talent</li>
            <li><strong>Browse Candidates:</strong> Search through thousands of qualified professionals</li>
            <li><strong>Use Advanced Filters:</strong> Find candidates with specific skills and experience</li>
            <li><strong>Track Applications:</strong> Manage your hiring pipeline efficiently</li>
        </ul>
        
        <h3>💼 Employer Dashboard Features</h3>
        <ul style="color: #4b5563; padding-left: 20px;">
            <li>Real-time analytics and hiring insights</li>
            <li>Bulk application management tools</li>
            <li>Custom job posting templates</li>
            <li>Direct messaging with candidates</li>
        </ul>
      ''',
      actionButtonText: 'Post Your First Job',
      actionButtonUrl: 'https://jobhunt.pk/employer/post-job',
    );
  }

  // 5. Account Rejected
  static String accountRejected({
    required String recipientName,
    required String reason,
  }) {
    return _baseTemplate(
      title: 'Account Review Update',
      role: 'User',
      content: '''
        <h2>Hello $recipientName,</h2>
        
        <p>Thank you for your interest in joining JobHunt. After careful review, we're unable to approve your account at this time.</p>
        
        <div class="highlight-box">
            <h3 style="margin-top: 0; color: #dc2626;">❌ Account Status</h3>
            <p style="margin-bottom: 0;"><span class="role-badge status-rejected">Not Approved</span></p>
            <p><strong>Reason:</strong> $reason</p>
        </div>
        
        <h3>🔄 What You Can Do</h3>
        <ul style="color: #4b5563; padding-left: 20px;">
            <li><strong>Review Your Information:</strong> Ensure all details are accurate and complete</li>
            <li><strong>Update Your Profile:</strong> Make necessary corrections and improvements</li>
            <li><strong>Reapply:</strong> Submit a new application with updated information</li>
            <li><strong>Contact Support:</strong> Reach out if you have questions about the decision</li>
        </ul>
        
        <h3>📞 Need Help?</h3>
        <p>If you believe this decision was made in error or need assistance with your application, please contact our support team:</p>
        <ul style="color: #4b5563; padding-left: 20px;">
            <li>Email: <strong>support@jobhunt.pk</strong></li>
            <li>Phone: <strong>+92-XXX-XXXXXXX</strong></li>
            <li>Live Chat: Available on our website</li>
        </ul>
      ''',
      actionButtonText: 'Contact Support',
      actionButtonUrl: 'https://jobhunt.pk/support',
    );
  }

  // 6. Job Posting Confirmation - Employer
  static String jobPostingConfirmation({
    required String recipientName,
    required String companyName,
    required String jobTitle,
    required String jobId,
    required String location,
    required String salary,
    required String jobType,
  }) {
    return _baseTemplate(
      title: 'Job Posted Successfully! 🎉',
      role: 'Employer',
      content: '''
        <h2>Congratulations $recipientName! 🎉</h2>
        
        <p>Your job posting has been successfully published and is now live on JobHunt. Get ready to receive applications from qualified candidates!</p>
        
        <div class="highlight-box">
            <h3 style="margin-top: 0; color: #059669;">✅ Job Posted Successfully</h3>
            <p style="margin-bottom: 0;">Your job is now visible to thousands of job seekers across Pakistan.</p>
        </div>
        
        <h3>📋 Job Details</h3>
        <div class="info-grid">
            <div class="info-item">
                <div class="info-label">Job Title</div>
                <div class="info-value">$jobTitle</div>
            </div>
            <div class="info-item">
                <div class="info-label">Company</div>
                <div class="info-value">$companyName</div>
            </div>
            <div class="info-item">
                <div class="info-label">Location</div>
                <div class="info-value">$location</div>
            </div>
            <div class="info-item">
                <div class="info-label">Job Type</div>
                <div class="info-value">$jobType</div>
            </div>
            <div class="info-item">
                <div class="info-label">Salary Range</div>
                <div class="info-value">$salary</div>
            </div>
            <div class="info-item">
                <div class="info-label">Job ID</div>
                <div class="info-value">$jobId</div>
            </div>
        </div>
        
        <h3>🚀 What Happens Next?</h3>
        <ul style="color: #4b5563; padding-left: 20px;">
            <li><strong>Applications Start Coming In:</strong> Qualified candidates will begin applying</li>
            <li><strong>Real-time Notifications:</strong> Get notified of new applications instantly</li>
            <li><strong>Review & Shortlist:</strong> Use our tools to review and shortlist candidates</li>
            <li><strong>Schedule Interviews:</strong> Contact candidates directly through our platform</li>
        </ul>
        
        <h3>💡 Pro Tips for Success</h3>
        <ul style="color: #4b5563; padding-left: 20px;">
            <li>Check your job posting regularly for new applications</li>
            <li>Respond to candidates promptly to maintain engagement</li>
            <li>Use our analytics to track job performance</li>
            <li>Consider promoting your job for better visibility</li>
        </ul>
      ''',
      actionButtonText: 'View Job Dashboard',
      actionButtonUrl: 'https://jobhunt.pk/employer/job/$jobId',
      additionalInfo: '''
        <h4 style="margin-top: 0; color: #1e40af;">📊 Track Your Job Performance</h4>
        <p style="margin-bottom: 0;">Monitor views, applications, and candidate quality through your employer dashboard. Access detailed analytics to optimize your hiring process.</p>
      ''',
    );
  }

  // 7. Application Status Update - Job Seeker
  static String applicationStatusUpdate({
    required String recipientName,
    required String jobTitle,
    required String companyName,
    required String status,
    required String applicationId,
    String? interviewDate,
    String? interviewTime,
    String? notes,
  }) {
    String statusContent = '';
    String statusColor = '';
    String statusIcon = '';

    switch (status.toLowerCase()) {
      case 'reviewing':
        statusContent =
            'Your application is being reviewed by the hiring team.';
        statusColor = '#f59e0b';
        statusIcon = '👀';
        break;
      case 'interviewing':
        statusContent =
            'Congratulations! You\'ve been selected for an interview.';
        statusColor = '#3b82f6';
        statusIcon = '🎯';
        break;
      case 'accepted':
        statusContent = 'Congratulations! Your application has been accepted.';
        statusColor = '#10b981';
        statusIcon = '🎉';
        break;
      case 'rejected':
        statusContent =
            'Thank you for your interest. Unfortunately, we\'ve decided to move forward with other candidates.';
        statusColor = '#ef4444';
        statusIcon = '😔';
        break;
      default:
        statusContent = 'Your application status has been updated.';
        statusColor = '#6b7280';
        statusIcon = '📝';
    }

    return _baseTemplate(
      title: 'Application Status Update',
      role: 'Job Seeker',
      content: '''
        <h2>Hello $recipientName! $statusIcon</h2>
        
        <p>We have an update regarding your application for the <strong>$jobTitle</strong> position at <strong>$companyName</strong>.</p>
        
        <div class="highlight-box" style="border-left-color: $statusColor;">
            <h3 style="margin-top: 0; color: $statusColor;">$statusIcon Application Status</h3>
            <p style="margin-bottom: 0;"><span class="role-badge" style="background: $statusColor;">${status.toUpperCase()}</span></p>
            <p>$statusContent</p>
        </div>
        
        <h3>📋 Application Details</h3>
        <div class="info-grid">
            <div class="info-item">
                <div class="info-label">Job Title</div>
                <div class="info-value">$jobTitle</div>
            </div>
            <div class="info-item">
                <div class="info-label">Company</div>
                <div class="info-value">$companyName</div>
            </div>
            <div class="info-item">
                <div class="info-label">Application ID</div>
                <div class="info-value">$applicationId</div>
            </div>
            <div class="info-item">
                <div class="info-label">Status</div>
                <div class="info-value">${status.toUpperCase()}</div>
            </div>
        </div>
        
        ${interviewDate != null && interviewTime != null ? '''
        <h3>📅 Interview Details</h3>
        <div class="highlight-box">
            <h4 style="margin-top: 0; color: #1e40af;">Interview Scheduled</h4>
            <p><strong>Date:</strong> $interviewDate</p>
            <p><strong>Time:</strong> $interviewTime</p>
            <p>Please prepare for your interview and arrive on time. Good luck!</p>
        </div>
        ''' : ''}
        
        ${notes != null ? '''
        <h3>📝 Additional Notes</h3>
        <div class="highlight-box">
            <p style="margin-bottom: 0;">$notes</p>
        </div>
        ''' : ''}
        
        <h3>🚀 Next Steps</h3>
        <ul style="color: #4b5563; padding-left: 20px;">
            ${status.toLowerCase() == 'reviewing' ? '<li>Wait for further updates from the hiring team</li>' : ''}
            ${status.toLowerCase() == 'interviewing' ? '<li>Prepare for your interview by researching the company</li><li>Review the job description and prepare relevant questions</li>' : ''}
            ${status.toLowerCase() == 'accepted' ? '<li>Wait for contact from the company regarding next steps</li><li>Prepare for onboarding and your new role</li>' : ''}
            ${status.toLowerCase() == 'rejected' ? '<li>Continue applying to other opportunities</li><li>Consider asking for feedback to improve future applications</li>' : ''}
            <li>Keep your JobHunt profile updated with new skills and experience</li>
        </ul>
      ''',
      actionButtonText: status.toLowerCase() == 'accepted'
          ? 'View Other Jobs'
          : 'Browse More Jobs',
      actionButtonUrl: 'https://jobhunt.pk/jobs',
    );
  }

  // 8. Job Alerts - Job Seeker
  static String jobAlerts({
    required String recipientName,
    required List<Map<String, String>> jobs,
  }) {
    String jobListHtml = '';
    for (var job in jobs.take(5)) {
      jobListHtml += '''
        <div class="info-item" style="margin-bottom: 15px;">
            <div style="display: flex; justify-content: space-between; align-items: start;">
                <div>
                    <div class="info-label">${job['title']}</div>
                    <div class="info-value">${job['company']} • ${job['location']}</div>
                    <div style="color: #6b7280; font-size: 14px; margin-top: 5px;">${job['salary']}</div>
                </div>
                <a href="${job['url']}" style="background: #3b82f6; color: white; padding: 8px 16px; border-radius: 6px; text-decoration: none; font-size: 14px; font-weight: 500;">Apply</a>
            </div>
        </div>
      ''';
    }

    return _baseTemplate(
      title: 'New Jobs Matching Your Profile! 🔥',
      role: 'Job Seeker',
      content: '''
        <h2>Hello $recipientName! 🔥</h2>
        
        <p>Great news! We found <strong>${jobs.length}</strong> new job opportunities that match your profile and preferences.</p>
        
        <div class="highlight-box">
            <h3 style="margin-top: 0; color: #1e40af;">🎯 Personalized Job Recommendations</h3>
            <p style="margin-bottom: 0;">These jobs are selected based on your skills, experience, and location preferences.</p>
        </div>
        
        <h3>💼 Recommended Jobs</h3>
        $jobListHtml
        
        <h3>🚀 Why These Jobs?</h3>
        <ul style="color: #4b5563; padding-left: 20px;">
            <li><strong>Skills Match:</strong> These roles align with your technical and soft skills</li>
            <li><strong>Experience Level:</strong> Suitable for your career stage and background</li>
            <li><strong>Location:</strong> Based on your preferred work locations</li>
            <li><strong>Salary Range:</strong> Within your expected compensation range</li>
        </ul>
        
        <h3>💡 Pro Tips</h3>
        <ul style="color: #4b5563; padding-left: 20px;">
            <li>Apply quickly - good jobs get filled fast!</li>
            <li>Customize your cover letter for each application</li>
            <li>Follow companies you're interested in for future opportunities</li>
            <li>Update your job alert preferences to get more relevant matches</li>
        </ul>
      ''',
      actionButtonText: 'View All Jobs',
      actionButtonUrl: 'https://jobhunt.pk/jobs',
      additionalInfo: '''
        <h4 style="margin-top: 0; color: #1e40af;">🔔 Manage Your Job Alerts</h4>
        <p style="margin-bottom: 0;">Want to receive more or fewer alerts? <a href="https://jobhunt.pk/job-alerts" style="color: #3b82f6;">Update your preferences</a> to get the perfect job recommendations.</p>
      ''',
    );
  }

  // 9. Weekly Job Digest - Job Seeker
  static String weeklyJobDigest({
    required String recipientName,
    required Map<String, dynamic> stats,
    required List<Map<String, String>> featuredJobs,
    required List<Map<String, String>> trendingCompanies,
  }) {
    return _baseTemplate(
      title: 'Weekly Job Digest 📊',
      role: 'Job Seeker',
      content: '''
        <h2>Hello $recipientName! 📊</h2>
        
        <p>Here's your weekly roundup of the job market in Pakistan. Stay ahead of the competition with these insights and opportunities!</p>
        
        <div class="highlight-box">
            <h3 style="margin-top: 0; color: #1e40af;">📈 This Week's Market Stats</h3>
            <div class="info-grid">
                <div class="info-item">
                    <div class="info-label">New Jobs Posted</div>
                    <div class="info-value">${stats['newJobs']}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Companies Hiring</div>
                    <div class="info-value">${stats['companiesHiring']}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Average Applications</div>
                    <div class="info-value">${stats['avgApplications']}</div>
                </div>
                <div class="info-item">
                    <div class="info-label">Hot Skills</div>
                    <div class="info-value">${stats['hotSkills']}</div>
                </div>
            </div>
        </div>
        
        <h3>⭐ Featured Jobs This Week</h3>
        ${featuredJobs.map((job) => '''
        <div class="info-item" style="margin-bottom: 15px;">
            <div style="display: flex; justify-content: space-between; align-items: start;">
                <div>
                    <div class="info-label">${job['title']}</div>
                    <div class="info-value">${job['company']} • ${job['location']}</div>
                    <div style="color: #6b7280; font-size: 14px; margin-top: 5px;">${job['salary']} • ${job['type']}</div>
                </div>
                <a href="${job['url']}" style="background: #3b82f6; color: white; padding: 8px 16px; border-radius: 6px; text-decoration: none; font-size: 14px; font-weight: 500;">Apply</a>
            </div>
        </div>
        ''').join('')}
        
        <h3>🚀 Trending Companies</h3>
        <div class="info-grid">
            ${trendingCompanies.map((company) => '''
            <div class="info-item">
                <div class="info-label">${company['name']}</div>
                <div class="info-value">${company['openings']} open positions</div>
            </div>
            ''').join('')}
        </div>
        
        <h3>💡 Market Insights</h3>
        <ul style="color: #4b5563; padding-left: 20px;">
            <li><strong>Remote Work:</strong> ${stats['remotePercentage']}% of jobs now offer remote work options</li>
            <li><strong>Salary Trends:</strong> Average salaries have increased by ${stats['salaryIncrease']}% this quarter</li>
            <li><strong>In-Demand Skills:</strong> ${stats['topSkills']} are the most sought-after skills</li>
            <li><strong>Hiring Timeline:</strong> Companies are taking an average of ${stats['hiringTimeline']} days to fill positions</li>
        </ul>
      ''',
      actionButtonText: 'Explore All Jobs',
      actionButtonUrl: 'https://jobhunt.pk/jobs',
      additionalInfo: '''
        <h4 style="margin-top: 0; color: #1e40af;">📊 Your Job Search Progress</h4>
        <p style="margin-bottom: 0;">You've applied to <strong>${stats['userApplications']}</strong> jobs this week. Keep up the great work! <a href="https://jobhunt.pk/dashboard" style="color: #3b82f6;">View your dashboard</a> to track your applications.</p>
      ''',
    );
  }

  // Text versions for email clients that don't support HTML
  static String getTextVersion(String htmlContent) {
    return htmlContent
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
