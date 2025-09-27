import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/providers/applications_providers.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/models/application.dart';
import '../../../core/utils/back_button_handler.dart';

class ApplicationDetailPage extends ConsumerWidget {
  final String applicationId;

  const ApplicationDetailPage({
    super.key,
    required this.applicationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationAsync = ref.watch(applicationProvider(applicationId));

    return BackButtonHandler.createPopScope(
      context: context,
      child: Scaffold(
        appBar: BrandedAppBar(
          title: 'Application Details',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/seeker/applications'),
            tooltip: 'Back',
          ),
        ),
        body: applicationAsync.when(
          data: (application) {
            if (application == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      'Application not found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('This application may have been deleted.'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Application Status Card
                  _StatusCard(application: application),

                  const SizedBox(height: 20),

                  // Job Information
                  _SectionCard(
                    title: 'Job Information',
                    icon: Icons.work_outline,
                    children: [
                      _InfoRow(
                        label: 'Position',
                        value: application.jobTitle ?? 'Not specified',
                      ),
                      if (application.employerName != null)
                        _InfoRow(
                          label: 'Company',
                          value: application.employerName!,
                        ),
                      if (application.expectedSalary != null)
                        _InfoRow(
                          label: 'Expected Salary',
                          value:
                              'Rs. ${application.expectedSalary!.toString().replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  )}',
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Application Details
                  _SectionCard(
                    title: 'Application Details',
                    icon: Icons.description_outlined,
                    children: [
                      _InfoRow(
                        label: 'Applied Date',
                        value: timeago.format(application.createdAt),
                      ),
                      if (application.updatedAt != null)
                        _InfoRow(
                          label: 'Last Updated',
                          value: timeago.format(application.updatedAt!),
                        ),
                      _InfoRow(
                        label: 'Status',
                        value: application.status.toUpperCase(),
                      ),
                    ],
                  ),

                  if (application.coverLetter != null &&
                      application.coverLetter!.isNotEmpty) ...[
                    const SizedBox(height: 20),

                    // Cover Letter
                    _SectionCard(
                      title: 'Cover Letter',
                      icon: Icons.article_outlined,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceVariant
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            application.coverLetter!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (application.notes != null &&
                      application.notes!.isNotEmpty) ...[
                    const SizedBox(height: 20),

                    // Notes
                    _SectionCard(
                      title: 'Notes',
                      icon: Icons.note_outlined,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceVariant
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            application.notes!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _viewJob(context, application.jobId),
                          icon: const Icon(Icons.work),
                          label: const Text('View Job'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () =>
                              _downloadCV(context, application.cvUrl),
                          icon: const Icon(Icons.download),
                          label: const Text('Download CV'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text('Failed to load application'),
                const SizedBox(height: 8),
                Text('$e'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _viewJob(BuildContext context, String jobId) {
    // Navigate to job details page
    context.go('/seeker/job/$jobId');
  }

  Future<void> _downloadCV(BuildContext context, String cvUrl) async {
    if (cvUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No CV available for download'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Download the file
      final response = await http.get(Uri.parse(cvUrl));
      if (response.statusCode == 200) {
        // Get the downloads directory
        final directory = await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
        final fileName = 'CV_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('${directory.path}/$fileName');

        // Write the file
        await file.writeAsBytes(response.bodyBytes);

        // Close loading dialog
        if (context.mounted) Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CV downloaded to ${directory.path}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => _openFile(file.path),
            ),
          ),
        );
      } else {
        // Close loading dialog
        if (context.mounted) Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download CV'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openFile(String filePath) async {
    final uri = Uri.file(filePath);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _StatusCard extends StatelessWidget {
  final Application application;

  const _StatusCard({required this.application});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment_turned_in,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Application Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                _StatusChip(status: application.status),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getStatusMessage(application.status),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Your application is being reviewed by the employer. You will be notified once a decision is made.';
      case 'reviewed':
        return 'Your application has been reviewed. The employer is currently making a decision.';
      case 'shortlisted':
        return 'Congratulations! You have been shortlisted for this position. The employer may contact you for further steps.';
      case 'rejected':
        return 'Unfortunately, your application was not selected for this position. Keep applying to other opportunities!';
      case 'hired':
        return 'Congratulations! You have been hired for this position. The employer will contact you with next steps.';
      default:
        return 'Your application status is being updated.';
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.schedule;
        break;
      case 'reviewed':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        icon = Icons.visibility;
        break;
      case 'shortlisted':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle_outline;
        break;
      case 'rejected':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.cancel_outlined;
        break;
      case 'hired':
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade800;
        icon = Icons.celebration;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
