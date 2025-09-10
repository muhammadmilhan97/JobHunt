import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../providers/notification_providers.dart';

/// In-app notification banner that shows foreground FCM messages
class InAppNotificationBanner extends ConsumerWidget {
  final Widget child;

  const InAppNotificationBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inAppNotification = ref.watch(inAppNotificationProvider);

    // Listen to foreground messages
    ref.listen(foregroundMessageListenerProvider, (_, __) {});

    return Stack(
      alignment:
          Alignment.topCenter, // Explicitly set non-directional alignment
      children: [
        child,
        if (inAppNotification != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: _NotificationBanner(
              message: inAppNotification,
              onTap: () {
                // Handle notification tap
                _handleNotificationTap(context, inAppNotification);
                // Clear the notification
                ref.read(inAppNotificationProvider.notifier).state = null;
              },
              onDismiss: () {
                // Clear the notification
                ref.read(inAppNotificationProvider.notifier).state = null;
              },
            ),
          ),
      ],
    );
  }

  void _handleNotificationTap(BuildContext context, RemoteMessage message) {
    // Handle different notification types based on data
    final data = message.data;

    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'job_posted':
          if (data.containsKey('jobId')) {
            // Navigate to job detail
            // context.go('/seeker/job/${data['jobId']}');
          }
          break;
        case 'application_status':
          // Navigate to applications
          break;
        case 'new_message':
          // Navigate to messages
          break;
        default:
          // Default action
          break;
      }
    }
  }
}

class _NotificationBanner extends StatefulWidget {
  final RemoteMessage message;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationBanner({
    required this.message,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getNotificationIcon(),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.message.notification?.title ??
                                'Notification',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.message.notification?.body != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.message.notification!.body!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _dismiss,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon() {
    final data = widget.message.data;

    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'job_posted':
          return Icons.work;
        case 'application_status':
          return Icons.assignment_turned_in;
        case 'new_message':
          return Icons.message;
        case 'reminder':
          return Icons.notification_important;
        default:
          return Icons.notifications;
      }
    }

    return Icons.notifications;
  }
}
