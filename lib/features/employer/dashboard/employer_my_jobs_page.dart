import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../widgets/job_card.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_logo.dart';

class EmployerMyJobsPage extends ConsumerWidget {
  const EmployerMyJobsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final jobsAsync = ref.watch(jobsByEmployerProvider(uid));
    return Scaffold(
      appBar: const BrandedAppBar(title: 'My Jobs'),
      body: jobsAsync.when(
        data: (jobs) {
          if (jobs.isEmpty) {
            return const Center(child: Text('No jobs posted yet'));
          }
          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Dismissible(
                key: ValueKey(job.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Job'),
                          content: const Text(
                              'Are you sure you want to delete this job?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete')),
                          ],
                        ),
                      ) ??
                      false;
                },
                onDismissed: (_) async {
                  try {
                    await ref.read(jobRepositoryProvider).deleteJob(job.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Job deleted')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete: $e')),
                    );
                  }
                },
                child: JobCard(
                  job: job,
                  onTap: () => context.go('/employer/post/${job.id}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/employer/post'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
