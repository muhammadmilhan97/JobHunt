import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/auth/role_select_page.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/pin_setup_screen.dart';
import '../../features/auth/screens/pin_verification_screen.dart';
import '../../features/auth/screens/pending_approval_screen.dart';
import '../../features/seeker/home/seeker_home_page.dart';
import '../../features/seeker/home/seeker_shell.dart';
import '../../features/seeker/job_detail/job_detail_page.dart';
import '../../features/notifications/notifications_page.dart';
import '../../features/employer/dashboard/employer_dashboard_page.dart';
import '../../features/employer/post_job/post_job_page.dart';
import '../../features/employer/dashboard/employer_my_jobs_page.dart';
import '../../features/employer/applicants/applicants_list_page.dart';
import '../../features/admin/admin_dashboard_page.dart';
import '../../features/admin/user_management_page.dart';
import '../../features/admin/job_moderation_page.dart';
import '../../features/admin/user_approval_page.dart';
import '../../features/admin/screens/system_logs_page.dart';
import '../../features/admin/screens/admin_settings_page.dart';
import '../../features/seeker/applications/my_applications_page.dart';
import '../../features/seeker/applications/application_detail_page.dart';
import '../../features/seeker/profile/seeker_profile_page.dart';
import '../../features/employer/company/employer_company_page.dart';
import '../../features/seeker/favorites/seeker_favorites_page.dart';
import '../../features/shared/settings/settings_page.dart';
import '../../features/shared/settings/email_preferences_page.dart';
import '../services/firebase_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Splash Route
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: '/auth/pin-setup',
        name: 'pin-setup',
        builder: (context, state) {
          final nextRoute = state.uri.queryParameters['next'];
          return PinSetupScreen(nextRoute: nextRoute);
        },
      ),

      GoRoute(
        path: '/auth/pin-verification',
        name: 'pin-verification',
        builder: (context, state) {
          final nextRoute = state.uri.queryParameters['next'];
          return PinVerificationScreen(nextRoute: nextRoute);
        },
      ),

      GoRoute(
        path: '/auth/pending-approval',
        name: 'pending-approval',
        builder: (context, state) {
          final message = state.uri.queryParameters['message'] ??
              'Your account is pending admin approval.';
          return PendingApprovalScreen(message: message);
        },
      ),

      GoRoute(
        path: '/role',
        name: 'role',
        builder: (context, state) => const RoleSelectPage(),
      ),

      // Job Seeker Shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => SeekerShell(child: child),
        routes: [
          GoRoute(
            path: '/seeker/home',
            name: 'seeker-home',
            builder: (context, state) => const SeekerHomePage(),
          ),
          GoRoute(
            path: '/seeker/favorites',
            name: 'seeker-favorites',
            builder: (context, state) => const SeekerFavoritesPage(),
          ),
          GoRoute(
            path: '/seeker/applications',
            name: 'seeker-applications',
            builder: (context, state) => const MyApplicationsPage(),
          ),
          GoRoute(
            path: '/seeker/profile',
            name: 'seeker-profile',
            builder: (context, state) => const SeekerProfilePage(),
          ),
        ],
      ),

      GoRoute(
        path: '/seeker/job/:id',
        name: 'job-detail',
        builder: (context, state) {
          final jobId = state.pathParameters['id']!;
          return JobDetailPage(jobId: jobId);
        },
      ),

      GoRoute(
        path: '/seeker/application/:id',
        name: 'application-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ApplicationDetailPage(applicationId: id);
        },
      ),

      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),

      // Settings Route
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),

      // Email Preferences Route
      GoRoute(
        path: '/email-preferences',
        name: 'email-preferences',
        builder: (context, state) => const EmailPreferencesPage(),
      ),

      // Employer Routes
      GoRoute(
        path: '/employer/dashboard',
        name: 'employer-dashboard',
        builder: (context, state) => const EmployerDashboardPage(),
      ),

      GoRoute(
        path: '/employer/my-jobs',
        name: 'employer-my-jobs',
        builder: (context, state) => const EmployerMyJobsPage(),
      ),

      GoRoute(
        path: '/employer/company',
        name: 'employer-company',
        builder: (context, state) => const EmployerCompanyPage(),
      ),

      GoRoute(
        path: '/employer/post',
        name: 'post-job',
        builder: (context, state) => const PostJobPage(),
      ),
      GoRoute(
        path: '/employer/post/:id',
        name: 'edit-job',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PostJobPage(jobId: id);
        },
      ),

      GoRoute(
        path: '/employer/job/:jobId/applicants',
        name: 'job-applicants',
        builder: (context, state) {
          final jobId = state.pathParameters['jobId']!;
          final jobTitle = state.uri.queryParameters['title'] ?? 'Job';
          return ApplicantsListPage(
            jobId: jobId,
            jobTitle: jobTitle,
          );
        },
      ),

      // Admin Routes
      GoRoute(
        path: '/admin/panel',
        name: 'admin-panel',
        builder: (context, state) => const AdminDashboardPage(),
      ),

      GoRoute(
        path: '/admin/users',
        name: 'admin-users',
        builder: (context, state) => const UserManagementPage(),
      ),

      GoRoute(
        path: '/admin/jobs',
        name: 'admin-jobs',
        builder: (context, state) => const JobModerationPage(),
      ),
      GoRoute(
        path: '/admin/logs',
        name: 'admin-logs',
        builder: (context, state) => const SystemLogsPage(),
      ),
      GoRoute(
        path: '/admin/settings',
        name: 'admin-settings',
        builder: (context, state) => const AdminSettingsPage(),
      ),

      GoRoute(
        path: '/admin/approvals',
        name: 'admin-approvals',
        builder: (context, state) => const UserApprovalPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page ${state.uri} does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
    redirect: (context, state) {
      // Check for pending deep link captured by FirebasePushService
      // We read it via a static getter to avoid provider cycles
      final link = FirebasePushServicePendingLink.get();
      if (link != null) {
        final kind = link['kind'];
        final id = link['id'];
        FirebasePushServicePendingLink.clear();
        if (kind == 'job') return '/seeker/job/$id';
        if (kind == 'application') return '/seeker/application/$id';
      }
      return null;
    },
  );
});
