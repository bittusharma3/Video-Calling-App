// lib/utils/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static const _kPrefKey = 'theme_mode'; // values: 'system','light','dark'
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.system);

  // Call at app startup to restore saved mode.
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(_kPrefKey) ?? 'system';
      mode.value = _stringToThemeMode(s);
    } catch (_) {
      mode.value = ThemeMode.system;
    }
  }

  static Future<void> setMode(ThemeMode m) async {
    mode.value = m;
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(_kPrefKey, _themeModeToString(m));
    } catch (_) {}
  }

  // Toggle between light and dark. If current is system -> switch to light.
  static Future<void> toggleTheme() async {
    final current = mode.value;
    if (current == ThemeMode.dark) {
      await setMode(ThemeMode.light);
    } else if (current == ThemeMode.light) {
      await setMode(ThemeMode.dark);
    } else {
      // system -> pick light first (you can change to dark if you prefer)
      await setMode(ThemeMode.light);
    }
  }

  static String _themeModeToString(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  static ThemeMode _stringToThemeMode(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
