import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/localization_providers.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/widgets/app_logo.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizationService = ref.watch(localizationServiceProvider);
    final accessibilityService = ref.watch(accessibilityServiceProvider);

    return Scaffold(
      appBar: BrandedAppBar(
        title: 'Settings',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/seeker/profile');
            }
          },
          tooltip: 'Back',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Section
          _buildSectionHeader(context, 'Language'),
          _buildLanguageSelector(context, ref, localizationService),

          const SizedBox(height: 24),

          // Accessibility Section
          _buildSectionHeader(context, 'Accessibility'),
          _buildAccessibilitySettings(context, ref, accessibilityService),

          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader(context, 'Notifications'),
          _buildNotificationSettings(context),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(context, 'About'),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    WidgetRef ref,
    LocalizationService localizationService,
  ) {
    return Card(
      child: Column(
        children: LocalizationService.getLanguageOptions().map((option) {
          return FutureBuilder<String>(
            future: localizationService.getCurrentLanguageCode(),
            builder: (context, snapshot) {
              final isSelected = snapshot.data == option['code'];

              return ListTile(
                title: Text(option['name']!),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  localizationService.setLanguage(option['code']!);
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAccessibilitySettings(
    BuildContext context,
    WidgetRef ref,
    dynamic accessibilityService,
  ) {
    return Card(
      child: Column(
        children: [
          // High Contrast
          SwitchListTile(
            title: const Text('High Contrast'),
            subtitle:
                const Text('Improve visibility with high contrast colors'),
            value: accessibilityService.highContrast,
            onChanged: (value) {
              accessibilityService.setHighContrast(value);
            },
          ),

          const Divider(),

          // Large Text
          SwitchListTile(
            title: const Text('Large Text'),
            subtitle: const Text('Increase text size for better readability'),
            value: accessibilityService.largeText,
            onChanged: (value) {
              accessibilityService.setLargeText(value);
            },
          ),

          const Divider(),

          // Reduce Motion
          SwitchListTile(
            title: const Text('Reduce Motion'),
            subtitle: const Text('Minimize animations and transitions'),
            value: accessibilityService.reduceMotion,
            onChanged: (value) {
              accessibilityService.setReduceMotion(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.email),
        title: const Text('Email Preferences'),
        subtitle: const Text('Manage your email notifications'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          context.push('/email-preferences');
        },
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Privacy Policy'),
            onTap: () {
              // TODO: Navigate to privacy policy
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            onTap: () {
              // TODO: Navigate to terms of service
            },
          ),
        ],
      ),
    );
  }
}
