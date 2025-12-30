import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const String _localeKey = 'app_locale';
  static const Locale defaultLocale = Locale('ar');

  /// Get saved locale from SharedPreferences
  static Future<Locale> getLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);
      if (localeCode != null) {
        return Locale(localeCode);
      }
    } catch (e) {
      // If error, return default locale
    }
    return defaultLocale;
  }

  /// Save locale to SharedPreferences
  static Future<void> setLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get text direction based on locale
  static TextDirection getTextDirection(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return TextDirection.rtl;
      case 'en':
        return TextDirection.ltr;
      default:
        return TextDirection.rtl;
    }
  }

  /// Check if locale is RTL
  static bool isRTL(Locale locale) {
    return getTextDirection(locale) == TextDirection.rtl;
  }
}












