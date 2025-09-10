import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/applications_providers.dart';
import '../../../core/widgets/app_logo.dart';

class ApplicationDetailPage extends ConsumerWidget {
  final String applicationId;
  const ApplicationDetailPage({super.key, required this.applicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(applicationByIdProvider(applicationId));
    return Scaffold(
      appBar: const BrandedAppBar(title: 'Application Details'),
      body: async.when(
        data: (a) {
          if (a == null) {
            return const Center(child: Text('Application not found'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: Text(a.jobTitle ?? 'Job'),
                subtitle: Text(a.employerName ?? ''),
                trailing: Chip(label: Text((a.status).toUpperCase())),
              ),
              const SizedBox(height: 12),
              if (a.cvUrl.isNotEmpty)
                FilledButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse(a.cvUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('View CV'),
                ),
              const SizedBox(height: 16),
              if (a.status == 'interview' && (a.notes?.isNotEmpty ?? false))
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Interview Notes',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(a.notes!),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/seeker/job/${a.jobId}'),
                child: const Text('View Job'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text('$e'),
            ],
          ),
        ),
      ),
    );
  }
}
