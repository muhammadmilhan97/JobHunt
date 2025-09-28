import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/applications_providers.dart';
import '../../../core/providers/user_providers.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_logo.dart';

class EmployerAllApplicantsPage extends ConsumerWidget {
  const EmployerAllApplicantsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final applicationsAsync = uid != null
        ? ref.watch(applicationsForEmployerProvider(uid))
        : const AsyncValue<List<Application>>.data(const []);

    // Debug logging
    applicationsAsync.when(
      data: (applications) =>
          print('Applicants - Applications loaded: ${applications.length}'),
      loading: () => print('Applicants - Loading applications...'),
      error: (error, stack) =>
          print('Applicants - Error loading applications: $error'),
    );

    return Scaffold(
      appBar: BrandedAppBar(
        title: 'All Applicants',
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
            ref.invalidate(applicationsForEmployerProvider(uid));
          }
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: applicationsAsync.when(
          data: (applications) => _buildApplicantsList(context, applications),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(context, error.toString()),
        ),
      ),
    );
  }

  Widget _buildApplicantsList(
      BuildContext context, List<Application> applications) {
    if (applications.isEmpty) {
      return _buildEmptyState(context);
    }

    // Calculate real metrics from applications
    final totalApplicants = applications.length;
    final pendingApplications =
        applications.where((app) => app.status == 'pending').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Total Applicants',
                  value: totalApplicants.toString(),
                  icon: Icons.people_outline,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: 'Pending',
                  value: pendingApplications.toString(),
                  icon: Icons.pending_outlined,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Jobs with Applicants
          Text(
            'All Applications',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // List all applications
          ...applications
              .map((application) => _ApplicationCard(application: application)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'Failed to load applicants',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
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
              'No applicants yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Post jobs to start receiving applications',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/employer/post'),
              icon: const Icon(Icons.add),
              label: const Text('Post New Job'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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

class _ApplicationCard extends ConsumerWidget {
  final Application application;

  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync =
        ref.watch(userStreamProvider(application.jobSeekerId));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(application.status),
                  child: Icon(
                    _getStatusIcon(application.status),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      userProfileAsync.when(
                        data: (userProfile) => Text(
                          userProfile?.name ?? 'Unknown Applicant',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        loading: () => const Text('Loading...'),
                        error: (_, __) => const Text('Error loading name'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Applied: ${_formatDate(application.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
                _getStatusChip(application.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job ID: ${application.jobId.substring(0, 8)}...',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (application.expectedSalary != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Expected: PKR ${NumberFormat('#,##0').format(application.expectedSalary)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (application.cvUrl.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse(application.cvUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url,
                            mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open CV')),
                        );
                      }
                    },
                    icon: const Icon(Icons.description, size: 16),
                    label: const Text('View CV'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
              ],
            ),
            if (application.coverLetter != null &&
                application.coverLetter!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Cover Letter:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                application.coverLetter!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to job-specific applicants page
                      context.push(
                          '/employer/job/${application.jobId}/applicants?title=Job');
                    },
                    icon: const Icon(Icons.people, size: 16),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'accepted':
        return Icons.check;
      case 'rejected':
        return Icons.close;
      default:
        return Icons.help;
    }
  }

  Widget _getStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
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

  Widget _buildActionButton(BuildContext context, WidgetRef ref) {
    switch (application.status.toLowerCase()) {
      case 'pending':
        return ElevatedButton.icon(
          onPressed: () async {
            await ref
                .read(applicationsRepositoryProvider)
                .updateStatus(application.id, 'reviewing');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Application moved to reviewing')),
            );
          },
          icon: const Icon(Icons.rate_review, size: 16),
          label: const Text('Start Review'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        );
      case 'reviewing':
        return ElevatedButton.icon(
          onPressed: () async {
            await ref
                .read(applicationsRepositoryProvider)
                .updateStatus(application.id, 'accepted');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Application accepted')),
            );
          },
          icon: const Icon(Icons.check_circle, size: 16),
          label: const Text('Accept'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        );
      case 'accepted':
        return ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Already accepted')),
            );
          },
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Accepted'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        );
      case 'rejected':
        return ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Already rejected')),
            );
          },
          icon: const Icon(Icons.cancel, size: 16),
          label: const Text('Rejected'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
