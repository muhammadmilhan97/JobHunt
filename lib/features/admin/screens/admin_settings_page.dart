import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/admin_settings_provider.dart';
import '../../../core/widgets/app_logo.dart';

class AdminSettingsPage extends ConsumerStatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  ConsumerState<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends ConsumerState<AdminSettingsPage> {
  bool _emailEnabled = true;
  bool _welcomeEmails = true;
  bool _logsEnabled = true;
  bool _maintenanceMode = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(adminSettingsProvider);
    final saver = ref.read(adminSettingsNotifierProvider);

    return Scaffold(
      appBar: const BrandedAppBar(title: 'Admin Settings'),
      body: settingsAsync.when(
        data: (settings) {
          _emailEnabled = (settings['emailEnabled'] as bool?) ?? _emailEnabled;
          _welcomeEmails =
              (settings['enableWelcomeEmails'] as bool?) ?? _welcomeEmails;
          _logsEnabled = (settings['logsEnabled'] as bool?) ?? _logsEnabled;
          _maintenanceMode =
              (settings['maintenanceMode'] as bool?) ?? _maintenanceMode;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: const Text('Email Sending Enabled'),
                subtitle: const Text('Turn off to disable all emails globally'),
                value: _emailEnabled,
                onChanged: (v) => setState(() => _emailEnabled = v),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Welcome Emails'),
                subtitle: const Text('Send welcome emails on approval'),
                value: _welcomeEmails,
                onChanged: (v) => setState(() => _welcomeEmails = v),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Store System Logs'),
                subtitle: const Text('Enable Firestore log collection'),
                value: _logsEnabled,
                onChanged: (v) => setState(() => _logsEnabled = v),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Maintenance Mode'),
                subtitle:
                    const Text('Show maintenance banner and restrict actions'),
                value: _maintenanceMode,
                onChanged: (v) => setState(() => _maintenanceMode = v),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          setState(() => _saving = true);
                          await saver.save({
                            'emailEnabled': _emailEnabled,
                            'enableWelcomeEmails': _welcomeEmails,
                            'logsEnabled': _logsEnabled,
                            'maintenanceMode': _maintenanceMode,
                            'updatedAt': DateTime.now().toIso8601String(),
                          });
                          if (!mounted) return;
                          setState(() => _saving = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Settings saved')),
                          );
                        },
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
