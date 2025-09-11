import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'firebase_options.dart';
// import 'app/theme.dart';
// import 'core/services/firebase_service.dart';
import 'core/services/firebase_push_service.dart';
import 'core/services/error_reporter.dart';
import 'core/services/analytics_service.dart';
import 'core/services/email_service.dart';
import 'core/providers/router_provider.dart';
import 'core/providers/localization_providers.dart';
import 'core/widgets/app_lifecycle_handler.dart';
import 'core/widgets/in_app_notification_banner.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env) - non-fatal if missing
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize services
  await FirebasePushService.initialize();
  await AnalyticsService.initialize();
  ErrorReporter.initialize();

  // Initialize email service with SendGrid API key
  final sendGridApiKey =
      const String.fromEnvironment('SENDGRID_API_KEY', defaultValue: '')
              .isNotEmpty
          ? const String.fromEnvironment('SENDGRID_API_KEY')
          : (dotenv.isInitialized
              ? (dotenv.maybeGet('SENDGRID_API_KEY') ?? '')
              : '');
  if (sendGridApiKey.isNotEmpty) {
    EmailService.initialize(sendGridApiKey);
  }

  // Set up background message handler for FCM
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Set preferred orientations for better performance
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const ProviderScope(child: JobHuntApp()));
}

class JobHuntApp extends ConsumerWidget {
  const JobHuntApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // final currentLocale = ref.watch(currentLocaleProvider);
    final accessibilityService = ref.watch(accessibilityServiceProvider);

    return MaterialApp.router(
      title: 'JobHunt',
      debugShowCheckedModeBanner: false,

      // Theme with accessibility settings
      theme: accessibilityService.applyAccessibilitySettings(
        ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
      ),

      // Localization configuration (temporarily commented out)
      // localizationsDelegates: [
      //   AppLocalizations.delegate,
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('en', 'US'),
      //   Locale('ur', 'PK'),
      // ],
      // locale: currentLocale,

      routerConfig: router,
      builder: (context, child) => AppLifecycleHandler(
        child: InAppNotificationBanner(child: child!),
      ),
    );
  }
}
