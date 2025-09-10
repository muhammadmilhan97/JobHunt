import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/application_providers.dart';
import '../../../core/providers/user_providers.dart';
import '../../../core/services/application_service.dart';

class ApplicantsListPage extends ConsumerWidget {
  final String jobId;
  final String jobTitle;

  const ApplicantsListPage({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(jobApplicationsProvider(jobId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Applicants'),
            Text(
              jobTitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        elevation: 1,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: applicationsAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildApplicationsList(context, ref, applications);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Failed to load applicants',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(jobApplicationsProvider(jobId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Applications Yet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Applications for this job will appear here',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList(
    BuildContext context,
    WidgetRef ref,
    List<Application> applications,
  ) {
    // Get unique user IDs to fetch user data
    final userIds = applications.map((app) => app.jobSeekerId).toSet().toList();
    
    return ref.watch(usersByIdsProvider(userIds)).when(
      data: (users) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: applications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final application = applications[index];
          final user = users[application.jobSeekerId];
          
          return _buildApplicationCard(context, ref, application, user);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Failed to load user data: $error'),
      ),
    );
  }

  Widget _buildApplicationCard(
    BuildContext context,
    WidgetRef ref,
    Application application,
    UserProfile? user,
  ) {
    final statusColors = ref.watch(applicationStatusColorsProvider);
    final statusLabels = ref.watch(applicationStatusLabelsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Unknown Applicant',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user?.city != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${user!.city}${user.country != null ? ', ${user.country}' : ''}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusChip(context, application.status, statusColors, statusLabels),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Application details
            Row(
              children: [
                // Expected salary
                if (application.expectedSalary != null) ...[
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      Icons.attach_money,
                      'Expected Salary',
                      'PKR ${_formatSalary(application.expectedSalary!)}',
                    ),
                  ),
                ],
                
                // Experience years
                if (user?.experienceYears != null) ...[
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      Icons.work_history,
                      'Experience',
                      '${user!.experienceYears} years',
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Cover letter (if exists)
            if (application.coverLetter != null && application.coverLetter!.isNotEmpty) ...[
              Text(
                'Cover Letter',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  application.coverLetter!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Actions
            Row(
              children: [
                // View CV button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _launchCV(application.cvUrl),
                    icon: const Icon(Icons.description, size: 18),
                    label: const Text('View CV'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Status dropdown
                Expanded(
                  flex: 2,
                  child: _buildStatusDropdown(context, ref, application),
                ),
              ],
            ),
            
            // Applied date
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Applied ${_formatDate(application.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    String status,
    Map<String, Color> statusColors,
    Map<String, String> statusLabels,
  ) {
    final color = statusColors[status] ?? Colors.grey;
    final label = statusLabels[status] ?? status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(
    BuildContext context,
    WidgetRef ref,
    Application application,
  ) {
    final statusLabels = ref.watch(applicationStatusLabelsProvider);
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: application.status,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          items: statusLabels.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                entry.value,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (newStatus) {
            if (newStatus != null && newStatus != application.status) {
              _updateApplicationStatus(ref, application.id, newStatus);
            }
          },
        ),
      ),
    );
  }

  Future<void> _updateApplicationStatus(
    WidgetRef ref,
    String applicationId,
    String newStatus,
  ) async {
    try {
      final notifier = ref.read(applicationNotifierProvider.notifier);
      await notifier.updateApplicationStatus(
        applicationId: applicationId,
        newStatus: newStatus,
      );
      
      // Show success message
      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(
            content: Text('Application status updated to ${newStatus}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchCV(String cvUrl) async {
    try {
      final uri = Uri.parse(cvUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch CV URL';
      }
    } catch (e) {
      print('Error launching CV: $e');
      // You might want to show a snackbar here
    }
  }

  String _formatSalary(int salary) {
    if (salary >= 1000000) {
      return '${(salary / 1000000).toStringAsFixed(1)}M';
    } else if (salary >= 1000) {
      return '${(salary / 1000).toStringAsFixed(0)}K';
    }
    return salary.toString();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
