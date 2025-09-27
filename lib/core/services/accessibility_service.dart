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
      // Create new text theme with increased font sizes instead of using fontSizeFactor
      final baseTextTheme = baseTheme.textTheme;
      baseTheme = baseTheme.copyWith(
        textTheme: TextTheme(
          displayLarge: baseTextTheme.displayLarge?.copyWith(
              fontSize: (baseTextTheme.displayLarge?.fontSize ?? 32) * 1.2),
          displayMedium: baseTextTheme.displayMedium?.copyWith(
              fontSize: (baseTextTheme.displayMedium?.fontSize ?? 28) * 1.2),
          displaySmall: baseTextTheme.displaySmall?.copyWith(
              fontSize: (baseTextTheme.displaySmall?.fontSize ?? 24) * 1.2),
          headlineLarge: baseTextTheme.headlineLarge?.copyWith(
              fontSize: (baseTextTheme.headlineLarge?.fontSize ?? 22) * 1.2),
          headlineMedium: baseTextTheme.headlineMedium?.copyWith(
              fontSize: (baseTextTheme.headlineMedium?.fontSize ?? 20) * 1.2),
          headlineSmall: baseTextTheme.headlineSmall?.copyWith(
              fontSize: (baseTextTheme.headlineSmall?.fontSize ?? 18) * 1.2),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
              fontSize: (baseTextTheme.titleLarge?.fontSize ?? 16) * 1.2),
          titleMedium: baseTextTheme.titleMedium?.copyWith(
              fontSize: (baseTextTheme.titleMedium?.fontSize ?? 14) * 1.2),
          titleSmall: baseTextTheme.titleSmall?.copyWith(
              fontSize: (baseTextTheme.titleSmall?.fontSize ?? 12) * 1.2),
          bodyLarge: baseTextTheme.bodyLarge?.copyWith(
              fontSize: (baseTextTheme.bodyLarge?.fontSize ?? 16) * 1.2),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(
              fontSize: (baseTextTheme.bodyMedium?.fontSize ?? 14) * 1.2),
          bodySmall: baseTextTheme.bodySmall?.copyWith(
              fontSize: (baseTextTheme.bodySmall?.fontSize ?? 12) * 1.2),
          labelLarge: baseTextTheme.labelLarge?.copyWith(
              fontSize: (baseTextTheme.labelLarge?.fontSize ?? 14) * 1.2),
          labelMedium: baseTextTheme.labelMedium?.copyWith(
              fontSize: (baseTextTheme.labelMedium?.fontSize ?? 12) * 1.2),
          labelSmall: baseTextTheme.labelSmall?.copyWith(
              fontSize: (baseTextTheme.labelSmall?.fontSize ?? 10) * 1.2),
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
