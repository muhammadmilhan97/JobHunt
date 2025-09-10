import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/application.dart';
import '../../../core/providers/applications_providers.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/widgets/app_logo.dart';

class EmployerApplicantsPage extends ConsumerWidget {
  final String jobId;

  const EmployerApplicantsPage({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicantsAsync = ref.watch(applicationsForJobProvider(jobId));

    return Scaffold(
      appBar: const BrandedAppBar(title: 'Applicants'),
      body: applicantsAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_outline, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'No applicants yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Applications will appear here once job seekers apply.',
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              return _ApplicantCard(
                application: application,
                onStatusUpdate: (newStatus) async {
                  // Log analytics
                  await AnalyticsService.logStatusChange(
                    jobId: jobId,
                    status: newStatus,
                    previousStatus: application.status,
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text('Failed to load applicants: $error'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final Application application;
  final Function(String) onStatusUpdate;

  const _ApplicantCard({
    required this.application,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    'A', // Placeholder since we don't have jobSeekerName
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Applicant', // Placeholder since we don't have jobSeekerName
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (application.expectedSalary != null)
                        Text(
                          'Expected: \$${application.expectedSalary}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                    ],
                  ),
                ),
                _StatusChip(status: application.status),
              ],
            ),
            const SizedBox(height: 12),
            if (application.coverLetter?.isNotEmpty ?? false) ...[
              Text(
                'Cover Letter:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                application.coverLetter!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewCV(context),
                    icon: const Icon(Icons.description),
                    label: const Text('View CV'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatusDropdown(
                    currentStatus: application.status,
                    onStatusChanged: onStatusUpdate,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _viewCV(BuildContext context) async {
    if (application.cvUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CV not available')),
      );
      return;
    }

    try {
      final uri = Uri.parse(application.cvUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch URL');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening CV: $e')),
      );
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'reviewing':
        color = Colors.blue;
        label = 'Reviewing';
        break;
      case 'interview':
        color = Colors.purple;
        label = 'Interview';
        break;
      case 'accepted':
        color = Colors.green;
        label = 'Accepted';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatusDropdown extends StatefulWidget {
  final String currentStatus;
  final Function(String) onStatusChanged;

  const _StatusDropdown({
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  State<_StatusDropdown> createState() => _StatusDropdownState();
}

class _StatusDropdownState extends State<_StatusDropdown> {
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: const [
        DropdownMenuItem(value: 'pending', child: Text('Pending')),
        DropdownMenuItem(value: 'reviewing', child: Text('Reviewing')),
        DropdownMenuItem(value: 'interview', child: Text('Interview')),
        DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
        DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
      ],
      onChanged: (newStatus) {
        if (newStatus != null && newStatus != _selectedStatus) {
          setState(() {
            _selectedStatus = newStatus;
          });
          widget.onStatusChanged(newStatus);
        }
      },
    );
  }
}
