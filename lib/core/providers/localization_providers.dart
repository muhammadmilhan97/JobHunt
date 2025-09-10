import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/localization_service.dart';
import '../services/accessibility_service.dart';

// Localization service provider
final localizationServiceProvider = ChangeNotifierProvider<LocalizationService>((ref) {
  return LocalizationService();
});

// Accessibility service provider
final accessibilityServiceProvider = ChangeNotifierProvider<AccessibilityService>((ref) {
  return AccessibilityService();
});

// Current locale provider
final currentLocaleProvider = Provider<Locale?>((ref) {
  final localizationService = ref.watch(localizationServiceProvider);
  return localizationService.locale;
});

// High contrast mode provider
final highContrastProvider = Provider<bool>((ref) {
  final accessibilityService = ref.watch(accessibilityServiceProvider);
  return accessibilityService.highContrast;
});

// Large text mode provider
final largeTextProvider = Provider<bool>((ref) {
  final accessibilityService = ref.watch(accessibilityServiceProvider);
  return accessibilityService.largeText;
});

// Reduce motion provider
final reduceMotionProvider = Provider<bool>((ref) {
  final accessibilityService = ref.watch(accessibilityServiceProvider);
  return accessibilityService.reduceMotion;
});
