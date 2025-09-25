import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'error_reporter.dart';

/// Service for handling 4-digit PIN authentication
class PinService {
  static const String _pinKey = 'user_pin_hash';
  static const String _pinSetKey = 'pin_is_set';
  static const String _pinAttemptsKey = 'pin_attempts';
  static const String _pinSessionVerifiedKey = 'pin_session_verified';
  static const int _maxAttempts = 5;

  /// Check if PIN is set for current user
  static Future<bool> isPinSet() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      final prefs = await SharedPreferences.getInstance();
      final userPinKey = '${_pinSetKey}_${currentUser.uid}';
      final localSet = prefs.getBool(userPinKey);
      if (localSet == true) return true;

      // Fallback to Firestore flag
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final fsSet = (doc.data()?['pinSet'] as bool?) ?? false;
      if (fsSet) {
        // sync local flag for faster subsequent checks
        await prefs.setBool(userPinKey, true);
      }
      return fsSet;
    } catch (e) {
      ErrorReporter.reportError('Failed to check PIN status', e.toString());
      return false;
    }
  }

  /// Set PIN for current user
  static Future<bool> setPin(String pin) async {
    try {
      if (!_isValidPin(pin)) {
        throw Exception('PIN must be exactly 4 digits');
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final prefs = await SharedPreferences.getInstance();
      final hashedPin = _hashPin(pin, currentUser.uid);

      final userPinKey = '${_pinKey}_${currentUser.uid}';
      final userPinSetKey = '${_pinSetKey}_${currentUser.uid}';

      await prefs.setString(userPinKey, hashedPin);
      await prefs.setBool(userPinSetKey, true);

      // Persist in Firestore (flag + hashed pin)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({
        'pinSet': true,
        'pinHash': hashedPin,
        'pinUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Reset attempts when PIN is set
      await _resetAttempts();

      return true;
    } catch (e) {
      ErrorReporter.reportError('Failed to set PIN', e.toString());
      return false;
    }
  }

  /// Verify PIN for current user
  static Future<bool> verifyPin(String pin) async {
    try {
      if (!_isValidPin(pin)) {
        return false;
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final prefs = await SharedPreferences.getInstance();
      final userPinKey = '${_pinKey}_${currentUser.uid}';
      String? storedHash = prefs.getString(userPinKey);

      if (storedHash == null) {
        // Fallback to Firestore hash
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        storedHash = doc.data()?['pinHash'] as String?;
        if (storedHash == null) {
          return false;
        }
      }

      final inputHash = _hashPin(pin, currentUser.uid);
      final isValid = storedHash == inputHash;

      if (isValid) {
        await _resetAttempts();
        await _setSessionVerified(true);
        // Cache hash locally for next time if it came from Firestore
        await prefs.setString(userPinKey, storedHash);
      } else {
        await _incrementAttempts();
      }

      return isValid;
    } catch (e) {
      ErrorReporter.reportError('Failed to verify PIN', e.toString());
      return false;
    }
  }

  /// Change PIN for current user
  static Future<bool> changePin(String oldPin, String newPin) async {
    try {
      final isOldPinValid = await verifyPin(oldPin);
      if (!isOldPinValid) {
        return false;
      }

      return await setPin(newPin);
    } catch (e) {
      ErrorReporter.reportError('Failed to change PIN', e.toString());
      return false;
    }
  }

  /// Reset PIN (requires re-authentication)
  static Future<bool> resetPin() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final prefs = await SharedPreferences.getInstance();
      final userPinKey = '${_pinKey}_${currentUser.uid}';
      final userPinSetKey = '${_pinSetKey}_${currentUser.uid}';

      await prefs.remove(userPinKey);
      await prefs.setBool(userPinSetKey, false);
      await _resetAttempts();
      await _setSessionVerified(false);

      // Clear Firestore fields
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({
        'pinSet': false,
        'pinHash': FieldValue.delete(),
        'pinUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      ErrorReporter.reportError('Failed to reset PIN', e.toString());
      return false;
    }
  }

  /// Get remaining PIN attempts
  static Future<int> getRemainingAttempts() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return _maxAttempts;

      final prefs = await SharedPreferences.getInstance();
      final userAttemptsKey = '${_pinAttemptsKey}_${currentUser.uid}';
      final attempts = prefs.getInt(userAttemptsKey) ?? 0;

      return (_maxAttempts - attempts).clamp(0, _maxAttempts);
    } catch (e) {
      return _maxAttempts;
    }
  }

  /// Check if PIN attempts are exhausted
  static Future<bool> areAttemptsExhausted() async {
    final remaining = await getRemainingAttempts();
    return remaining <= 0;
  }

  /// Clear all PIN data (for user deletion/logout)
  static Future<void> clearPinData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final prefs = await SharedPreferences.getInstance();
      final userPinKey = '${_pinKey}_${currentUser.uid}';
      final userPinSetKey = '${_pinSetKey}_${currentUser.uid}';
      final userAttemptsKey = '${_pinAttemptsKey}_${currentUser.uid}';

      await prefs.remove(userAttemptsKey);
      final userSessionKey = '${_pinSessionVerifiedKey}_${currentUser.uid}';
      await prefs.remove(userSessionKey);
    } catch (e) {
      ErrorReporter.reportError('Failed to clear PIN data', e.toString());
    }
  }

  /// Check if current session is already PIN-verified
  static Future<bool> isSessionVerified() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;
      final prefs = await SharedPreferences.getInstance();
      final userSessionKey = '${_pinSessionVerifiedKey}_${currentUser.uid}';
      return prefs.getBool(userSessionKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Explicitly set session verified flag
  static Future<void> _setSessionVerified(bool value) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;
      final prefs = await SharedPreferences.getInstance();
      final userSessionKey = '${_pinSessionVerifiedKey}_${currentUser.uid}';
      if (value) {
        await prefs.setBool(userSessionKey, true);
      } else {
        await prefs.remove(userSessionKey);
      }
    } catch (e) {
      ErrorReporter.reportError('Failed to set PIN session flag', e.toString());
    }
  }

  /// Clear only session-related PIN state (keep stored PIN)
  static Future<void> clearPinSession() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;
      final prefs = await SharedPreferences.getInstance();
      final userSessionKey = '${_pinSessionVerifiedKey}_${currentUser.uid}';
      await prefs.remove(userSessionKey);
      await _resetAttempts();
    } catch (e) {
      ErrorReporter.reportError('Failed to clear PIN session', e.toString());
    }
  }

  /// Validate PIN format
  static bool _isValidPin(String pin) {
    if (pin.length != 4) return false;
    return RegExp(r'^\d{4}$').hasMatch(pin);
  }

  /// Hash PIN with user ID salt
  static String _hashPin(String pin, String userId) {
    final saltedPin = '$pin$userId';
    final bytes = utf8.encode(saltedPin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Increment failed attempts
  static Future<void> _incrementAttempts() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final prefs = await SharedPreferences.getInstance();
      final userAttemptsKey = '${_pinAttemptsKey}_${currentUser.uid}';
      final attempts = prefs.getInt(userAttemptsKey) ?? 0;

      await prefs.setInt(userAttemptsKey, attempts + 1);
    } catch (e) {
      ErrorReporter.reportError(
          'Failed to increment PIN attempts', e.toString());
    }
  }

  /// Reset failed attempts
  static Future<void> _resetAttempts() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final prefs = await SharedPreferences.getInstance();
      final userAttemptsKey = '${_pinAttemptsKey}_${currentUser.uid}';

      await prefs.remove(userAttemptsKey);
    } catch (e) {
      ErrorReporter.reportError('Failed to reset PIN attempts', e.toString());
    }
  }
}
