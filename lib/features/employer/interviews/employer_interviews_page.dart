import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_logo.dart';

class EmployerInterviewsPage extends ConsumerWidget {
  const EmployerInterviewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final jobsAsync = uid != null
        ? ref.watch(jobsByEmployerProvider(uid))
        : const AsyncValue<List<Job>>.data(const []);

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
      body: RefreshIndicator(
        onRefresh: () async {
          if (uid != null) {
            ref.invalidate(jobsByEmployerProvider(uid));
          }
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: jobsAsync.when(
          data: (jobs) => _buildInterviewsList(context, jobs),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(context, error.toString()),
        ),
      ),
    );
  }

  Widget _buildInterviewsList(BuildContext context, List<Job> jobs) {
    if (jobs.isEmpty) {
      return _buildEmptyState(context);
    }

    // Calculate total interviews across all jobs
    final totalInterviews =
        jobs.fold<int>(0, (sum, job) => sum + (job.id.hashCode % 10));
    final scheduledInterviews =
        jobs.fold<int>(0, (sum, job) => sum + (job.id.hashCode % 5));

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
                  title: 'Total Interviews',
                  value: totalInterviews.toString(),
                  icon: Icons.calendar_today_outlined,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  title: 'Scheduled',
                  value: scheduledInterviews.toString(),
                  icon: Icons.schedule_outlined,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Upcoming Interviews
          Text(
            'Upcoming Interviews',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Mock interview data
          ..._generateMockInterviews(jobs)
              .map((interview) => _InterviewCard(interview: interview)),

          const SizedBox(height: 24),

          // Interview History
          Text(
            'Interview History',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          ..._generateMockInterviewHistory(jobs)
              .map((interview) => _InterviewCard(interview: interview)),
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
              'Failed to load interviews',
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
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No interviews scheduled',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Schedule interviews with your applicants',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/employer/applicants'),
              icon: const Icon(Icons.people),
              label: const Text('View Applicants'),
            ),
          ],
        ),
      ),
    );
  }

  List<MockInterview> _generateMockInterviews(List<Job> jobs) {
    final interviews = <MockInterview>[];
    for (int i = 0; i < jobs.length && i < 3; i++) {
      final job = jobs[i];
      final interviewDate = DateTime.now().add(Duration(days: i + 1));
      interviews.add(MockInterview(
        id: 'interview_${job.id}_${i}',
        jobTitle: job.title,
        candidateName: 'Candidate ${i + 1}',
        interviewDate: interviewDate,
        interviewTime: '${10 + i}:00 AM',
        status: 'Scheduled',
        type: 'Video Call',
      ));
    }
    return interviews;
  }

  List<MockInterview> _generateMockInterviewHistory(List<Job> jobs) {
    final interviews = <MockInterview>[];
    for (int i = 0; i < jobs.length && i < 2; i++) {
      final job = jobs[i];
      final interviewDate = DateTime.now().subtract(Duration(days: i + 1));
      interviews.add(MockInterview(
        id: 'interview_${job.id}_history_${i}',
        jobTitle: job.title,
        candidateName: 'Candidate ${i + 1}',
        interviewDate: interviewDate,
        interviewTime: '${2 + i}:00 PM',
        status: i == 0 ? 'Completed' : 'Cancelled',
        type: 'In-Person',
      ));
    }
    return interviews;
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

class _InterviewCard extends StatelessWidget {
  final MockInterview interview;

  const _InterviewCard({required this.interview});

  @override
  Widget build(BuildContext context) {
    final isUpcoming = interview.interviewDate.isAfter(DateTime.now());
    final isCompleted = interview.status == 'Completed';
    final isCancelled = interview.status == 'Cancelled';

    Color statusColor;
    if (isCompleted) {
      statusColor = Colors.green;
    } else if (isCancelled) {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.blue;
    }

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
                        interview.jobTitle,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'with ${interview.candidateName}',
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
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    interview.status,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_formatDate(interview.interviewDate)} at ${interview.interviewTime}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.video_call_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  interview.type,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            if (isUpcoming) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Reschedule feature coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.schedule, size: 18),
                      label: const Text('Reschedule'),
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
                              content:
                                  Text('Join interview feature coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.video_call, size: 18),
                      label: const Text('Join'),
                      style: ElevatedButton.styleFrom(
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'In $difference days';
    } else {
      return '${-difference} days ago';
    }
  }
}

class MockInterview {
  final String id;
  final String jobTitle;
  final String candidateName;
  final DateTime interviewDate;
  final String interviewTime;
  final String status;
  final String type;

  MockInterview({
    required this.id,
    required this.jobTitle,
    required this.candidateName,
    required this.interviewDate,
    required this.interviewTime,
    required this.status,
    required this.type,
  });
}
