import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/locale_service.dart';

/// Extension to easily get AppLocalizations from context
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations? get l10n => AppLocalizations.of(this);
}

/// Extension to get text direction from locale
extension LocaleExtension on Locale {
  TextDirection get textDirection => LocaleService.getTextDirection(this);
  
  bool get isRTL => LocaleService.isRTL(this);
}

/// Helper widget to wrap content with locale-aware Directionality
class LocaleDirectionality extends StatelessWidget {
  final Widget child;
  final Locale locale;

  const LocaleDirectionality({
    Key? key,
    required this.child,
    required this.locale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: locale.textDirection,
      child: child,
    );
  }
}












