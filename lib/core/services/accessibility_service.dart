import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityService extends ChangeNotifier {
  static const String _highContrastKey = 'high_contrast';
  static const String _largeTextKey = 'large_text';
  static const String _reduceMotionKey = 'reduce_motion';
  
  bool _highContrast = false;
  bool _largeText = false;
  bool _reduceMotion = false;
  
  bool get highContrast => _highContrast;
  bool get largeText => _largeText;
  bool get reduceMotion => _reduceMotion;
  
  AccessibilityService() {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _highContrast = prefs.getBool(_highContrastKey) ?? false;
    _largeText = prefs.getBool(_largeTextKey) ?? false;
    _reduceMotion = prefs.getBool(_reduceMotionKey) ?? false;
    notifyListeners();
  }
  
  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highContrastKey, value);
    notifyListeners();
  }
  
  Future<void> setLargeText(bool value) async {
    _largeText = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_largeTextKey, value);
    notifyListeners();
  }
  
  Future<void> setReduceMotion(bool value) async {
    _reduceMotion = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reduceMotionKey, value);
    notifyListeners();
  }
  
  // Get theme data with accessibility settings applied
  ThemeData applyAccessibilitySettings(ThemeData baseTheme) {
    if (_highContrast) {
      baseTheme = baseTheme.copyWith(
        brightness: Brightness.light,
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: Colors.black,
          secondary: Colors.black,
          surface: Colors.white,
          background: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black,
          onBackground: Colors.black,
        ),
      );
    }
    
    if (_largeText) {
      baseTheme = baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(
          fontSizeFactor: 1.2,
        ),
      );
    }
    
    return baseTheme;
  }
  
  // Get animation duration considering reduce motion setting
  Duration getAnimationDuration(Duration defaultDuration) {
    if (_reduceMotion) {
      return Duration.zero;
    }
    return defaultDuration;
  }
  
  // Get curve considering reduce motion setting
  Curve getAnimationCurve(Curve defaultCurve) {
    if (_reduceMotion) {
      return Curves.linear;
    }
    return defaultCurve;
  }
}
