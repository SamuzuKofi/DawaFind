import 'package:shared_preferences/shared_preferences.dart';

/// Single place where every persisted user preference lives. No screen touches
/// SharedPreferences keys directly, so a key can be renamed here without
/// breaking anything else.
class PreferencesService {
  PreferencesService._();

  static const _keyLanguage = 'selected_language';
  static const _keyUserType = 'user_type';
  static const _keyOnboardingDone = 'onboarding_done';
  static const _keyLoggedIn = 'is_logged_in';
  static const _keyDarkMode = 'dark_mode';

  /// Display names for the two letter codes we store, used in menus.
  static const Map<String, String> languageNames = {
    'EN': 'English',
    'FR': 'Français',
    'KR': 'Ikirundi',
  };

  static Future<void> saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, lang);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'EN';
  }

  static Future<void> saveUserType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserType, type);
  }

  static Future<String> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserType) ?? 'patient';
  }

  static Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, true);
  }

  static Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingDone) ?? false;
  }

  // Lets the splash screen send a returning user straight to their own home
  // screen instead of the login form.
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  /// Clears the session on logout. The language and theme choices are kept on
  /// purpose, since they belong to the device rather than to the account.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyUserType);
  }

  static Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }
}
