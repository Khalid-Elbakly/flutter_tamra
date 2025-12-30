import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import 'l10n/app_localizations.dart';
import 'services/locale_service.dart';
import 'services/notification_service.dart';
import 'utils/locale_helper.dart';
import 'providers/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // تهيئة خدمة الإشعارات
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(MyApp(
    appRouter: AppRouter(),
  ));
}

class MyApp extends StatefulWidget {
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = LocaleService.defaultLocale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final locale = await LocaleService.getLocale();
    setState(() {
      _locale = locale;
    });
  }

  void setLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    await LocaleService.setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        title: 'Tamra',
        theme: ThemeData(fontFamily: 'IBMPlex'),
        debugShowCheckedModeBanner: false,
        locale: _locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: widget.appRouter.generateRoute,
        builder: (context, child) {
          return LocaleDirectionality(
            locale: _locale,
            child: child ?? const SizedBox(),
          );
        },
      ),
    );
  }
}
