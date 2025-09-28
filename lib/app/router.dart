import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/auth/role_select_page.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/seeker/home/seeker_home_page.dart';
import '../features/seeker/job_detail/job_detail_page.dart';
import '../features/employer/dashboard/employer_dashboard_page.dart';
import '../features/employer/dashboard/employer_my_jobs_page.dart';
import '../features/employer/post_job/post_job_page.dart';
import '../features/employer/company/employer_company_page.dart';
import '../features/employer/applicants/employer_applicants_page.dart';
import '../features/admin/screens/admin_panel_screen.dart';
import '../features/admin/screens/system_logs_page.dart';
import '../features/admin/screens/admin_settings_page.dart';

final GoRouter appRouter = GoRouter(
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
      path: '/role',
      name: 'role',
      builder: (context, state) => const RoleSelectPage(),
    ),

    // Job Seeker Routes
    GoRoute(
      path: '/seeker/home',
      name: 'seeker-home',
      builder: (context, state) => const SeekerHomePage(),
    ),

    GoRoute(
      path: '/seeker/job/:id',
      name: 'job-detail',
      builder: (context, state) {
        final jobId = state.pathParameters['id']!;
        return JobDetailPage(jobId: jobId);
      },
    ),

    // Employer Routes
    GoRoute(
      path: '/employer/dashboard',
      name: 'employer-dashboard',
      builder: (context, state) => const EmployerDashboardPage(),
    ),

    GoRoute(
      path: '/employer/post',
      name: 'post-job',
      builder: (context, state) => const PostJobPage(),
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
      path: '/employer/job/:jobId/applicants',
      name: 'employer-applicants',
      builder: (context, state) {
        final jobId = state.pathParameters['jobId']!;
        return EmployerApplicantsPage(jobId: jobId);
      },
    ),

    // Admin Routes
    GoRoute(
      path: '/admin/panel',
      name: 'admin-panel',
      builder: (context, state) => const AdminPanelScreen(),
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
  ],

  // Error handling
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Page not found: ${state.uri}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Go to Home'),
          ),
        ],
      ),
    ),
  ),
);
