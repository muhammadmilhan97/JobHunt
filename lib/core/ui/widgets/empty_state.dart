import 'package:flutter/material.dart';

/// A widget that displays an empty state with an icon, text, and optional CTA
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final double iconSize;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Predefined empty states for common scenarios
class EmptyStates {
  /// Empty state for no jobs found
  static Widget noJobs({VoidCallback? onRefresh}) => EmptyState(
        icon: Icons.work_outline,
        title: 'No jobs found',
        subtitle: 'Try adjusting your search criteria or check back later.',
        actionText: 'Refresh',
        onAction: onRefresh,
      );

  /// Empty state for no applications
  static Widget noApplications() => const EmptyState(
        icon: Icons.inbox_outlined,
        title: 'No applications yet',
        subtitle: 'Start applying to jobs and they will appear here.',
      );

  /// Empty state for no favorites
  static Widget noFavorites() => const EmptyState(
        icon: Icons.favorite_border,
        title: 'No favorite jobs yet',
        subtitle: 'Tap the heart icon on jobs to save them here.',
      );

  /// Empty state for no notifications
  static Widget noNotifications() => const EmptyState(
        icon: Icons.notifications_none,
        title: 'No notifications',
        subtitle: 'You\'ll see important updates here.',
      );

  /// Empty state for no search results
  static Widget noSearchResults({VoidCallback? onClearFilters}) => EmptyState(
        icon: Icons.search_off,
        title: 'No results found',
        subtitle: 'Try adjusting your search criteria.',
        actionText: 'Clear filters',
        onAction: onClearFilters,
      );
}
