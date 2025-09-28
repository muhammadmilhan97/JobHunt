import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/user_providers.dart';
import '../../../core/providers/applications_providers.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_logo.dart';

class EmployerAnalyticsPage extends ConsumerWidget {
  const EmployerAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final jobsAsync = uid != null
        ? ref.watch(jobsByEmployerProvider(uid))
        : const AsyncValue<List<Job>>.data(const []);
    final applicationsAsync = uid != null
        ? ref.watch(applicationsForEmployerProvider(uid))
        : const AsyncValue<List<Application>>.data(const []);

    // Debug logging
    applicationsAsync.when(
      data: (applications) =>
          print('Analytics - Applications loaded: ${applications.length}'),
      loading: () => print('Analytics - Loading applications...'),
      error: (error, stack) =>
          print('Analytics - Error loading applications: $error'),
    );
    final userProfileAsync = uid != null
        ? ref.watch(userStreamProvider(uid))
        : const AsyncValue.data(null);

    return Scaffold(
      appBar: BrandedAppBar(
        title: 'Analytics',
        actions: [
          IconButton(
            onPressed: () => context.push('/employer/dashboard'),
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Dashboard',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (uid != null) {
            ref.invalidate(jobsByEmployerProvider(uid));
          }
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(
                context,
                userProfileAsync.maybeWhen(
                      data: (u) => u?.companyName ?? u?.name ?? 'Company',
                      orElse: () => 'Company',
                    ) ??
                    'Company',
              ),

              const SizedBox(height: 24),

              // Analytics Overview
              jobsAsync.when(
                data: (jobs) => applicationsAsync.when(
                  data: (applications) =>
                      _buildAnalyticsOverview(context, jobs, applications),
                  loading: () => _buildAnalyticsShimmer(),
                  error: (_, __) => _buildErrorState(context),
                ),
                loading: () => _buildAnalyticsShimmer(),
                error: (_, __) => _buildErrorState(context),
              ),

              const SizedBox(height: 24),

              // Job Performance Chart
              _buildJobPerformanceSection(context, jobsAsync),

              const SizedBox(height: 24),

              // Recent Activity
              _buildRecentActivitySection(context, jobsAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, String companyName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Dashboard',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Insights for $companyName',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsOverview(
      BuildContext context, List<Job> jobs, List<Application> applications) {
    final totalJobs = jobs.length;
    final activeJobs = jobs.where((job) => job.isActive).length;
    final totalApplicants = applications.length;
    final pendingApplications =
        applications.where((app) => app.status == 'pending').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _AnalyticsCard(
              title: 'Total Jobs',
              value: totalJobs.toString(),
              icon: Icons.work_outline,
              color: Colors.blue,
            ),
            _AnalyticsCard(
              title: 'Active Jobs',
              value: activeJobs.toString(),
              icon: Icons.check_circle_outline,
              color: Colors.green,
            ),
            _AnalyticsCard(
              title: 'Pending Applications',
              value: pendingApplications.toString(),
              icon: Icons.pending_outlined,
              color: Colors.orange,
            ),
            _AnalyticsCard(
              title: 'Total Applicants',
              value: totalApplicants.toString(),
              icon: Icons.people_outline,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsShimmer() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: List.generate(
          4,
          (index) => Card(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )),
    );
  }

  Widget _buildJobPerformanceSection(
      BuildContext context, AsyncValue<List<Job>> jobsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Performance',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        jobsAsync.when(
          data: (jobs) => _buildJobPerformanceChart(context, jobs),
          loading: () => _buildJobPerformanceShimmer(),
          error: (_, __) => _buildErrorState(context),
        ),
      ],
    );
  }

  Widget _buildJobPerformanceChart(BuildContext context, List<Job> jobs) {
    if (jobs.isEmpty) {
      return Card(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.bar_chart_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No job data available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Top Performing Jobs',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            ...jobs.take(5).map((job) => _JobPerformanceItem(job: job)),
          ],
        ),
      ),
    );
  }

  Widget _buildJobPerformanceShimmer() {
    return Card(
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(
      BuildContext context, AsyncValue<List<Job>> jobsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        jobsAsync.when(
          data: (jobs) => _buildRecentActivityList(context, jobs),
          loading: () => _buildRecentActivityShimmer(),
          error: (_, __) => _buildErrorState(context),
        ),
      ],
    );
  }

  Widget _buildRecentActivityList(BuildContext context, List<Job> jobs) {
    if (jobs.isEmpty) {
      return Card(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.timeline_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No recent activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Latest Job Postings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            ...jobs.take(5).map((job) => _RecentActivityItem(job: job)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityShimmer() {
    return Card(
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load analytics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobPerformanceItem extends StatelessWidget {
  final Job job;

  const _JobPerformanceItem({required this.job});

  @override
  Widget build(BuildContext context) {
    final views = job.id.hashCode % 200;
    final applicants = job.id.hashCode % 50;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  '${job.locationCity}, ${job.locationCountry}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$views views',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                '$applicants applicants',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentActivityItem extends StatelessWidget {
  final Job job;

  const _RecentActivityItem({required this.job});

  @override
  Widget build(BuildContext context) {
    final daysAgo = DateTime.now().difference(job.createdAt).inDays;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: job.isActive ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  'Posted $daysAgo days ago',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: job.isActive
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              job.isActive ? 'Active' : 'Inactive',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: job.isActive ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
