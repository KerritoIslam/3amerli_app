import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants/app_language.dart';

/// App settings stored in SharedPreferences.
///
/// - themeMode is stored as int: 0 = system, 1 = light, 2 = dark
/// - language is stored as a language code string (e.g. 'en','fr','ar')
class Settings {
  static const _kThemeMode = 'settings_theme_mode';
  static const _kLanguage = 'settings_language';

  final SharedPreferences _prefs;

  /// Notifiers to listen for changes in UI code.
  final ValueNotifier<ThemeMode> themeModeNotifier;
  final ValueNotifier<String> languageNotifier;

  Settings._(this._prefs, ThemeMode initialTheme, String initialLanguage)
      : themeModeNotifier = ValueNotifier(initialTheme),
        languageNotifier = ValueNotifier(initialLanguage);

  /// Create Settings from a SharedPreferences instance.
  ///
  /// This will read persisted values if present, otherwise defaults to
  /// ThemeMode.system and the system locale language (if supported) or 'en'.
  factory Settings(SharedPreferences prefs) {
    // Determine initial theme preference
    final storedTheme = prefs.getInt(_kThemeMode);
    ThemeMode themeMode;
    if (storedTheme == null) {
      themeMode = ThemeMode.system;
    } else if (storedTheme == 1) {
      themeMode = ThemeMode.light;
    } else if (storedTheme == 2) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.system;
    }

    // Determine initial language, try system locale if available
    final storedLang = prefs.getString(_kLanguage);
    String language;
    if (storedLang != null && storedLang.isNotEmpty) {
      language = storedLang;
    } else {
      // Try to read from platform locale. WidgetsBinding should be
      // initialized by the caller (main) before creating injection.
      try {
        final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
        if (code == 'fr' || code == 'ar' || code == 'en') {
          language = code;
        } else {
          language = 'en';
        }
      } catch (_) {
        language = 'en';
      }
    }

    return Settings._(prefs, themeMode, language);
  }

  ThemeMode get themeMode => themeModeNotifier.value;

  Future<void> setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    final int stored;
    if (mode == ThemeMode.light) {
      stored = 1;
    } else if (mode == ThemeMode.dark) {
      stored = 2;
    } else {
      stored = 0;
    }
    await _prefs.setInt(_kThemeMode, stored);
  }

  String get language => languageNotifier.value;

  Future<void> setLanguage(String code) async {
    languageNotifier.value = code;
    await _prefs.setString(_kLanguage, code);
    
    // Update AppLanguage.current when language changes
    if (code == 'fr') {
      AppLanguage.current = AppLocale.fr;
    } else if (code == 'ar') {
      AppLanguage.current = AppLocale.ar;
    } else {
      AppLanguage.current = AppLocale.en;
    }
  }

  /// Convenience: toggle between light/dark (does not change system)
  Future<void> toggleDark() async {
    if (themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  /// Reset theme to system default (removes stored preference)
  Future<void> resetThemeToSystem() async {
    themeModeNotifier.value = ThemeMode.system;
    await _prefs.remove(_kThemeMode);
  }

  /// Close notifiers when disposing (if you ever dispose Settings)
  void dispose() {
    themeModeNotifier.dispose();
    languageNotifier.dispose();
  }
}
