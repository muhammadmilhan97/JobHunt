import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/localization_providers.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/utils/back_button_handler.dart';
import '../../../l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizationService = ref.watch(localizationServiceProvider);
    final accessibilityService = ref.watch(accessibilityServiceProvider);
    final l10n = AppLocalizations.of(context)!;

    return BackButtonHandler.createPopScope(
      context: context,
      child: Scaffold(
        appBar: BrandedAppBar(
          title: l10n.settings,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            tooltip: l10n.back,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Language Section
            _buildSectionHeader(context, l10n.language),
            _buildLanguageSelector(context, ref, localizationService),

            const SizedBox(height: 24),

            // Accessibility Section
            _buildSectionHeader(context, l10n.accessibility),
            _buildAccessibilitySettings(context, ref, accessibilityService),

            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader(context, l10n.notifications),
            _buildNotificationSettings(context),

            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader(context, 'About'),
            _buildAboutSection(context),
          ],
        ),
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
                onTap: () async {
                  await localizationService.setLanguage(option['code']!);
                  // Force rebuild to show updated selection
                  if (context.mounted) {
                    ref.invalidate(localizationServiceProvider);
                  }
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
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Column(
        children: [
          // High Contrast
          SwitchListTile(
            title: Text(l10n.highContrast),
            subtitle:
                const Text('Improve visibility with high contrast colors'),
            value: accessibilityService.highContrast,
            onChanged: (value) async {
              await accessibilityService.setHighContrast(value);
              // Force rebuild to apply theme changes
              if (context.mounted) {
                ref.invalidate(accessibilityServiceProvider);
              }
            },
          ),

          const Divider(),

          // Large Text
          SwitchListTile(
            title: Text(l10n.largeText),
            subtitle: const Text('Increase text size for better readability'),
            value: accessibilityService.largeText,
            onChanged: (value) async {
              await accessibilityService.setLargeText(value);
              // Force rebuild to apply theme changes
              if (context.mounted) {
                ref.invalidate(accessibilityServiceProvider);
              }
            },
          ),

          const Divider(),

          // Reduce Motion
          SwitchListTile(
            title: Text(l10n.reduceMotion),
            subtitle: const Text('Minimize animations and transitions'),
            value: accessibilityService.reduceMotion,
            onChanged: (value) async {
              await accessibilityService.setReduceMotion(value);
              // Force rebuild to apply theme changes
              if (context.mounted) {
                ref.invalidate(accessibilityServiceProvider);
              }
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
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.push('/privacy-policy');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.push('/terms-of-service');
            },
          ),
        ],
      ),
    );
  }
}
