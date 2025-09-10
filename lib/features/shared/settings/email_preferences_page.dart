import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../core/providers/user_providers.dart';
import '../../../core/providers/auth_providers.dart';
// import '../../../core/repository/user_repository.dart';
// import '../../../core/widgets/branded_app_bar.dart';
import '../../../core/services/job_alert_service.dart';

class EmailPreferencesPage extends ConsumerStatefulWidget {
  const EmailPreferencesPage({super.key});

  @override
  ConsumerState<EmailPreferencesPage> createState() =>
      _EmailPreferencesPageState();
}

class _EmailPreferencesPageState extends ConsumerState<EmailPreferencesPage> {
  bool _isLoading = false;

  Future<void> _updatePreferences({
    required bool emailNotifications,
    required bool weeklyDigest,
    required bool instantAlerts,
    required bool jobPostingNotifications,
  }) async {
    final userProfile = ref.read(currentUserProfileProvider).value;
    if (userProfile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Update using JobAlertService
      await JobAlertService.updateEmailPreferences(
        userId: userProfile.id,
        emailNotifications: emailNotifications,
        weeklyDigest: weeklyDigest,
        instantAlerts: instantAlerts,
      );

      // Update successful - preferences are handled by JobAlertService

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email preferences updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Preferences'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: userProfileAsync.when(
        data: (userProfile) {
          if (userProfile == null) {
            return const Center(
              child: Text('User not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Email Notifications',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1e293b),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your email notification preferences',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF64748b),
                      ),
                ),
                const SizedBox(height: 32),

                // Email Notifications Card
                _buildPreferenceCard(
                  context,
                  title: 'Email Notifications',
                  subtitle: 'Receive email notifications from JobHunt',
                  value: userProfile.emailNotifications,
                  onChanged: (value) => _updatePreferences(
                    emailNotifications: value,
                    weeklyDigest: userProfile.weeklyDigest,
                    instantAlerts: userProfile.instantAlerts,
                    jobPostingNotifications:
                        userProfile.jobPostingNotifications,
                  ),
                ),
                const SizedBox(height: 16),

                // Job Seeker specific preferences
                if (userProfile.role == 'job_seeker') ...[
                  _buildPreferenceCard(
                    context,
                    title: 'Job Alerts',
                    subtitle:
                        'Get notified when new jobs match your preferences',
                    value: userProfile.instantAlerts,
                    enabled: userProfile.emailNotifications,
                    onChanged: (value) => _updatePreferences(
                      emailNotifications: userProfile.emailNotifications,
                      weeklyDigest: userProfile.weeklyDigest,
                      instantAlerts: value,
                      jobPostingNotifications:
                          userProfile.jobPostingNotifications,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPreferenceCard(
                    context,
                    title: 'Weekly Job Digest',
                    subtitle: 'Receive a weekly summary of new job postings',
                    value: userProfile.weeklyDigest,
                    enabled: userProfile.emailNotifications,
                    onChanged: (value) => _updatePreferences(
                      emailNotifications: userProfile.emailNotifications,
                      weeklyDigest: value,
                      instantAlerts: userProfile.instantAlerts,
                      jobPostingNotifications:
                          userProfile.jobPostingNotifications,
                    ),
                  ),
                ],

                // Employer specific preferences
                if (userProfile.role == 'employer') ...[
                  const SizedBox(height: 16),
                  _buildPreferenceCard(
                    context,
                    title: 'Job Posting Confirmations',
                    subtitle:
                        'Get notified when your jobs are posted successfully',
                    value: userProfile.jobPostingNotifications,
                    enabled: userProfile.emailNotifications,
                    onChanged: (value) => _updatePreferences(
                      emailNotifications: userProfile.emailNotifications,
                      weeklyDigest: userProfile.weeklyDigest,
                      instantAlerts: userProfile.instantAlerts,
                      jobPostingNotifications: value,
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Information Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF0EA5E9),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'About Email Notifications',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: const Color(0xFF0C4A6E),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Job alerts are sent when new positions match your preferences\n'
                        '• Weekly digests include up to 10 relevant job postings\n'
                        '• You can unsubscribe from any email using the link at the bottom\n'
                        '• Important account notifications will always be sent',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF0C4A6E),
                              height: 1.5,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading preferences: $error'),
        ),
      ),
    );
  }

  Widget _buildPreferenceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: enabled ? const Color(0xFF1e293b) : Colors.grey[500],
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: enabled ? const Color(0xFF64748b) : Colors.grey[400],
              ),
        ),
        trailing: Switch(
          value: enabled ? value : false,
          onChanged: enabled && !_isLoading ? onChanged : null,
          activeColor: const Color(0xFF2563eb),
        ),
      ),
    );
  }
}
