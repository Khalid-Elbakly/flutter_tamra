import 'package:flutter/material.dart';
import 'package:tamra/presentation/screens/login_screen.dart';
import 'package:tamra/presentation/screens/layout_screen.dart';
import 'package:tamra/services/auth_service.dart';
import 'dart:async';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/intro_back.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Image.asset('assets/images/logo_white.png', width: 170),
      ),
    );
  }

  startTime() async {
    var duration = new Duration(seconds: 2);
    return new Timer(
        duration, route
       );
  }

  route() {
    // التحقق من حالة تسجيل الدخول
    final currentUser = _authService.currentUser;
    
    if (currentUser != null) {
      // المستخدم مسجل دخول - الانتقال مباشرة للصفحة الرئيسية
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LayoutScreen(),
        ),
      );
    } else {
      // المستخدم غير مسجل دخول - الانتقال لشاشة تسجيل الدخول
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    }
  }
}
