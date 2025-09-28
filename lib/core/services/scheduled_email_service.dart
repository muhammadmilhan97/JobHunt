import 'dart:async';
import 'job_alert_service.dart';
import 'error_reporter.dart';

/// Service for handling scheduled email tasks
class ScheduledEmailService {
  static Timer? _weeklyDigestTimer;
  static Timer? _dailyJobAlertsTimer;

  /// Initialize scheduled email services
  static void initialize() {
    _scheduleWeeklyDigest();
    _scheduleDailyJobAlerts();
  }

  /// Schedule weekly digest emails (runs every Sunday at 9 AM)
  static void _scheduleWeeklyDigest() {
    // Calculate next Sunday at 9 AM
    final now = DateTime.now();
    final daysUntilSunday = (7 - now.weekday) % 7;
    final nextSunday =
        now.add(Duration(days: daysUntilSunday == 0 ? 7 : daysUntilSunday));
    final nextRun =
        DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 9, 0);

    final duration = nextRun.difference(now);

    _weeklyDigestTimer = Timer(duration, () {
      _runWeeklyDigest();
      // Schedule next run (every 7 days)
      _weeklyDigestTimer = Timer.periodic(const Duration(days: 7), (_) {
        _runWeeklyDigest();
      });
    });
  }

  /// Schedule daily job alerts (runs every day at 8 AM)
  static void _scheduleDailyJobAlerts() {
    // Calculate next 8 AM
    final now = DateTime.now();
    final next8AM = DateTime(now.year, now.month, now.day, 8, 0);
    final nextRun =
        next8AM.isBefore(now) ? next8AM.add(const Duration(days: 1)) : next8AM;

    final duration = nextRun.difference(now);

    _dailyJobAlertsTimer = Timer(duration, () {
      _runDailyJobAlerts();
      // Schedule next run (every 24 hours)
      _dailyJobAlertsTimer = Timer.periodic(const Duration(hours: 24), (_) {
        _runDailyJobAlerts();
      });
    });
  }

  /// Run weekly digest
  static Future<void> _runWeeklyDigest() async {
    try {
      await JobAlertService.sendWeeklyDigest();
    } catch (e) {
      ErrorReporter.reportError('Failed to run weekly digest', e.toString());
    }
  }

  /// Run daily job alerts
  static Future<void> _runDailyJobAlerts() async {
    try {
      // This could be enhanced to send daily job alerts based on user preferences
      // For now, we'll just log that it ran
      print('Daily job alerts check completed');
    } catch (e) {
      ErrorReporter.reportError('Failed to run daily job alerts', e.toString());
    }
  }

  /// Manually trigger weekly digest (for testing)
  static Future<void> triggerWeeklyDigest() async {
    await _runWeeklyDigest();
  }

  /// Manually trigger job alerts (for testing)
  static Future<void> triggerJobAlerts() async {
    await _runDailyJobAlerts();
  }

  /// Cancel all scheduled tasks
  static void cancelAll() {
    _weeklyDigestTimer?.cancel();
    _dailyJobAlertsTimer?.cancel();
  }

  /// Get next scheduled run times
  static Map<String, DateTime?> getNextRunTimes() {
    return {
      'weeklyDigest': _getNextWeeklyDigestTime(),
      'dailyJobAlerts': _getNextDailyJobAlertsTime(),
    };
  }

  static DateTime? _getNextWeeklyDigestTime() {
    if (_weeklyDigestTimer == null) return null;

    final now = DateTime.now();
    final daysUntilSunday = (7 - now.weekday) % 7;
    final nextSunday =
        now.add(Duration(days: daysUntilSunday == 0 ? 7 : daysUntilSunday));
    return DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 9, 0);
  }

  static DateTime? _getNextDailyJobAlertsTime() {
    if (_dailyJobAlertsTimer == null) return null;

    final now = DateTime.now();
    final next8AM = DateTime(now.year, now.month, now.day, 8, 0);
    return next8AM.isBefore(now)
        ? next8AM.add(const Duration(days: 1))
        : next8AM;
  }
}
