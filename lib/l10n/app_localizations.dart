import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

abstract class AppLocalizations {
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates => [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  // App strings
  String get appName;
  String get newAddress;
  String get addressName;
  String get addressDescription;
  String get addressOnMap;
  String get save;
  String get home;
  String get basket;
  String get providers;
  String get myAccount;
  String get deliveryTo;
  String get searchProduct;
  String get fruits;
  String get vegetables;
  String get papers;
  String get citrus;
  String get tropical;
  String get local;
  String get selectLanguage;
  String get arabic;
  String get english;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'ar':
        Intl.defaultLocale = 'ar';
        return AppLocalizationsAr();
      case 'en':
        Intl.defaultLocale = 'en';
        return AppLocalizationsEn();
      default:
        Intl.defaultLocale = 'ar';
        return AppLocalizationsAr();
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

