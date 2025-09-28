import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/applications_providers.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_logo.dart';

class EmployerInterviewsPage extends ConsumerWidget {
  const EmployerInterviewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final applicationsAsync = uid != null
        ? ref.watch(applicationsForEmployerProvider(uid))
        : const AsyncValue<List<Application>>.data([]);

    return Scaffold(
      appBar: BrandedAppBar(
        title: 'Interviews',
        actions: [
          IconButton(
            onPressed: () => context.push('/employer/dashboard'),
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Dashboard',
          ),
        ],
      ),
      body: applicationsAsync.when(
        data: (applications) =>
            _buildInterviewsContent(context, applications, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildInterviewsContent(
      BuildContext context, List<Application> applications, WidgetRef ref) {
    // Filter applications that are ready for interviews (pending applications)
    final pendingApplications =
        applications.where((app) => app.status == 'pending').toList();
    final scheduledInterviews =
        applications.where((app) => app.status == 'interviewing').toList();
    final completedInterviews =
        applications.where((app) => app.status == 'interviewed').toList();

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
            // Analytics Cards
            _buildAnalyticsSection(applications),

            const SizedBox(height: 24),

            // Pending Applications (Ready to Schedule)
            if (pendingApplications.isNotEmpty) ...[
              _buildSectionTitle(
                  context, 'Ready to Schedule (${pendingApplications.length})'),
              const SizedBox(height: 12),
              ...pendingApplications.map((app) => _PendingInterviewCard(
                    application: app,
                    onSchedule: () => _scheduleInterview(context, app, ref),
                  )),
              const SizedBox(height: 24),
            ],

            // Upcoming Interviews
            if (scheduledInterviews.isNotEmpty) ...[
              _buildSectionTitle(context,
                  'Upcoming Interviews (${scheduledInterviews.length})'),
              const SizedBox(height: 12),
              ...scheduledInterviews.map((app) => _UpcomingInterviewCard(
                    application: app,
                    onReschedule: () => _rescheduleInterview(context, app, ref),
                    onJoin: () => _joinInterview(context, app),
                  )),
              const SizedBox(height: 24),
            ],

            // Interview History
            if (completedInterviews.isNotEmpty) ...[
              _buildSectionTitle(
                  context, 'Interview History (${completedInterviews.length})'),
              const SizedBox(height: 12),
              ...completedInterviews.map((app) => _CompletedInterviewCard(
                    application: app,
                    onViewNotes: () => _viewInterviewNotes(context, app),
                  )),
            ],

            // Empty State
            if (applications.isEmpty) _buildEmptyState(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(List<Application> applications) {
    final scheduledCount =
        applications.where((app) => app.status == 'interviewing').length;
    final completedCount =
        applications.where((app) => app.status == 'interviewed').length;

    return Row(
      children: [
        Expanded(
          child: _AnalyticsCard(
            title: 'Total Interviews',
            value: '${scheduledCount + completedCount}',
            icon: Icons.calendar_today_outlined,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _AnalyticsCard(
            title: 'Scheduled',
            value: scheduledCount.toString(),
            icon: Icons.schedule_outlined,
            color: Colors.orange,
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Interviews Yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Applications will appear here when candidates apply to your jobs.',
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
            Text('Error loading interviews',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _scheduleInterview(
      BuildContext context, Application application, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _ScheduleInterviewDialog(
        application: application,
        onScheduled: () {
          // Refresh data
          final uid = FirebaseAuth.instance.currentUser?.uid;
          if (uid != null) {
            ref.invalidate(applicationsForEmployerProvider(uid));
          }
        },
      ),
    );
  }

  void _rescheduleInterview(
      BuildContext context, Application application, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reschedule functionality coming soon')),
    );
  }

  void _joinInterview(BuildContext context, Application application) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video call integration coming soon')),
    );
  }

  void _viewInterviewNotes(BuildContext context, Application application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Interview Notes'),
        content: Text(
            'Interview completed for ${application.jobTitle}\n\nCandidate showed strong technical skills and good communication.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
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

class _PendingInterviewCard extends StatelessWidget {
  final Application application;
  final VoidCallback onSchedule;

  const _PendingInterviewCard({
    required this.application,
    required this.onSchedule,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.jobTitle ?? 'Job Application',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Candidate ${application.jobSeekerId.substring(0, 8)}...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      Text(
                        'Applied ${_formatDate(application.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Pending',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSchedule,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text('Schedule Interview'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // View candidate details
                    },
                    icon: const Icon(Icons.person, size: 18),
                    label: const Text('View Profile'),
                    style: OutlinedButton.styleFrom(
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

class _UpcomingInterviewCard extends StatelessWidget {
  final Application application;
  final VoidCallback onReschedule;
  final VoidCallback onJoin;

  const _UpcomingInterviewCard({
    required this.application,
    required this.onReschedule,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    // Mock interview time (in real app, this would be stored in Firebase)
    final interviewTime = DateTime.now().add(const Duration(hours: 2));

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
                        application.jobTitle ?? 'Job Application',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                          'with Candidate ${application.jobSeekerId.substring(0, 8)}...'),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Scheduled',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'Today at ${DateFormat('h:mm a').format(interviewTime)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 16),
                Icon(Icons.video_call,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('Video Call',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReschedule,
                    icon: const Icon(Icons.edit_calendar, size: 18),
                    label: const Text('Reschedule'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onJoin,
                    icon: const Icon(Icons.video_call, size: 18),
                    label: const Text('Join'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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

class _CompletedInterviewCard extends StatelessWidget {
  final Application application;
  final VoidCallback onViewNotes;

  const _CompletedInterviewCard({
    required this.application,
    required this.onViewNotes,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.jobTitle ?? 'Job Application',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      Text(
                          'with Candidate ${application.jobSeekerId.substring(0, 8)}...'),
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
                    'Completed',
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
                Text('Yesterday at 2:00 PM',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 16),
                Icon(Icons.person,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('In-Person',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onViewNotes,
              icon: const Icon(Icons.notes, size: 18),
              label: const Text('View Notes'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
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
              'Job: ${widget.application.jobTitle}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
                'Candidate: ${widget.application.jobSeekerId.substring(0, 8)}...'),
            const SizedBox(height: 16),

            // Date Selection
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
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
          onPressed: () {
            // TODO: Save interview to Firebase
            Navigator.of(context).pop();
            widget.onScheduled();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Interview scheduled for ${DateFormat('MMM dd').format(selectedDate)} at ${selectedTime.format(context)}',
                ),
              ),
            );
          },
          child: const Text('Schedule'),
        ),
      ],
    );
  }
}
