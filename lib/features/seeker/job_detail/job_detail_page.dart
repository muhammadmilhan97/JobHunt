import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/job.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/services/analytics_service.dart';
import '../../../widgets/job_card.dart';
import '../../../core/utils/currency.dart';
import 'apply_bottom_sheet.dart' as new_apply;

class JobDetailPage extends ConsumerStatefulWidget {
  final String jobId;

  const JobDetailPage({super.key, required this.jobId});

  @override
  ConsumerState<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends ConsumerState<JobDetailPage> {
  @override
  void initState() {
    super.initState();
    // Log job view analytics
    _logJobView();
  }

  Future<void> _logJobView() async {
    final jobAsync = ref.read(jobByIdProvider(widget.jobId));
    jobAsync.whenData((job) {
      if (job != null) {
        AnalyticsService.logJobView(
          jobId: job.id,
          category: job.category,
          city: job.locationCity,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(jobByIdProvider(widget.jobId));

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/seeker/home');
          }
        }
      },
      child: Scaffold(
        appBar: BrandedAppBar(
          title: 'Job Details',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/seeker/home');
              }
            },
            tooltip: 'Back',
          ),
        ),
        body: jobAsync.when(
          data: (job) {
            if (job == null) {
              return const Center(child: Text('Job not found'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job card at the top
                  JobCard(
                    job: job,
                    onTap:
                        null, // Disable tap since we're already on detail page
                  ),
                  const SizedBox(height: 24),

                  // Job description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Requirements
                  if (job.requirements.isNotEmpty) ...[
                    Text(
                      'Requirements',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job.requirements.join(', '),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Skills
                  if (job.skills.isNotEmpty) ...[
                    Text(
                      'Skills',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: job.skills
                          .map((skill) => Chip(
                                label: Text(skill),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Additional details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Additional Details',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.business,
                            label: 'Company',
                            value: job.company,
                          ),
                          _DetailRow(
                            icon: Icons.location_on,
                            label: 'Location',
                            value:
                                '${job.locationCity}, ${job.locationCountry}',
                          ),
                          _DetailRow(
                            icon: Icons.category,
                            label: 'Category',
                            value: job.category,
                          ),
                          _DetailRow(
                            icon: Icons.work,
                            label: 'Type',
                            value: job.type,
                          ),
                          if (job.salaryMin != null || job.salaryMax != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.monetization_on_outlined,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Salary',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.08),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'PKR',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              CurrencyFormatter.formatPkrRange(
                                                job.salaryMin,
                                                job.salaryMax,
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          _DetailRow(
                            icon: Icons.schedule,
                            label: 'Posted',
                            value: _formatDate(job.createdAt),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading job details'),
                const SizedBox(height: 8),
                Text(error.toString()),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(jobByIdProvider(widget.jobId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: jobAsync.when(
          data: (job) {
            if (job == null) return null;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: () => _showApplyBottomSheet(job),
                  child: const Text('Apply Now'),
                ),
              ),
            );
          },
          loading: () => null,
          error: (_, __) => null,
        ),
      ),
    );
  }

  void _showApplyBottomSheet(Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => new_apply.ApplyBottomSheet(
        jobId: job.id,
        jobTitle: job.title,
        companyName: job.company,
        employerId: job.employerId,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
