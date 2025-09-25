class EmailConfig {
  // SendGrid Configuration
  static const String sendGridApiKey = String.fromEnvironment(
    'SENDGRID_API_KEY',
    defaultValue: '', // Never hardcode API keys in source code
  );

  // Email Settings
  static const String defaultFromEmail = 'jobhuntapplication@gmail.com';
  static const String defaultFromName = 'JobHunt Team';
  static const String supportEmail = 'jobhuntapplication@gmail.com';

  // App Domain (update with your actual domain)
  static const String appDomain = 'https://jobhunt-app.com';
  static const String logoUrl = '$appDomain/assets/logo.png';

  // OTP Settings
  static const int otpExpiryMinutes = 10;
  static const int maxOtpAttempts = 5;
  static const int otpResendDelayMinutes = 1;

  // Job Alert Settings
  static const int jobAlertBatchSize = 100;
  static const int jobAlertBatchDelaySeconds = 1;
  static const int weeklyDigestJobLimit = 10;

  // Social Links (update with your actual social media links)
  static const String linkedinUrl = 'https://linkedin.com/company/jobhunt-app';
  static const String twitterUrl = 'https://twitter.com/jobhunt_app';
  static const String facebookUrl = 'https://facebook.com/jobhunt.app';

  // Feature Flags
  static const bool enableOtpVerification = true;
  static const bool enableWelcomeEmails = true;
  static const bool enableJobAlerts = true;
  static const bool enableEmployerNotifications = true;
  static const bool enableWeeklyDigest = true;

  /// Check if email service is properly configured
  /// We now use Firebase Cloud Functions (Gmail SMTP) instead of SendGrid,
  /// so consider email configured by default.
  static bool get isConfigured => true;

  /// Get the job URL for a specific job ID
  static String getJobUrl(String jobId) => '$appDomain/jobs/$jobId';

  /// Get the application URL for a specific application ID
  static String getApplicationUrl(String applicationId) =>
      '$appDomain/applications/$applicationId';

  /// Get the unsubscribe URL for a specific user
  static String getUnsubscribeUrl(String userId) =>
      '$appDomain/unsubscribe?user=$userId';
}
