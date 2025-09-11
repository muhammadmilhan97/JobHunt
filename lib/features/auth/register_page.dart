import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_providers.dart';
import '../../core/providers/notification_providers.dart';
import '../../core/providers/role_providers.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/services/auth_service.dart'; // Added import for AuthService
import '../../core/services/firebase_service.dart'; // Added import for FirebaseService
import 'package:cloud_firestore/cloud_firestore.dart'; // Added import for FieldValue

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Common fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Job Seeker fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();
  final _expectedSalaryController = TextEditingController();

  // Employer fields
  final _employerFirstNameController = TextEditingController();
  final _employerLastNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _contactNumberController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    // Dispose common controllers
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    // Dispose job seeker controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cnicController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _expectedSalaryController.dispose();

    // Dispose employer controllers
    _employerFirstNameController.dispose();
    _employerLastNameController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _contactNumberController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final intendedRole = ref.watch(intendedRoleProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: const BrandedAppBar(
        title: 'Create Account',
        centerTitle: true,
        elevation: 0,
        showLogo: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // App logo
                const Center(child: AppLogo.large()),
                const SizedBox(height: 28),

                // Role selection reminder banner
                if (intendedRole == null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Please select your role first',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/role'),
                          child: Text(
                            'Select Role',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Welcome message with role
                if (intendedRole != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: _getRoleColor(intendedRole).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _getRoleColor(intendedRole).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(_getRoleIcon(intendedRole),
                            color: _getRoleColor(intendedRole), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Creating account as ${_getRoleDisplayName(intendedRole)}',
                            style: TextStyle(
                              color: _getRoleColor(intendedRole),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/role'),
                          child: Text(
                            'Change',
                            style: TextStyle(
                              color: _getRoleColor(intendedRole),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Welcome text
                Text(
                  'Join Our Platform',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  'Create your account to start your journey',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Role-specific form
                if (intendedRole == 'job_seeker')
                  _buildJobSeekerForm()
                else if (intendedRole == 'employer')
                  _buildEmployerForm()
                else if (intendedRole == 'admin')
                  _buildAdminMessage()
                else
                  const SizedBox.shrink(),

                const SizedBox(height: 32),

                // Sign up button
                if (intendedRole != null && intendedRole != 'admin')
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/auth'),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobSeekerForm() {
    return Column(
      children: [
        // First Name field
        TextFormField(
          controller: _firstNameController,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            labelText: 'First Name',
            hintText: 'Enter your first name',
            prefixIcon: const Icon(Icons.person_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your first name';
            }
            if (value.trim().length < 2) {
              return 'First name must be at least 2 characters';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Last Name field
        TextFormField(
          controller: _lastNameController,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            labelText: 'Last Name',
            hintText: 'Enter your last name',
            prefixIcon: const Icon(Icons.person_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your last name';
            }
            if (value.trim().length < 2) {
              return 'Last name must be at least 2 characters';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // CNIC field
        TextFormField(
          controller: _cnicController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'CNIC',
            hintText: 'Enter your CNIC (e.g., 12345-1234567-1)',
            prefixIcon: const Icon(Icons.credit_card_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your CNIC';
            }
            // Basic CNIC format validation
            if (!RegExp(r'^\d{5}-\d{7}-\d$').hasMatch(value.trim())) {
              return 'Please enter CNIC in format: 12345-1234567-1';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // City field
        TextFormField(
          controller: _cityController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'City',
            hintText: 'Enter your city',
            prefixIcon: const Icon(Icons.location_city_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your city';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Country field
        TextFormField(
          controller: _countryController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'Country',
            hintText: 'Enter your country',
            prefixIcon: const Icon(Icons.public_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your country';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Address field
        TextFormField(
          controller: _addressController,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Address',
            hintText: 'Enter your complete address',
            prefixIcon: const Icon(Icons.home_outlined),
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Experience field
        TextFormField(
          controller: _experienceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Experience (Years)',
            hintText: 'Enter years of experience',
            prefixIcon: const Icon(Icons.work_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your experience';
            }
            final experience = int.tryParse(value);
            if (experience == null || experience < 0) {
              return 'Please enter a valid experience';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Expected Salary field
        TextFormField(
          controller: _expectedSalaryController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Expected Salary (PKR)',
            hintText: 'Enter expected salary',
            prefixIcon: const Icon(Icons.attach_money_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your expected salary';
            }
            final salary = int.tryParse(value);
            if (salary == null || salary < 0) {
              return 'Please enter a valid salary';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Email field
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'Enter your email',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Password field
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
              return 'Password must contain uppercase, lowercase, and number';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Confirm Password field
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            hintText: 'Confirm your password',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmployerForm() {
    return Column(
      children: [
        // First Name field
        TextFormField(
          controller: _employerFirstNameController,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            labelText: 'First Name',
            hintText: 'Enter your first name',
            prefixIcon: const Icon(Icons.person_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your first name';
            }
            if (value.trim().length < 2) {
              return 'First name must be at least 2 characters';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Last Name field
        TextFormField(
          controller: _employerLastNameController,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            labelText: 'Last Name',
            hintText: 'Enter your last name',
            prefixIcon: const Icon(Icons.person_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your last name';
            }
            if (value.trim().length < 2) {
              return 'Last name must be at least 2 characters';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Company Name field
        TextFormField(
          controller: _companyNameController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'Company Name',
            hintText: 'Enter your company name',
            prefixIcon: const Icon(Icons.business_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your company name';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Company Address field
        TextFormField(
          controller: _companyAddressController,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Company Address',
            hintText: 'Enter your company address',
            prefixIcon: const Icon(Icons.location_on_outlined),
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your company address';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Contact Number field
        TextFormField(
          controller: _contactNumberController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Contact Number',
            hintText: 'Enter your contact number',
            prefixIcon: const Icon(Icons.phone_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your contact number';
            }
            if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
              return 'Please enter a valid contact number';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Email field
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'Enter your email',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Password field
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
              return 'Password must contain uppercase, lowercase, and number';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Confirm Password field
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            hintText: 'Confirm your password',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAdminMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            size: 64,
            color: Colors.purple.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'Admin Access Required',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Admin accounts are not available for public registration. Please contact us for admin access.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Column(
              children: [
                Text(
                  'Contact Email:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.shade700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'jobhuntapplication@gmail.com',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.go('/auth'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final intendedRole = ref.read(intendedRoleProvider);
    if (intendedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role first')),
      );
      return;
    }

    if (intendedRole == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin registration is not available')),
      );
      return;
    }

    print('Starting registration for role: $intendedRole');
    final authNotifier = ref.read(authNotifierProvider.notifier);

    try {
      print('Creating user account...');
      await authNotifier.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: intendedRole == 'job_seeker'
            ? '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
            : '${_employerFirstNameController.text.trim()} ${_employerLastNameController.text.trim()}',
        role: intendedRole,
      );

      final authState = ref.read(authNotifierProvider);
      print(
          'Auth state - Error: ${authState.error}, Success: ${authState.isSuccess}');

      if (authState.error != null) {
        if (mounted) {
          String errorMessage = authState.error!;
          if (errorMessage.contains('already exists')) {
            errorMessage =
                'An account with this email already exists. Please try signing in instead.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              action: SnackBarAction(
                label: 'Sign In',
                onPressed: () => context.go('/auth'),
              ),
            ),
          );
        }
        return;
      }

      if (authState.isSuccess) {
        print('User account created successfully, updating profile...');
        // After successful account creation, update the user profile with role-specific data
        try {
          if (intendedRole == 'job_seeker') {
            print('Updating job seeker profile...');
            await FirebaseService.firestore
                .collection('users')
                .doc(AuthService.currentUserId)
                .update({
              'firstName': _firstNameController.text.trim(),
              'lastName': _lastNameController.text.trim(),
              'cnic': _cnicController.text.trim(),
              'city': _cityController.text.trim(),
              'country': _countryController.text.trim(),
              'address': _addressController.text.trim(),
              'experienceYears':
                  int.tryParse(_experienceController.text.trim()) ?? 0,
              'expectedSalary':
                  int.tryParse(_expectedSalaryController.text.trim()) ?? 0,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            print('Job seeker profile updated successfully');
          } else if (intendedRole == 'employer') {
            print('Updating employer profile...');
            await FirebaseService.firestore
                .collection('users')
                .doc(AuthService.currentUserId)
                .update({
              'firstName': _employerFirstNameController.text.trim(),
              'lastName': _employerLastNameController.text.trim(),
              'companyName': _companyNameController.text.trim(),
              'companyAddress': _companyAddressController.text.trim(),
              'contactNumber': _contactNumberController.text.trim(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
            print('Employer profile updated successfully');
          }
        } catch (e) {
          print('Error updating user profile: $e');
          // Don't fail the registration if profile update fails
          // The user can update their profile later
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully!')),
          );
          print('Requesting notification permission...');
          final notificationNotifier =
              ref.read(notificationNotifierProvider.notifier);
          notificationNotifier.requestPermission();

          final currentUserProfile = ref.read(currentUserProfileProvider).value;
          print('Current user profile role: ${currentUserProfile?.role}');

          if (intendedRole != null && currentUserProfile?.role == null) {
            try {
              print('Updating user role to: $intendedRole');
              await authNotifier.updateUserRole(intendedRole);
              ref.read(intendedRoleProvider.notifier).state = null;
              print('User role updated successfully');
            } catch (e) {
              print('Error updating user role: $e');
              // Don't fail the registration if role update fails
            }
          }

          // After successful registration, user should be signed out and redirected to pending approval
          print('Registration successful! User will be signed out for admin approval.');
          
          // Sign out the user since they need approval
          await authNotifier.signOut();
          
          if (mounted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Account created! Pending admin approval.'),
                    ),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
            
            // Navigate to pending approval screen
            context.go('/auth/pending-approval?message=${Uri.encodeComponent('Your account has been created and is pending admin approval. You will receive an email notification once your account is reviewed.')}');
          }
        }
      }
    } catch (e) {
      print('Registration error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    }
  }

  // Helper methods for role display
  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'job_seeker':
        return Icons.person_outline;
      case 'employer':
        return Icons.business_center_outlined;
      case 'admin':
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'job_seeker':
        return Colors.blue;
      case 'employer':
        return Colors.green;
      case 'admin':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'job_seeker':
        return 'Job Seeker';
      case 'employer':
        return 'Employer';
      case 'admin':
        return 'Admin';
      default:
        return 'User';
    }
  }
}
