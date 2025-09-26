import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/notification_bell_icon.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../widgets/job_card.dart';
import '../../../core/providers/favorites_providers.dart';
import '../../../core/utils/currency.dart';

class SeekerHomePage extends ConsumerStatefulWidget {
  const SeekerHomePage({super.key});

  @override
  ConsumerState<SeekerHomePage> createState() => _SeekerHomePageState();
}

class _SeekerHomePageState extends ConsumerState<SeekerHomePage> {
  String _selectedCategory = 'All';
  String? _selectedCity;
  String? _selectedType;
  double _minSalary = 0;
  double _maxSalary = 500000;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final jobsAsync = ref.watch(latestJobsProvider);
        final categoriesAsync = ref.watch(categoriesProvider);

        return Scaffold(
          appBar: BrandedAppBar(
            title: 'Find your next job',
            actions: [
              IconButton(
                onPressed: _showFilterBottomSheet,
                icon: const Icon(Icons.tune),
                tooltip: 'Filters',
              ),
              const NotificationBellIcon(),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'logout') {
                    final authNotifier =
                        ref.read(authNotifierProvider.notifier);
                    await authNotifier.signOut();
                    if (context.mounted) {
                      context.go('/auth');
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Sign Out'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(latestJobsProvider);
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: CustomScrollView(
              slivers: [
                // Branded hero
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 16, left: 16, right: 16, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(child: AppLogo.large()),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                // Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search jobs, companies...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(0.5),
                      ),
                      onChanged: (value) {
                        // TODO: Implement search functionality
                      },
                    ),
                  ),
                ),

                // Category chips
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 60,
                    child: categoriesAsync.when(
                      data: (categories) {
                        final allCategories = ['All', ...categories];
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: allCategories.length,
                          itemBuilder: (context, index) {
                            final category = allCategories[index];
                            final isSelected = _selectedCategory == category;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                                selectedColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                checkmarkColor: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Text('Error loading categories: $error'),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // Jobs list
                jobsAsync.when(
                  data: (jobs) {
                    final filteredJobs = _filterJobs(jobs);

                    if (filteredJobs.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.work_off,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No jobs found',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Try adjusting your filters',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverList.builder(
                      itemCount: filteredJobs.length,
                      itemBuilder: (context, index) {
                        final job = filteredJobs[index];
                        final isFavAsync =
                            ref.watch(isFavoriteProvider(job.id));
                        return isFavAsync.when(
                          data: (isFav) => JobCard(
                            job: job,
                            isSaved: isFav,
                            onTap: () => _navigateToJobDetail(job.id),
                            onSave: () async {
                              final toggle = ref.read(toggleFavoriteProvider);
                              await toggle(job.id);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isFav
                                      ? 'Removed from favorites'
                                      : 'Added to favorites'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () => toggle(job.id),
                                  ),
                                ),
                              );
                            },
                          ),
                          loading: () => JobCard(
                            job: job,
                            isSaved: false,
                            onTap: () => _navigateToJobDetail(job.id),
                            onSave: () {},
                          ),
                          error: (e, st) => JobCard(
                            job: job,
                            isSaved: false,
                            onTap: () => _navigateToJobDetail(job.id),
                            onSave: () {},
                          ),
                        );
                      },
                    );
                  },
                  loading: () => SliverList.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) => _buildShimmerJobCard(),
                  ),
                  error: (error, stack) => SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Something went wrong',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(latestJobsProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Job> _filterJobs(List<Job> jobs) {
    return jobs.where((job) {
      // Category filter
      if (_selectedCategory != 'All' && job.category != _selectedCategory) {
        return false;
      }

      // City filter
      if (_selectedCity != null && _selectedCity!.isNotEmpty) {
        if (!job.locationCity
            .toLowerCase()
            .contains(_selectedCity!.toLowerCase())) {
          return false;
        }
      }

      // Type filter
      if (_selectedType != null && _selectedType!.isNotEmpty) {
        if (job.type != _selectedType) {
          return false;
        }
      }

      // Salary filter
      if (job.salaryMin != null && job.salaryMin! < _minSalary) {
        return false;
      }

      if (job.salaryMax != null && job.salaryMax! > _maxSalary) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildShimmerJobCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    height: 24,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 24,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final typesAsync = ref.watch(jobTypesProvider);

          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) => Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Filter Jobs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        // City filter
                        Text(
                          'City',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ref.watch(citiesProvider).when(
                              data: (cities) => DropdownButtonFormField<String>(
                                value: _selectedCity,
                                decoration: const InputDecoration(
                                  hintText: 'Select city',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('Any city'),
                                  ),
                                  ...cities.map((city) => DropdownMenuItem(
                                        value: city,
                                        child: Text(city),
                                      )),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCity = value;
                                  });
                                },
                              ),
                              loading: () => const CircularProgressIndicator(),
                              error: (error, stack) => Text('Error: $error'),
                            ),
                        const SizedBox(height: 24),

                        // Job type filter
                        Text(
                          'Job Type',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        typesAsync.when(
                          data: (types) => DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: const InputDecoration(
                              hintText: 'Select job type',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Any type'),
                              ),
                              ...types.map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value;
                              });
                            },
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) => Text('Error: $error'),
                        ),
                        const SizedBox(height: 24),

                        // Salary range
                        Text(
                          'Salary Range',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₨ ${CurrencyFormatter.compact(_minSalary)} - ₨ ${CurrencyFormatter.compact(_maxSalary)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        RangeSlider(
                          values: RangeValues(_minSalary, _maxSalary),
                          min: 0,
                          max: 500000,
                          divisions: 50,
                          labels: RangeLabels(
                            CurrencyFormatter.compact(_minSalary),
                            CurrencyFormatter.compact(_maxSalary),
                          ),
                          onChanged: (values) {
                            setState(() {
                              _minSalary = values.start;
                              _maxSalary = values.end;
                            });
                          },
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {}); // Trigger rebuild with new filters
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Clear filters
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCity = null;
                          _selectedType = null;
                          _minSalary = 0;
                          _maxSalary = 500000;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Clear Filters'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToJobDetail(String jobId) {
    context.push('/seeker/job/$jobId');
  }
}
