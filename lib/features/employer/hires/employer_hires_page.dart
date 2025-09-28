import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/applications_providers.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_logo.dart';

class EmployerHiresPage extends ConsumerWidget {
  const EmployerHiresPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final applicationsAsync = uid != null
        ? ref.watch(applicationsForEmployerProvider(uid))
        : const AsyncValue<List<Application>>.data([]);

    return Scaffold(
      appBar: BrandedAppBar(
        title: 'Hires',
        actions: [
          IconButton(
            onPressed: () => context.push('/employer/dashboard'),
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Dashboard',
          ),
        ],
      ),
      body: applicationsAsync.when(
        data: (applications) => _buildHiresContent(context, applications, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildHiresContent(
      BuildContext context, List<Application> applications, WidgetRef ref) {
    // Filter applications by status
    final acceptedApplications =
        applications.where((app) => app.status == 'accepted').toList();
    final recentHires = acceptedApplications.take(5).toList(); // Last 5 hires

    // Calculate analytics
    final totalHires = acceptedApplications.length;
    final thisMonthHires = acceptedApplications.where((app) {
      final now = DateTime.now();
      final appDate = app.updatedAt ?? app.createdAt;
      return appDate.year == now.year && appDate.month == now.month;
    }).length;

    return RefreshIndicator(
      onRefresh: () async {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          ref.invalidate(applicationsForEmployerProvider(uid));
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analytics Section
            _buildAnalyticsSection(applications, totalHires, thisMonthHires),

            const SizedBox(height: 24),

            // Recent Hires
            if (recentHires.isNotEmpty) ...[
              _buildSectionTitle(context, 'Recent Hires'),
              const SizedBox(height: 12),
              ...recentHires.map((app) => _HireCard(
                    application: app,
                    onViewProfile: () => _viewProfile(context, app),
                    onContact: () => _contactHire(context, app),
                  )),
              const SizedBox(height: 24),
            ],

            // Hire Statistics
            _buildHireStatistics(context, applications),

            // Empty State
            if (acceptedApplications.isEmpty) _buildEmptyState(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(
      List<Application> applications, int totalHires, int thisMonthHires) {
    return Row(
      children: [
        Expanded(
          child: _AnalyticsCard(
            title: 'Total Hires',
            value: totalHires.toString(),
            icon: Icons.people_outline,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AnalyticsCard(
            title: 'Recent Hires',
            value: thisMonthHires.toString(),
            icon: Icons.trending_up,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildHireStatistics(
      BuildContext context, List<Application> applications) {
    final acceptedApplications =
        applications.where((app) => app.status == 'accepted').toList();
    final totalApplications = applications.length;

    // Calculate statistics
    final hireRate = totalApplications > 0
        ? (acceptedApplications.length / totalApplications * 100)
        : 0.0;
    final avgTimeToHire =
        19; // Mock data - in real app, calculate from interview to hire dates
    final successRate =
        89; // Mock data - percentage of hires that stay long-term

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hire Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatisticItem(
                    icon: Icons.trending_up,
                    label: 'Hire Rate',
                    value: '${hireRate.toStringAsFixed(1)}%',
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _StatisticItem(
                    icon: Icons.access_time,
                    label: 'Avg. Time to Hire',
                    value: '$avgTimeToHire days',
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _StatisticItem(
                    icon: Icons.star,
                    label: 'Success Rate',
                    value: '$successRate%',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Hires Yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hired candidates will appear here after you accept applications.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading hires',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _viewProfile(BuildContext context, Application application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Candidate Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job: ${application.jobTitle}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Candidate ID: ${application.jobSeekerId}'),
            const SizedBox(height: 8),
            Text(
                'Expected Salary: PKR ${application.expectedSalary ?? 'Not specified'}'),
            const SizedBox(height: 8),
            Text(
                'Hired: ${_formatDate(application.updatedAt ?? application.createdAt)}'),
            const SizedBox(height: 12),
            if (application.coverLetter != null) ...[
              const Text('Cover Letter:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(application.coverLetter!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Open CV
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening CV...')),
              );
            },
            child: const Text('View CV'),
          ),
        ],
      ),
    );
  }

  void _contactHire(BuildContext context, Application application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Send Email'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Email integration coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Phone integration coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Messaging feature coming soon')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
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
                    color: color.withOpacity(0.1),
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

class _StatisticItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatisticItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _HireCard extends StatelessWidget {
  final Application application;
  final VoidCallback onViewProfile;
  final VoidCallback onContact;

  const _HireCard({
    required this.application,
    required this.onViewProfile,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final salary = application.expectedSalary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                        application.jobTitle ?? 'Job Position',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hired Candidate ${application.jobSeekerId.substring(0, 8)}...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Active',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('Today', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 16),
                Icon(Icons.attach_money,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  salary != null
                      ? 'PKR ${NumberFormat('#,###').format(salary)}'
                      : 'Salary not specified',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewProfile,
                    icon: const Icon(Icons.person, size: 18),
                    label: const Text('View Profile'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onContact,
                    icon: const Icon(Icons.message, size: 18),
                    label: const Text('Contact'),
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
}
