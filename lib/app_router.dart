import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tamra/presentation/screens/add_address_screen.dart';
import 'package:tamra/presentation/screens/contact_screen.dart';
import 'package:tamra/presentation/screens/home_screen.dart';
import 'package:tamra/presentation/screens/layout_screen.dart';
import 'package:tamra/presentation/screens/privacy_policy_screen.dart';
import 'package:tamra/presentation/screens/select_language_screen.dart';
import 'package:tamra/presentation/screens/terms_screen.dart';
import 'package:tamra/presentation/screens/update_account_screen.dart';
import 'package:tamra/presentation/screens/verify_screen.dart';
import 'package:tamra/presentation/screens/intro_screen.dart';
import 'package:tamra/presentation/screens/login_screen.dart';
import 'constants/strings.dart';

import 'main.dart';
import 'presentation/screens/order_screen.dart';
import 'presentation/screens/orders_screen.dart';
import 'presentation/screens/test_scree.dart';

class AppRouter {
  AppRouter() {}

  Route generateRoute(RouteSettings settings) {
    // final storage = new FlutterSecureStorage();
    // final String token = storage.read(key: 'token').toString();
    switch (settings.name) {
      // case homeScreen:
      //   return MaterialPageRoute(
      //     builder: (context) => HomeScreen(),
      //   );
      case introScreen:
        return MaterialPageRoute(
          builder: (context) => IntroScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => IntroScreen(),
        );
    }
  }
}
