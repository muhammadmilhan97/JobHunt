import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/application.dart';
import '../../../core/providers/applications_providers.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/email_service.dart';
import '../../../core/widgets/app_logo.dart';

class EmployerApplicantsPage extends ConsumerWidget {
  final String jobId;
  final String jobTitle;

  const EmployerApplicantsPage({
    super.key,
    required this.jobId,
    this.jobTitle = 'Job',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicantsAsync = ref.watch(applicationsForJobProvider(jobId));

    return Scaffold(
      appBar: BrandedAppBar(
        title: 'Applicants - $jobTitle',
      ),
      body: applicantsAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return _buildEmptyState(context);
          }

          // Sort applications by status priority and date
          final sortedApplications = [...applications];
          sortedApplications.sort((a, b) {
            final statusPriority = {
              'pending': 0,
              'reviewing': 1,
              'accepted': 2,
              'rejected': 3
            };
            final aPriority = statusPriority[a.status] ?? 4;
            final bPriority = statusPriority[b.status] ?? 4;

            if (aPriority != bPriority) {
              return aPriority.compareTo(bPriority);
            }
            return b.createdAt.compareTo(a.createdAt); // Newest first
          });

          return Column(
            children: [
              // Summary Header
              _buildSummaryHeader(applications),
              // Applications List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedApplications.length,
                  itemBuilder: (context, index) {
                    final application = sortedApplications[index];
                    return _ApplicantCard(
                      application: application,
                      jobTitle: jobTitle,
                      onStatusUpdate: (newStatus) => _updateApplicationStatus(
                        context,
                        ref,
                        application,
                        newStatus,
                      ),
                      onViewCV: () => _viewCV(context, application),
                      onScheduleInterview: () =>
                          _scheduleInterview(context, ref, application),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildSummaryHeader(List<Application> applications) {
    final pending = applications.where((app) => app.status == 'pending').length;
    final reviewing =
        applications.where((app) => app.status == 'reviewing').length;
    final accepted =
        applications.where((app) => app.status == 'accepted').length;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Expanded(
              child: _SummaryItem(
                  'Total', applications.length.toString(), Colors.blue)),
          Expanded(
              child:
                  _SummaryItem('Pending', pending.toString(), Colors.orange)),
          Expanded(
              child: _SummaryItem(
                  'Reviewing', reviewing.toString(), Colors.purple)),
          Expanded(
              child:
                  _SummaryItem('Accepted', accepted.toString(), Colors.green)),
        ],
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
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Applications Yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Applications will appear here when candidates apply to this job.',
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
            Text('Error loading applicants',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Future<void> _updateApplicationStatus(
    BuildContext context,
    WidgetRef ref,
    Application application,
    String newStatus,
  ) async {
    try {
      // Update status in Firebase
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(application.id)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send email notification to candidate
      await _sendStatusUpdateEmail(application, newStatus);

      // Log analytics
      await AnalyticsService.logStatusChange(
        jobId: jobId,
        status: newStatus,
        previousStatus: application.status,
      );

      // Refresh the applications list
      ref.invalidate(applicationsForJobProvider(jobId));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Application status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendStatusUpdateEmail(
      Application application, String newStatus) async {
    try {
      String subject = '';
      String message = '';

      switch (newStatus) {
        case 'reviewing':
          subject = 'Application Under Review - ${application.jobTitle}';
          message = '''
Dear Candidate,

Thank you for your application for the ${application.jobTitle} position at ${application.employerName}.

We are currently reviewing your application and will get back to you soon.

Best regards,
${application.employerName} Team
''';
          break;

        case 'accepted':
          subject =
              'Congratulations! Application Accepted - ${application.jobTitle}';
          message = '''
Dear Candidate,

Congratulations! We are pleased to inform you that your application for the ${application.jobTitle} position has been accepted.

We will contact you soon to discuss the next steps.

Best regards,
${application.employerName} Team
''';
          break;

        case 'rejected':
          subject = 'Application Update - ${application.jobTitle}';
          message = '''
Dear Candidate,

Thank you for your interest in the ${application.jobTitle} position at ${application.employerName}.

After careful consideration, we have decided to move forward with other candidates. We appreciate the time you took to apply and wish you the best in your job search.

Best regards,
${application.employerName} Team
''';
          break;
      }

      if (subject.isNotEmpty && message.isNotEmpty) {
        await EmailService.sendEmail(
          to: 'candidate@example.com', // In real app, get from user profile
          toName: 'Candidate',
          subject: subject,
          htmlContent: message.replaceAll('\n', '<br>'),
          textContent: message,
          emailType: 'application_status_update',
          metadata: {
            'applicationId': application.id,
            'jobId': application.jobId,
            'newStatus': newStatus,
          },
        );
      }
    } catch (e) {
      print('Error sending status update email: $e');
    }
  }

  void _viewCV(BuildContext context, Application application) {
    if (application.cvUrl.isNotEmpty) {
      _launchURL(application.cvUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No CV available')),
      );
    }
  }

  void _scheduleInterview(
      BuildContext context, WidgetRef ref, Application application) {
    showDialog(
      context: context,
      builder: (context) => _ScheduleInterviewDialog(
        application: application,
        onScheduled: () {
          // Update status to interviewing and refresh
          _updateApplicationStatus(context, ref, application, 'interviewing');
        },
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final Application application;
  final String jobTitle;
  final Function(String) onStatusUpdate;
  final VoidCallback onViewCV;
  final VoidCallback onScheduleInterview;

  const _ApplicantCard({
    required this.application,
    required this.jobTitle,
    required this.onStatusUpdate,
    required this.onViewCV,
    required this.onScheduleInterview,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      _getStatusColor(application.status).withOpacity(0.1),
                  child: Icon(
                    _getStatusIcon(application.status),
                    color: _getStatusColor(application.status),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Candidate ${application.jobSeekerId.substring(0, 8)}...',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                        'Applied ${_formatDate(application.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: application.status),
              ],
            ),

            const SizedBox(height: 12),

            // Application Details
            if (application.expectedSalary != null) ...[
              Row(
                children: [
                  Icon(Icons.attach_money,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                      'Expected Salary: PKR ${application.expectedSalary!.toStringAsFixed(0)}'),
                ],
              ),
              const SizedBox(height: 4),
            ],

            if (application.coverLetter != null &&
                application.coverLetter!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.message, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      application.coverLetter!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ] else ...[
              const SizedBox(height: 4),
            ],

            // Action Buttons
            Row(
              children: [
                // View CV Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewCV,
                    icon: const Icon(Icons.description, size: 18),
                    label: const Text('View CV'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Status Action Button
                Expanded(
                  child: _buildActionButton(context),
                ),
              ],
            ),

            // Additional Actions Row (if needed)
            if (application.status == 'pending') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onStatusUpdate('reviewing'),
                      icon: const Icon(Icons.rate_review, size: 18),
                      label: const Text('Start Review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onStatusUpdate('rejected'),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    switch (application.status) {
      case 'reviewing':
        return ElevatedButton.icon(
          onPressed: onScheduleInterview,
          icon: const Icon(Icons.calendar_today, size: 18),
          label: const Text('Schedule Interview'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        );

      case 'interviewing':
        return ElevatedButton.icon(
          onPressed: () => onStatusUpdate('accepted'),
          icon: const Icon(Icons.check_circle, size: 18),
          label: const Text('Accept'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        );

      case 'accepted':
        return ElevatedButton.icon(
          onPressed: () {
            // Contact candidate
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Contact functionality coming soon')),
            );
          },
          icon: const Icon(Icons.contact_mail, size: 18),
          label: const Text('Contact'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        );

      case 'rejected':
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Rejected',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        );

      default:
        return ElevatedButton.icon(
          onPressed: () => onStatusUpdate('reviewing'),
          icon: const Icon(Icons.rate_review, size: 18),
          label: const Text('Review'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'reviewing':
        return Colors.purple;
      case 'interviewing':
        return Colors.blue;
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
      case 'reviewing':
        return Icons.rate_review;
      case 'interviewing':
        return Icons.calendar_today;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
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

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'reviewing':
        return Colors.purple;
      case 'interviewing':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _ScheduleInterviewDialog extends StatefulWidget {
  final Application application;
  final VoidCallback onScheduled;

  const _ScheduleInterviewDialog({
    required this.application,
    required this.onScheduled,
  });

  @override
  State<_ScheduleInterviewDialog> createState() =>
      _ScheduleInterviewDialogState();
}

class _ScheduleInterviewDialogState extends State<_ScheduleInterviewDialog> {
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
  String interviewType = 'Video Call';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule Interview'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Candidate: ${widget.application.jobSeekerId.substring(0, 8)}...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Date Selection
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
            ),

            // Time Selection
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('Time'),
              subtitle: Text(selectedTime.format(context)),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (time != null) {
                  setState(() => selectedTime = time);
                }
              },
            ),

            // Interview Type
            const SizedBox(height: 8),
            const Text('Interview Type'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: interviewType,
              items: const [
                DropdownMenuItem(
                    value: 'Video Call', child: Text('Video Call')),
                DropdownMenuItem(value: 'In-Person', child: Text('In-Person')),
                DropdownMenuItem(
                    value: 'Phone Call', child: Text('Phone Call')),
              ],
              onChanged: (value) => setState(() => interviewType = value!),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Send interview scheduled email
            await _sendInterviewScheduledEmail();

            Navigator.of(context).pop();
            widget.onScheduled();

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Interview scheduled for ${selectedDate.day}/${selectedDate.month} at ${selectedTime.format(context)}',
                  ),
                ),
              );
            }
          },
          child: const Text('Schedule'),
        ),
      ],
    );
  }

  Future<void> _sendInterviewScheduledEmail() async {
    try {
      final subject = 'Interview Scheduled - ${widget.application.jobTitle}';
      final message = '''
Dear Candidate,

We are pleased to inform you that an interview has been scheduled for the ${widget.application.jobTitle} position.

Interview Details:
- Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}
- Time: ${selectedTime.format(context)}
- Type: $interviewType

We look forward to speaking with you.

Best regards,
${widget.application.employerName} Team
''';

      await EmailService.sendEmail(
        to: 'candidate@example.com', // In real app, get from user profile
        toName: 'Candidate',
        subject: subject,
        htmlContent: message.replaceAll('\n', '<br>'),
        textContent: message,
        emailType: 'interview_scheduled',
        metadata: {
          'applicationId': widget.application.id,
          'jobId': widget.application.jobId,
          'interviewDate': selectedDate.toIso8601String(),
          'interviewTime': '${selectedTime.hour}:${selectedTime.minute}',
          'interviewType': interviewType,
        },
      );
    } catch (e) {
      print('Error sending interview scheduled email: $e');
    }
  }
}
