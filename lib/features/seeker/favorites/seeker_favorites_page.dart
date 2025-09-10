import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/favorites_providers.dart';
import '../../../widgets/job_card.dart';

class SeekerFavoritesPage extends ConsumerWidget {
  const SeekerFavoritesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favs = ref.watch(favoritesJobsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favs.when(
        data: (jobs) {
          if (jobs.isEmpty) {
            return const Center(child: Text('No favorites yet'));
          }
          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return JobCard(
                job: job,
                isSaved: true,
                onSave: () async {
                  final toggle = ref.read(toggleFavoriteProvider);
                  await toggle(job.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Removed from favorites'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () => toggle(job.id),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
