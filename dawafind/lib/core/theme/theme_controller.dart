import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

/// Holds the theme the app is currently showing and keeps it in sync with
/// SharedPreferences. A ValueNotifier is used rather than setState so that no
/// single screen owns the theme: app.dart listens to it, and any screen can
/// flip it by calling setDark().
class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.light);

  bool get isDark => mode.value == ThemeMode.dark;

  /// Restores the saved choice. Called once from main() before the first frame
  /// so the app never flashes light before switching to dark.
  Future<void> load() async {
    final bool saved = await PreferencesService.isDarkMode();
    mode.value = saved ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setDark(bool value) async {
    mode.value = value ? ThemeMode.dark : ThemeMode.light;
    await PreferencesService.saveDarkMode(value);
  }
}
