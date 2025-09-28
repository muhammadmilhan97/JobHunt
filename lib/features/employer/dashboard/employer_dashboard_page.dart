import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/user_providers.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_logo.dart';
import '../analytics/employer_analytics_page.dart';
import '../applicants/employer_all_applicants_page.dart';
import '../interviews/employer_interviews_page.dart';
import '../hires/employer_hires_page.dart';

class EmployerDashboardPage extends ConsumerWidget {
  const EmployerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    print('Dashboard - Current user ID: $uid');
    final jobsAsync = uid != null
        ? ref.watch(jobsByEmployerProvider(uid))
        : const AsyncValue<List<Job>>.data(const []);
    final userProfileAsync = uid != null
        ? ref.watch(userStreamProvider(uid))
        : const AsyncValue.data(null);

    return Scaffold(
      appBar: BrandedAppBar(
        title: 'Employer Dashboard',
        actions: [
          IconButton(
            onPressed: () {
              context.push('/employer/post');
            },
            icon: const Icon(Icons.add),
            tooltip: 'Post New Job',
          ),
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                context.go('/auth');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
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
              // Branded hero
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Center(child: AppLogo.large()),
              ),

              const SizedBox(height: 16),

              // Welcome Section
              _buildWelcomeSection(
                context,
                userProfileAsync.maybeWhen(
                      data: (u) =>
                          u?.companyName ??
                          u?.name ??
                          currentUser?.displayName ??
                          'Employer',
                      orElse: () => currentUser?.displayName ?? 'Employer',
                    ) ??
                    'Employer',
              ),

              const SizedBox(height: 24),

              // Metrics Section
              jobsAsync.when(
                data: (jobs) => _buildMetricsSection(context, jobs),
                loading: () => _buildMetricsShimmer(),
                error: (_, __) => const SizedBox(),
              ),

              const SizedBox(height: 32),

              // My Jobs Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Jobs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push('/employer/my-jobs'),
                    icon: const Icon(Icons.view_list),
                    label: const Text('View All'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              jobsAsync.when(
                data: (jobs) {
                  print('Dashboard - Jobs loaded: ${jobs.length} jobs');
                  for (var job in jobs) {
                    print('Job: ${job.title} - EmployerId: ${job.employerId}');
                  }
                  return _buildJobsList(context, jobs);
                },
                loading: () => _buildJobsShimmer(),
                error: (error, stack) {
                  print('Dashboard - Error loading jobs: $error');
                  return _buildErrorState(context, error.toString());
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/employer/post'),
        icon: const Icon(Icons.add),
        label: const Text('Post Job'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
            'Welcome back, $companyName!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to find your next great hire?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/employer/post'),
                  icon: const Icon(Icons.add),
                  label: const Text('Post New Job'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmployerAnalyticsPage(),
                    ),
                  ),
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('View Analytics'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(BuildContext context, List<Job> jobs) {
    // Calculate metrics from this employer's jobs
    final activeJobs = jobs.where((job) => job.isActive).length;
    final totalApplicants = jobs.fold<int>(
        0, (sum, job) => sum + (job.id.hashCode % 50)); // Mock data
    final interviewsScheduled = jobs.fold<int>(
        0, (sum, job) => sum + (job.id.hashCode % 10)); // Mock data
    final hires = jobs.fold<int>(
        0, (sum, job) => sum + (job.id.hashCode % 5)); // Mock data
    final expiringJobs = jobs.where((job) {
      final daysSincePosted = DateTime.now().difference(job.createdAt).inDays;
      return daysSincePosted >= 25 &&
          daysSincePosted <= 30; // Jobs expiring soon
    }).length;

    return Column(
      children: [
        // Top row - Main KPIs
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Active Jobs',
                value: activeJobs.toString(),
                icon: Icons.work_outline,
                color: Colors.blue,
                onTap: () => context.push('/employer/my-jobs'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Total Applicants',
                value: totalApplicants.toString(),
                icon: Icons.people_outline,
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmployerAllApplicantsPage(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Second row - Additional KPIs
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Interviews',
                value: interviewsScheduled.toString(),
                icon: Icons.calendar_today_outlined,
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmployerInterviewsPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Hires',
                value: hires.toString(),
                icon: Icons.check_circle_outline,
                color: Colors.purple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmployerHiresPage(),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (expiringJobs > 0) ...[
          const SizedBox(height: 12),
          // Expiring jobs alert
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_outlined, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$expiringJobs job${expiringJobs > 1 ? 's' : ''} expiring soon',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/employer/my-jobs'),
                  child: const Text('View'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetricsShimmer() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJobsList(BuildContext context, List<Job> jobs) {
    if (jobs.isEmpty) {
      return _buildEmptyState(context);
    }

    // Take first 5 jobs for dashboard view
    final displayJobs = jobs.take(5).toList();

    return Column(
      children: displayJobs.map((job) => _EmployerJobCard(job: job)).toList(),
    );
  }

  Widget _buildJobsShimmer() {
    return Column(
      children: List.generate(
        3,
        (index) => Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 24,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No jobs posted yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Post your first job to start finding great candidates',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/employer/post'),
              icon: const Icon(Icons.add),
              label: const Text('Post Your First Job'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
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
              'Failed to load jobs',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
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

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                    child: Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          value,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmployerJobCard extends StatelessWidget {
  final Job job;

  const _EmployerJobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final applicantCount = job.id.hashCode % 50; // Mock data
    final viewsCount = job.id.hashCode % 200; // Mock data
    final status = DateTime.now().difference(job.createdAt).inDays < 30
        ? 'Active'
        : 'Inactive';

    // Format salary in PKR
    final salaryText = _formatSalary(job.salaryMin, job.salaryMax);

    // Calculate days until expiry
    final daysUntilExpiry =
        30 - DateTime.now().difference(job.createdAt).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${job.locationCity}, ${job.locationCountry}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      if (salaryText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          salaryText,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'Active'
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              status == 'Active' ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Metrics row - made responsive to prevent overflow
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildMetricChip(
                  context,
                  Icons.people_outline,
                  '$applicantCount applicants',
                ),
                _buildMetricChip(
                  context,
                  Icons.visibility_outlined,
                  '$viewsCount views',
                ),
                _buildMetricChip(
                  context,
                  Icons.calendar_today_outlined,
                  daysUntilExpiry > 0
                      ? '$daysUntilExpiry days left'
                      : '${DateTime.now().difference(job.createdAt).inDays} days ago',
                  daysUntilExpiry <= 5 ? Colors.orange : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push(
                        '/employer/job/${job.id}/applicants?title=${Uri.encodeComponent(job.title)}',
                      );
                    },
                    icon: const Icon(Icons.people, size: 18),
                    label: const Text('View Applicants'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit job feature coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Job'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(BuildContext context, IconData icon, String text,
      [Color? textColor]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor ??
                      Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  /// Format salary in PKR currency
  String _formatSalary(int? minSalary, int? maxSalary) {
    if (minSalary == null && maxSalary == null) return '';

    final formatter = NumberFormat.currency(
      locale: 'en_PK',
      symbol: 'PKR ',
      decimalDigits: 0,
    );

    if (minSalary != null && maxSalary != null) {
      return '${formatter.format(minSalary)} - ${formatter.format(maxSalary)}';
    } else if (minSalary != null) {
      return '${formatter.format(minSalary)}+';
    } else if (maxSalary != null) {
      return 'Up to ${formatter.format(maxSalary)}';
    }

    return '';
  }
}
