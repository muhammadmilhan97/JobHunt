import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'JobHunt'**
  String get appTitle;

  /// Home page title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Favorites page title
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Applications page title
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get applications;

  /// Profile page title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Dashboard page title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Post job page title
  ///
  /// In en, this message translates to:
  /// **'Post Job'**
  String get postJob;

  /// My jobs page title
  ///
  /// In en, this message translates to:
  /// **'My Jobs'**
  String get myJobs;

  /// Applicants page title
  ///
  /// In en, this message translates to:
  /// **'Applicants'**
  String get applicants;

  /// Semantic label for notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// User role - admin
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get admin;

  /// Apply button text
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Filters button text
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Clear all filters button text
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Search button text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Sign out button text
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Upload CV button text
  ///
  /// In en, this message translates to:
  /// **'Upload CV'**
  String get uploadCV;

  /// Replace CV button text
  ///
  /// In en, this message translates to:
  /// **'Replace CV'**
  String get replaceCV;

  /// Upload logo button text
  ///
  /// In en, this message translates to:
  /// **'Upload Logo'**
  String get uploadLogo;

  /// View CV button text
  ///
  /// In en, this message translates to:
  /// **'View CV'**
  String get viewCV;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Update button text
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Message shown when no results are found
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// Message suggesting to adjust filters
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters'**
  String get tryAdjustingFilters;

  /// Message when no jobs are available
  ///
  /// In en, this message translates to:
  /// **'No jobs available at the moment'**
  String get noJobsAvailable;

  /// Message when no applications exist
  ///
  /// In en, this message translates to:
  /// **'No applications yet'**
  String get noApplications;

  /// Message when no favorite jobs exist
  ///
  /// In en, this message translates to:
  /// **'No favorite jobs yet'**
  String get noFavorites;

  /// Message when no notifications exist
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// Message asking user to try again
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get tryAgain;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Message when job is posted successfully
  ///
  /// In en, this message translates to:
  /// **'Job posted successfully'**
  String get jobPostedSuccessfully;

  /// Message when application is submitted
  ///
  /// In en, this message translates to:
  /// **'Application submitted successfully'**
  String get applicationSubmitted;

  /// Message when profile is updated
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// Message when job is saved
  ///
  /// In en, this message translates to:
  /// **'Job saved to favorites'**
  String get jobSaved;

  /// Message when job is removed from favorites
  ///
  /// In en, this message translates to:
  /// **'Job removed from favorites'**
  String get jobRemoved;

  /// Undo action text
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Application status - pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Application status - reviewing
  ///
  /// In en, this message translates to:
  /// **'Reviewing'**
  String get reviewing;

  /// Application status - shortlisted
  ///
  /// In en, this message translates to:
  /// **'Shortlisted'**
  String get shortlisted;

  /// Application status - interview
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get interview;

  /// Application status - hired
  ///
  /// In en, this message translates to:
  /// **'Hired'**
  String get hired;

  /// Application status - rejected
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// Application status - withdrawn
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get withdrawn;

  /// Job type - full time
  ///
  /// In en, this message translates to:
  /// **'Full-time'**
  String get fullTime;

  /// Job type - part time
  ///
  /// In en, this message translates to:
  /// **'Part-time'**
  String get partTime;

  /// Job type - contract
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get contract;

  /// Job type - internship
  ///
  /// In en, this message translates to:
  /// **'Internship'**
  String get internship;

  /// Job type - freelance
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get freelance;

  /// User role - job seeker
  ///
  /// In en, this message translates to:
  /// **'Job Seeker'**
  String get jobSeeker;

  /// User role - employer
  ///
  /// In en, this message translates to:
  /// **'Employer'**
  String get employer;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Urdu language option
  ///
  /// In en, this message translates to:
  /// **'اردو'**
  String get urdu;

  /// System default language option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// Accessibility settings section
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// High contrast mode setting
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get highContrast;

  /// Large text mode setting
  ///
  /// In en, this message translates to:
  /// **'Large Text'**
  String get largeText;

  /// Reduce motion setting
  ///
  /// In en, this message translates to:
  /// **'Reduce Motion'**
  String get reduceMotion;

  /// Semantic label for save job icon
  ///
  /// In en, this message translates to:
  /// **'Save Job'**
  String get saveJob;

  /// Semantic label for back navigation
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backNavigation;

  /// Semantic label for open CV action
  ///
  /// In en, this message translates to:
  /// **'Open CV'**
  String get openCV;

  /// Semantic label for filter jobs action
  ///
  /// In en, this message translates to:
  /// **'Filter Jobs'**
  String get filterJobs;

  /// Semantic label for search jobs action
  ///
  /// In en, this message translates to:
  /// **'Search Jobs'**
  String get searchJobs;

  /// Semantic label for apply for job action
  ///
  /// In en, this message translates to:
  /// **'Apply for Job'**
  String get applyForJob;

  /// Semantic label for view job details action
  ///
  /// In en, this message translates to:
  /// **'View Job Details'**
  String get viewJobDetails;

  /// Semantic label for view application action
  ///
  /// In en, this message translates to:
  /// **'View Application'**
  String get viewApplication;

  /// Semantic label for update status action
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get updateStatus;

  /// Semantic label for delete job action
  ///
  /// In en, this message translates to:
  /// **'Delete Job'**
  String get deleteJob;

  /// Semantic label for edit job action
  ///
  /// In en, this message translates to:
  /// **'Edit Job'**
  String get editJob;

  /// Semantic label for upload file action
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get uploadFile;

  /// Semantic label for language selection
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Semantic label for theme toggle
  ///
  /// In en, this message translates to:
  /// **'Toggle Theme'**
  String get toggleTheme;

  /// Semantic label for menu button
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// Semantic label for close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Semantic label for unread notifications
  ///
  /// In en, this message translates to:
  /// **'Unread Notifications'**
  String get unreadNotifications;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ur': return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
