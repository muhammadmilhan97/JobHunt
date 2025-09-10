import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _systemDefault = 'system';
  
  Locale? _locale;
  Locale? get locale => _locale;
  
  static final List<Locale> supportedLocales = [
    const Locale('en', 'US'),
    const Locale('ur', 'PK'),
  ];
  
  static const Locale fallbackLocale = Locale('en', 'US');
  
  LocalizationService() {
    _loadSavedLanguage();
  }
  
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    
    if (savedLanguage == null || savedLanguage == _systemDefault) {
      // Use system default
      _locale = null;
    } else {
      final parts = savedLanguage.split('_');
      if (parts.length == 2) {
        _locale = Locale(parts[0], parts[1]);
      }
    }
    notifyListeners();
  }
  
  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (languageCode == _systemDefault) {
      await prefs.setString(_languageKey, _systemDefault);
      _locale = null;
    } else {
      await prefs.setString(_languageKey, languageCode);
      final parts = languageCode.split('_');
      if (parts.length == 2) {
        _locale = Locale(parts[0], parts[1]);
      }
    }
    notifyListeners();
  }
  
  Future<String> getCurrentLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? _systemDefault;
  }
  
  static String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en_US':
        return 'English';
      case 'ur_PK':
        return 'اردو';
      case _systemDefault:
        return 'System Default';
      default:
        return 'Unknown';
    }
  }
  
  static List<Map<String, String>> getLanguageOptions() {
    return [
      {'code': _systemDefault, 'name': 'System Default'},
      {'code': 'en_US', 'name': 'English'},
      {'code': 'ur_PK', 'name': 'اردو'},
    ];
  }
}
