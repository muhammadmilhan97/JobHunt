import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_settings_service.dart';

final adminSettingsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await AdminSettingsService.fetchSettings();
});

final adminSettingsNotifierProvider = Provider<AdminSettingsNotifier>((ref) {
  return AdminSettingsNotifier();
});

class AdminSettingsNotifier {
  Future<void> save(Map<String, dynamic> updates) async {
    await AdminSettingsService.updateSettings(updates);
  }
}


