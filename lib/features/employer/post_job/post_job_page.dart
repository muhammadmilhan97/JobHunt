import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/user_providers.dart';
import '../../../core/models/models.dart';
import '../../../widgets/tag_input.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/services/auth_service.dart';

// Post Job Form State
class PostJobFormState {
  final String title;
  final String category;
  final String description;
  final int? salaryMin;
  final int? salaryMax;
  final String city;
  final String country;
  final String type;
  final List<String> requirements;
  final List<String> skills;
  final String logoUrl;
  final bool isSubmitting;

  const PostJobFormState({
    this.title = '',
    this.category = '',
    this.description = '',
    this.salaryMin,
    this.salaryMax,
    this.city = '',
    this.country = '',
    this.type = '',
    this.requirements = const [],
    this.skills = const [],
    this.logoUrl = '',
    this.isSubmitting = false,
  });

  PostJobFormState copyWith({
    String? title,
    String? category,
    String? description,
    int? salaryMin,
    int? salaryMax,
    String? city,
    String? country,
    String? type,
    List<String>? requirements,
    List<String>? skills,
    String? logoUrl,
    bool? isSubmitting,
  }) {
    return PostJobFormState(
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      city: city ?? this.city,
      country: country ?? this.country,
      type: type ?? this.type,
      requirements: requirements ?? this.requirements,
      skills: skills ?? this.skills,
      logoUrl: logoUrl ?? this.logoUrl,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

// Post Job Form Controller
class PostJobFormController extends StateNotifier<PostJobFormState> {
  PostJobFormController() : super(const PostJobFormState());

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateCategory(String category) {
    state = state.copyWith(category: category);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateSalaryMin(int? salaryMin) {
    state = state.copyWith(salaryMin: salaryMin);
  }

  void updateSalaryMax(int? salaryMax) {
    state = state.copyWith(salaryMax: salaryMax);
  }

  void updateCity(String city) {
    state = state.copyWith(city: city);
  }

  void updateCountry(String country) {
    state = state.copyWith(country: country);
  }

  void updateType(String type) {
    state = state.copyWith(type: type);
  }

  void updateRequirements(List<String> requirements) {
    state = state.copyWith(requirements: requirements);
  }

  void updateSkills(List<String> skills) {
    state = state.copyWith(skills: skills);
  }

  void updateLogoUrl(String logoUrl) {
    state = state.copyWith(logoUrl: logoUrl);
  }

  void setSubmitting(bool isSubmitting) {
    state = state.copyWith(isSubmitting: isSubmitting);
  }

  void reset() {
    state = const PostJobFormState();
  }

  bool validate() {
    return state.title.isNotEmpty &&
        state.category.isNotEmpty &&
        state.description.isNotEmpty &&
        state.city.isNotEmpty &&
        state.country.isNotEmpty &&
        state.type.isNotEmpty &&
        state.requirements.isNotEmpty &&
        state.skills.isNotEmpty;
  }
}

// Provider
final postJobFormProvider =
    StateNotifierProvider<PostJobFormController, PostJobFormState>(
  (ref) => PostJobFormController(),
);

class PostJobPage extends ConsumerStatefulWidget {
  final String? jobId; // if provided, page acts in edit mode
  const PostJobPage({super.key, this.jobId});

  @override
  ConsumerState<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends ConsumerState<PostJobPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final List<String> _categories = [
    'IT',
    'Development',
    'Marketing',
    'SEO',
    'Education',
    'Freelance',
    'Design',
    'Sales',
    'Customer Service',
    'Finance',
  ];

  final List<String> _jobTypes = [
    'Full-time',
    'Part-time',
    'Freelance',
    'Contract',
    'Internship',
  ];

  final List<String> _countries = [
    'Pakistan',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
    'Remote',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.jobId != null) {
      _loadJob(widget.jobId!);
    }
  }

  Future<void> _loadJob(String id) async {
    final repo = ref.read(jobRepositoryProvider);
    final form = ref.read(postJobFormProvider.notifier);
    final result = await repo.getJobById(id);

    result.when(
      success: (job) {
        if (job != null) {
          form
            ..updateTitle(job.title)
            ..updateCategory(job.category)
            ..updateDescription(job.description)
            ..updateSalaryMin(job.salaryMin)
            ..updateSalaryMax(job.salaryMax)
            ..updateCity(job.locationCity)
            ..updateCountry(job.locationCountry)
            ..updateType(job.type)
            ..updateLogoUrl(job.logoUrl ?? '')
            ..updateRequirements(job.requirements)
            ..updateSkills(job.skills);
        }
      },
      failure: (message, error) {
        // Handle error - could show a snackbar
        print('Failed to load job: $message');
      },
      loading: () {
        // Handle loading state
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(postJobFormProvider);
    // final jobRepository = ref.read(jobRepositoryProvider);

    return Scaffold(
      appBar: BrandedAppBar(
        title: widget.jobId == null ? 'Post a Job' : 'Edit Job',
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: formState.isSubmitting ? null : () => _saveAsDraft(),
            child: const Text('Save Draft'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildJobInformationSection(),
                    const SizedBox(height: 24),
                    _buildDescriptionSection(),
                    const SizedBox(height: 24),
                    _buildLocationSection(),
                    const SizedBox(height: 24),
                    _buildRequirementsSection(),
                    const SizedBox(height: 24),
                    _buildSkillsSection(),
                    const SizedBox(height: 24),
                    _buildAdditionalInfoSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        formState.isSubmitting ? null : () => _submitJob(),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: formState.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.jobId == null ? 'Publish Job' : 'Update Job',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobInformationSection() {
    final formState = ref.watch(postJobFormProvider);
    final formController = ref.read(postJobFormProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: formState.title,
              decoration: const InputDecoration(
                labelText: 'Job Title *',
                hintText: 'e.g., Senior Flutter Developer',
              ),
              onChanged: formController.updateTitle,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a job title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: formState.category.isEmpty ? null : formState.category,
              decoration: const InputDecoration(
                labelText: 'Category *',
              ),
              isExpanded: true,
              items: _categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) formController.updateCategory(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: formState.type.isEmpty ? null : formState.type,
              decoration: const InputDecoration(
                labelText: 'Job Type *',
              ),
              isExpanded: true,
              items: _jobTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) formController.updateType(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a job type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: formState.salaryMin?.toString() ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Min Salary',
                      prefixText: 'PKR ',
                      hintText: '50000',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final salary = int.tryParse(value);
                      formController.updateSalaryMin(salary);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: formState.salaryMax?.toString() ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Max Salary',
                      prefixText: 'PKR ',
                      hintText: '100000',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final salary = int.tryParse(value);
                      formController.updateSalaryMax(salary);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    final formState = ref.watch(postJobFormProvider);
    final formController = ref.read(postJobFormProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Description',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: formState.description,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText:
                    'Describe the role, responsibilities, and what you\'re looking for...',
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              onChanged: formController.updateDescription,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a job description';
                }
                if (value.trim().length < 50) {
                  return 'Please provide at least 50 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    final formState = ref.watch(postJobFormProvider);
    final formController = ref.read(postJobFormProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: formState.city,
                    decoration: const InputDecoration(
                      labelText: 'City *',
                      hintText: 'e.g., Karachi',
                    ),
                    onChanged: formController.updateCity,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a city';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: formState.country.isEmpty ? null : formState.country,
                    decoration: const InputDecoration(
                      labelText: 'Country *',
                    ),
                    isExpanded: true,
                    items: _countries
                        .map((country) => DropdownMenuItem(
                              value: country,
                              child: Text(country),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) formController.updateCountry(value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a country';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementsSection() {
    final formState = ref.watch(postJobFormProvider);
    final formController = ref.read(postJobFormProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Requirements',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add the key requirements for this position',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            TagInput(
              tags: formState.requirements,
              hintText: 'Add requirement and press Enter...',
              onChanged: formController.updateRequirements,
              validator: (tag) {
                if (tag.length < 3) {
                  return 'Requirement must be at least 3 characters';
                }
                return null;
              },
            ),
            if (formState.requirements.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Please add at least one requirement',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    final formState = ref.watch(postJobFormProvider);
    final formController = ref.read(postJobFormProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Required Skills',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'List the technical and soft skills needed for this role',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            TagInput(
              tags: formState.skills,
              hintText: 'Add skill and press Enter...',
              onChanged: formController.updateSkills,
              validator: (tag) {
                if (tag.length < 2) {
                  return 'Skill must be at least 2 characters';
                }
                return null;
              },
            ),
            if (formState.skills.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Please add at least one skill',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    final formState = ref.watch(postJobFormProvider);
    final formController = ref.read(postJobFormProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: formState.logoUrl,
              decoration: const InputDecoration(
                labelText: 'Company Logo URL (Optional)',
                hintText: 'https://example.com/logo.png',
              ),
              onChanged: formController.updateLogoUrl,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasAbsolutePath) {
                    return 'Please enter a valid URL';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveAsDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Job saved as draft!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final formState = ref.read(postJobFormProvider);
    final formController = ref.read(postJobFormProvider.notifier);
    final jobRepository = ref.read(jobRepositoryProvider);

    if (!formController.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    formController.setSubmitting(true);

    try {
      final employerId = AuthService.currentUserId;
      if (employerId == null) {
        throw Exception('User not authenticated');
      }

      // Get company name from user profile
      final userProfile =
          await ref.read(userRepositoryProvider).getUserById(employerId);
      final companyName = userProfile?.companyName ?? 'Company Name';

      final job = Job(
        id: widget.jobId ?? 'job_${DateTime.now().millisecondsSinceEpoch}',
        title: formState.title,
        company: companyName,
        category: formState.category,
        locationCity: formState.city,
        locationCountry: formState.country,
        salaryMin: formState.salaryMin,
        salaryMax: formState.salaryMax,
        type: formState.type,
        logoUrl: formState.logoUrl.isEmpty ? null : formState.logoUrl,
        description: formState.description,
        requirements: formState.requirements,
        skills: formState.skills,
        createdAt: DateTime.now(),
        employerId: employerId,
        isActive: true,
      );

      if (widget.jobId == null) {
        print('Creating job with employerId: $employerId');
        print('Job data: ${job.toFirestore()}');
        final result = await jobRepository.createJob(job);
        result.when(
          success: (jobId) {
            print('Job created successfully with ID: $jobId');
          },
          failure: (message, error) {
            print('Job creation failed: $message');
            throw Exception(message);
          },
          loading: () {
            // This shouldn't happen for a Future
          },
        );
      } else {
        final result =
            await jobRepository.updateJob(widget.jobId!, job.toFirestore());
        result.when(
          success: (_) {
            // Job updated successfully
          },
          failure: (message, error) {
            throw Exception(message);
          },
          loading: () {
            // This shouldn't happen for a Future
          },
        );
      }

      if (mounted) {
        formController.reset();

        // Invalidate providers to refresh data
        if (widget.jobId == null) {
          // New job created - refresh jobs list
          ref.invalidate(jobsByEmployerProvider(employerId));
        } else {
          // Job updated - refresh specific job
          ref.invalidate(jobsByEmployerProvider(employerId));
        }

        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(widget.jobId == null
                      ? 'Job "${job.title}" posted successfully!'
                      : 'Job updated successfully!'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save job: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      formController.setSubmitting(false);
    }
  }
}
