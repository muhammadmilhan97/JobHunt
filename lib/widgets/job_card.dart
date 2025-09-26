import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/job.dart';
import '../core/providers/favorites_providers.dart';
import '../core/services/analytics_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../core/utils/currency.dart';

class JobCard extends ConsumerWidget {
  final Job job;
  final VoidCallback? onTap;
  final bool? isSaved;
  final VoidCallback? onSave;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.isSaved,
    this.onSave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use provider if isSaved is not provided
    final savedState =
        isSaved ?? ref.watch(isFavoriteProvider(job.id)).value ?? false;
    final toggleFavoriteFunction = ref.read(toggleFavoriteProvider);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.company,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 48, // Ensure minimum tap target size
                    height: 48,
                    child: IconButton(
                      onPressed: () {
                        toggleFavoriteFunction(job.id);
                        // Log analytics
                        AnalyticsService.logSave(
                          jobId: job.id,
                          isSaved: !savedState,
                        );
                      },
                      icon: Icon(
                        savedState ? Icons.favorite : Icons.favorite_border,
                        color: savedState ? Colors.red : null,
                      ),
                      tooltip: savedState
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${job.locationCity}, ${job.locationCountry}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'PKR',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    CurrencyFormatter.formatPkrRange(
                        job.salaryMin, job.salaryMax),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    timeago.format(job.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
