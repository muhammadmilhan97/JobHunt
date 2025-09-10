# JobHunt v2 - Flutter Job Search Application

A comprehensive Flutter application for job seekers and employers with advanced features including email notifications, job alerts, and real-time updates.

## 🚀 Features

### For Job Seekers
- **Job Search & Discovery**: Advanced search with filters and categories
- **Job Alerts**: Email notifications for matching job opportunities
- **Application Tracking**: Track application status and history
- **Favorites**: Save interesting jobs for later
- **Profile Management**: Comprehensive user profiles with skills and experience

### For Employers
- **Job Posting**: Create and manage job listings
- **Applicant Management**: Review and manage job applications
- **Company Dashboard**: Analytics and insights
- **Email Notifications**: Get notified of new applications

### System Features
- **Email Notifications**: Powered by SendGrid
- **Push Notifications**: Firebase Cloud Messaging
- **Real-time Updates**: Live data synchronization
- **Multi-language Support**: English and Urdu localization
- **Accessibility**: Full accessibility support
- **Offline Support**: Works without internet connection

## 🛠️ Tech Stack

- **Frontend**: Flutter/Dart
- **Backend**: Firebase (Firestore, Auth, Functions)
- **Email Service**: SendGrid
- **Push Notifications**: Firebase Cloud Messaging
- **Image Storage**: Cloudinary
- **State Management**: Riverpod
- **Localization**: Flutter Intl

## 📋 Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio / VS Code
- Firebase project
- SendGrid account
- Cloudinary account (optional)

## 🔧 Setup Instructions

### 1. Clone the Repository
```bash
git clone <repository-url>
cd jobhunt-v2
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Environment Configuration
```bash
# Copy the environment template
cp .env.example .env

# Edit .env file with your actual values
# NEVER commit .env files to version control
```

### 4. Firebase Setup
1. Create a Firebase project
2. Enable Firestore, Authentication, and Cloud Messaging
3. Download `google-services.json` and place it in `android/app/`
4. Update Firebase configuration in `lib/firebase_options.dart`

### 5. SendGrid Configuration
1. Create a SendGrid account
2. Generate an API key
3. Add the API key to your `.env` file:
   ```
   SENDGRID_API_KEY=your_actual_api_key_here
   ```

### 6. Run the Application
```bash
# For development with environment variables
flutter run --dart-define=SENDGRID_API_KEY=your_api_key_here

# Or use .env file (if configured)
flutter run
```

## 📱 Build Instructions

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🔐 Security Notes

- **Never commit API keys or secrets** to version control
- Use environment variables for sensitive configuration
- The `.env` file is automatically excluded from Git
- API keys are loaded at runtime, not hardcoded

## 📧 Email Features

The application includes comprehensive email functionality:

- **Welcome Emails**: Sent to new users upon registration
- **OTP Verification**: Email-based account verification
- **Job Alerts**: Automated notifications for matching jobs
- **Application Notifications**: Updates on application status
- **Weekly Digest**: Summary of new job opportunities

## 🌐 Localization

The app supports multiple languages:
- English (default)
- Urdu

To add new languages, update the `lib/l10n/` directory.

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 📚 Documentation

- [Firebase Setup Guide](docs/firebase_setup.md)
- [Email Configuration Guide](SENDGRID_SETUP.md)
- [API Documentation](docs/api.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Email: jobhuntapplication@gmail.com
- Create an issue in the repository

## 🔄 Version History

- **v2.0.0**: Complete rewrite with email notifications and advanced features
- **v1.0.0**: Initial release with basic job search functionality

---

**⚠️ Important**: Always use environment variables for sensitive configuration. Never commit API keys or secrets to version control.