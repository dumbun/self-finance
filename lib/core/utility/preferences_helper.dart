import 'package:self_finance/core/utility/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A helper class for managing app preferences using SharedPreferences.
/// Handles theme mode and notification toggle persistence.
class PreferencesHelper {
  PreferencesHelper._(); // Private constructor — use static methods only

  // ─── Keys ────────────────────────────────────────────────────────────────
  static const String _keyDarkTheme = 'is_dark_theme';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyBiometrics = 'is_bio_metrics';

  // ─── Defaults ─────────────────────────────────────────────────────────────
  static const bool _defaultDarkTheme = false;
  static const bool _defaultNotifications = true;
  static const bool _defaultBiometrics = true;

  // ─── Biometrics ────────────────────────────────────────────────────────────────

  static Future<bool> isBiometrics() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometrics) ?? _defaultBiometrics;
  }

  /// Saves the biometrics preference.
  ///
  /// Pass `true` to enable , `false` for disable.
  static Future<void> setBiometrics(bool isBiometrics) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometrics, isBiometrics);
  }

  /// Toggles the current theme and returns the new value.
  static Future<bool> toggleBiometrics() async {
    final current = await isBiometrics();
    final newValue = !current;
    await setBiometrics(newValue);
    return newValue;
  }

  // ─── Theme ────────────────────────────────────────────────────────────────

  /// Returns `true` if dark theme is enabled, `false` for light theme.
  static Future<bool> isDarkTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkTheme) ?? _defaultDarkTheme;
  }

  /// Saves the dark theme preference.
  ///
  /// Pass `true` to enable dark theme, `false` for light theme.
  static Future<void> setDarkTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkTheme, isDark);
  }

  /// Toggles the current theme and returns the new value.
  static Future<bool> toggleTheme() async {
    final current = await isDarkTheme();
    final newValue = !current;
    await setDarkTheme(newValue);
    return newValue;
  }

  // ─── Notifications ────────────────────────────────────────────────────────

  /// Returns `true` if notifications are enabled.
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifications) ?? _defaultNotifications;
  }

  /// Saves the notification preference.
  ///
  /// Pass `true` to enable notifications, `false` to disable.
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, enabled);
    enabled
        ? await NotificationService().initNotification()
        : await NotificationService().cancelAllNotifications();
  }

  /// Toggles the current notification setting and returns the new value.
  static Future<bool> toggleNotifications() async {
    final current = await areNotificationsEnabled();
    final newValue = !current;
    await setNotificationsEnabled(newValue);
    return newValue;
  }

  // ─── Bulk Operations ──────────────────────────────────────────────────────

  /// Loads all preferences at once and returns them as a map.
  ///
  /// Keys: `isDarkTheme`, `notificationsEnabled`, `isBiometrics`
  static Future<Map<String, bool>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isDarkTheme': prefs.getBool(_keyDarkTheme) ?? _defaultDarkTheme,
      'notificationsEnabled':
          prefs.getBool(_keyNotifications) ?? _defaultNotifications,
      'isBiometrics': prefs.getBool(_keyBiometrics) ?? _defaultNotifications,
    };
  }

  /// Resets all preferences to their default values.
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDarkTheme);
    await prefs.remove(_keyNotifications);
    await prefs.remove(_keyBiometrics);
  }
}
