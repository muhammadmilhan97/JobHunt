# SendGrid Email Notifications Setup Guide

## 🚀 Overview

Your JobHunt app now includes a comprehensive email notification system using SendGrid. This system handles:

- **OTP Email Verification** for user sign-in security
- **Welcome Emails** for new user registration
- **Job Alerts** for job seekers when new jobs match their preferences
- **Job Posting Confirmations** for employers
- **Weekly Job Digests** for subscribed users
- **Email Preference Management** for users

## 📋 Prerequisites

1. **SendGrid Account**: You need a SendGrid account with an API key
2. **Verified Sender**: Set up a verified sender identity in SendGrid
3. **Domain Authentication** (recommended): Configure domain authentication for better deliverability

## 🔧 Setup Instructions

### Step 1: Get Your SendGrid API Key

1. Log in to your [SendGrid Dashboard](https://app.sendgrid.com/)
2. Navigate to **Settings** → **API Keys**
3. Click **Create API Key**
4. Choose **Restricted Access** and grant these permissions:
   - **Mail Send**: Full Access
   - **Template Engine**: Full Access (if using templates)
   - **Suppressions**: Read Access (optional)
5. Copy your API key (it starts with `SG.`)

### Step 2: Configure Environment Variables

#### For Development (Local Testing)
Create a `.env` file in your project root:

```env
SENDGRID_API_KEY=SG.your_api_key_here
```

#### For Flutter App (Production)
Set the environment variable when building:

```bash
# Android
flutter build apk --dart-define=SENDGRID_API_KEY=SG.your_api_key_here

# iOS
flutter build ios --dart-define=SENDGRID_API_KEY=SG.your_api_key_here
```

### Step 3: Update Email Configuration

Edit `lib/core/config/email_config.dart`:

```dart
class EmailConfig {
  // Update these with your actual values
  static const String defaultFromEmail = 'noreply@yourdomain.com';
  static const String defaultFromName = 'JobHunt Team';
  static const String supportEmail = 'support@yourdomain.com';
  static const String appDomain = 'https://yourdomain.com';
  static const String logoUrl = 'https://yourdomain.com/assets/logo.png';
  
  // Social media links
  static const String linkedinUrl = 'https://linkedin.com/company/yourcompany';
  static const String twitterUrl = 'https://twitter.com/yourhandle';
  static const String facebookUrl = 'https://facebook.com/yourpage';
}
```

### Step 4: Set Up Sender Authentication

In SendGrid Dashboard:

1. Go to **Settings** → **Sender Authentication**
2. **Single Sender Verification**: Add your `noreply@yourdomain.com` email
3. **Domain Authentication** (recommended): Verify your domain for better deliverability

### Step 5: Test Email Functionality

Run your app and test:

1. **Registration**: Create a new account → should receive welcome email
2. **Job Posting**: Post a job as employer → should receive confirmation email
3. **Job Alerts**: Create job seeker with preferences → should receive alerts for matching jobs
4. **OTP Verification**: Enable OTP verification in your auth flow

## 📧 Email Types & Templates

### 1. Welcome Email
- **Trigger**: New user registration
- **Recipients**: All new users
- **Content**: Role-specific welcome message with next steps

### 2. OTP Verification Email
- **Trigger**: User sign-in (if OTP is enabled)
- **Recipients**: Users requiring email verification
- **Content**: 6-digit OTP code with 10-minute expiry

### 3. Job Posting Confirmation
- **Trigger**: Employer posts a new job
- **Recipients**: Employers with notifications enabled
- **Content**: Job details and what happens next

### 4. Job Alerts
- **Trigger**: New job matches user preferences
- **Recipients**: Job seekers with instant alerts enabled
- **Content**: Job details with apply button

### 5. Weekly Job Digest
- **Trigger**: Scheduled weekly (you need to set this up)
- **Recipients**: Users with weekly digest enabled
- **Content**: Summary of recent jobs (up to 10)

## ⚙️ Email Preferences

Users can manage their email preferences in:
- **Settings** → **Email Preferences**

Available options:
- **Email Notifications**: Master toggle for all emails
- **Job Alerts**: Instant notifications for matching jobs
- **Weekly Digest**: Weekly summary of new jobs
- **Job Posting Confirmations**: For employers

## 🔒 Security Features

### OTP Verification
- 6-digit random codes
- 10-minute expiry
- Maximum 5 attempts
- Rate limiting (1-minute between resends)
- Automatic cleanup of expired OTPs

### Email Validation
- All emails are validated before sending
- Failed sends are logged but don't block app functionality
- Retry logic for temporary failures

## 📊 Monitoring & Analytics

### Email Delivery Tracking
- All email sends are logged
- Failed sends are reported to ErrorReporter
- Analytics events are tracked for email interactions

### SendGrid Analytics
Monitor in SendGrid Dashboard:
- **Activity Feed**: See all email activity
- **Statistics**: Delivery rates, opens, clicks
- **Suppressions**: Bounces, blocks, spam reports

## 🚨 Troubleshooting

### Common Issues

#### 1. Emails Not Sending
- Check API key is set correctly
- Verify sender email is authenticated in SendGrid
- Check app logs for error messages

#### 2. Emails Going to Spam
- Set up domain authentication
- Ensure sender reputation is good
- Use consistent "From" addresses

#### 3. High Bounce Rate
- Validate email addresses before sending
- Clean your recipient lists regularly
- Monitor SendGrid suppressions

#### 4. Rate Limiting
- SendGrid has sending limits based on your plan
- Implement proper batching for bulk sends
- Monitor your sending volume

### Debug Mode
In development, email sending is logged to console:
```dart
if (kDebugMode) {
  print('Email sent successfully to $recipient');
}
```

## 📈 Scaling Considerations

### High Volume Sending
- Use SendGrid's batch sending for job alerts
- Implement proper queue management
- Consider using SendGrid's Marketing Campaigns for newsletters

### Template Management
- Create reusable templates in SendGrid
- Use dynamic content for personalization
- A/B test your email templates

### Performance
- Email sending is asynchronous and doesn't block app functionality
- Failed emails are retried with exponential backoff
- Bulk operations are batched to avoid rate limits

## 📝 Next Steps

1. **Set up your SendGrid account** with API key
2. **Update the configuration** with your domain and branding
3. **Test all email flows** in development
4. **Set up monitoring** for email delivery
5. **Configure scheduled jobs** for weekly digests (using Firebase Functions or similar)

## 🆘 Support

If you encounter issues:
1. Check SendGrid's [API documentation](https://docs.sendgrid.com/)
2. Review error logs in your app
3. Monitor SendGrid's activity feed
4. Contact SendGrid support for delivery issues

---

**Note**: Remember to comply with email regulations (CAN-SPAM, GDPR) and always provide unsubscribe options in your emails.
