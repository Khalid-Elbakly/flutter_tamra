import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:tamra/presentation/screens/layout_screen.dart';
import 'package:tamra/presentation/screens/update_account_screen.dart';
import 'package:tamra/services/auth_service.dart';
import 'package:tamra/services/notification_service.dart';

class VerifyScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const VerifyScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _otpController = TextEditingController();
  final StreamController<ErrorAnimationType> _errorController =
      StreamController<ErrorAnimationType>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isResending = false;
  bool _isDisposed = false;
  bool _controllerDisposed = false;

  @override
  void dispose() {
    if (_isDisposed) {
      // تم dispose مسبقاً، تجنب الاستدعاء مرة أخرى
      return;
    }
    
    _isDisposed = true;
    
    // إغلاق error controller أولاً
    try {
      if (!_errorController.isClosed) {
        _errorController.close();
      }
    } catch (e) {
      debugPrint('Error closing error controller: $e');
    }
    
    // ثم dispose للـ OTP controller
    // استخدام try-catch لأن PinCodeTextField قد يحاول الوصول إليه بعد dispose
    if (!_controllerDisposed) {
      try {
        _otpController.dispose();
        _controllerDisposed = true;
      } catch (e) {
        // تجاهل الخطأ إذا تم dispose مسبقاً أو إذا كان PinCodeTextField ما زال يستخدمه
        debugPrint('Error disposing OTP controller (may be already disposed or in use): $e');
        _controllerDisposed = true; // وضع علامة حتى لو فشل
      }
    }
    
    super.dispose();
  }

  Future<void> _verifyOTP(String smsCode) async {
    if (!mounted || _isDisposed) return;

    // تحديد نوع المستخدم (client للتطبيق الحالي)
    final result = await _authService.verifyOTP(
      verificationId: widget.verificationId,
      smsCode: smsCode,
      userType: 'client', // للتطبيق Client
    );

    if (!mounted || _isDisposed) return;

    if (result['success'] == true) {
      // نجح التحقق - التحقق من اكتمال بيانات المستخدم
      String userId = result['userId'] as String;
      
      // حفظ FCM token بعد تسجيل الدخول
      try {
        final notificationService = NotificationService();
        await notificationService.saveToken();
      } catch (e) {
        // خطأ في حفظ token (لا يؤثر على تسجيل الدخول)
        print('خطأ في حفظ FCM token: $e');
      }
      
      // التحقق من اكتمال بيانات المستخدم (keep loading during this)
      bool isProfileComplete = await _authService.isUserProfileComplete(userId, 'client');
      
      if (!mounted || _isDisposed) return;
      
      // Keep loading until navigation
      if (isProfileComplete) {
        // البيانات مكتملة - الانتقال إلى الشاشة الرئيسية
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LayoutScreen()),
          (route) => false, // إزالة كل الشاشات السابقة
        );
      } else {
        // البيانات غير مكتملة - الانتقال إلى صفحة إدخال البيانات
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => UpdateAccountScreen()),
          (route) => false, // إزالة كل الشاشات السابقة
        );
      }
    } else {
      // فشل التحقق - إيقاف التحميل وعرض خطأ
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
        });
        if (!_errorController.isClosed) {
          _errorController.add(ErrorAnimationType.shake);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'فشل التحقق من الكود'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleVerifyTap() {
    // يمكن التحقق يدوياً أيضاً
    if (!mounted || _isDisposed || _isLoading) return;
    // التحقق من أن controller لم يتم dispose
    try {
      final otpText = _otpController.text;
      if (otpText.length == 6) {
        // Set loading state immediately for instant UI feedback
        setState(() {
          _isLoading = true;
        });
        _verifyOTP(otpText);
      } else {
        if (mounted && !_isDisposed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('من فضلك أدخل الكود كاملاً'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      // Controller تم dispose، تجاهل الخطأ
      debugPrint('Controller disposed: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    if (_isResending || !mounted || _isDisposed) return;

    setState(() {
      _isResending = true;
    });

    await _authService.sendOTP(
      phoneNumber: widget.phoneNumber,
      onCodeSent: (String newVerificationId) {
        if (!mounted || _isDisposed) return;
        setState(() {
          _isResending = false;
        });
        if (mounted && !_isDisposed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إعادة إرسال الكود'),
              backgroundColor: Colors.green,
            ),
          );
        }
        // يمكنك تحديث verificationId هنا إذا أردت
      },
      onError: (String error) {
        if (!mounted || _isDisposed) return;
        setState(() {
          _isResending = false;
        });
        if (mounted && !_isDisposed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/back_1.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).padding.top + 50,
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo_1.png', width: 170),
                    ],
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('ادخل كود التفعيل',
                          style: TextStyle(
                              color: Color(0XFF6A6A6A),
                              fontSize: 20,
                              fontFamily: 'IBMPlex'))
                    ],
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: PinCodeTextField(
                        appContext: context,
                        pastedTextStyle: TextStyle(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                        length: 6,
                        obscureText: false,
                        blinkWhenObscuring: true,
                        animationType: AnimationType.fade,
                        validator: (v) {
                          if (v!.length < 3) {
                            return "";
                          } else {
                            return null;
                          }
                        },
                        pinTheme: PinTheme(
                          activeColor: Color(0XffBE6F47),
                          inactiveColor: Colors.grey,
                          shape: PinCodeFieldShape.underline,
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 70,
                          fieldWidth: 50,
                          activeFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          selectedFillColor: Colors.white,
                        ),
                        cursorColor: Colors.black,
                        animationDuration:
                            const Duration(milliseconds: 300),
                        enableActiveFill: true,
                        errorAnimationController: _errorController,
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        boxShadows: const [
                          BoxShadow(
                            offset: Offset(0, 1),
                            color: Colors.black12,
                            blurRadius: 10,
                          )
                        ],
                        onCompleted: (v) {
                          // عند إدخال الكود كاملاً، التحقق تلقائياً
                          if (mounted && !_isDisposed && !_isLoading) {
                            try {
                              // Set loading state immediately for instant UI feedback
                              setState(() {
                                _isLoading = true;
                              });
                              _verifyOTP(v);
                            } catch (e) {
                              // تجاهل الأخطاء إذا تم dispose
                              debugPrint('Error in onCompleted: $e');
                              if (mounted && !_isDisposed) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          }
                        },
                        onChanged: (value) {
                          // إزالة أي أخطاء عند تغيير القيمة
                          if (!mounted || _isDisposed) return;
                          try {
                            if (value.length == 6 && !_errorController.isClosed) {
                              _errorController.add(ErrorAnimationType.clear);
                            }
                          } catch (e) {
                            // تجاهل الأخطاء إذا تم dispose
                            debugPrint('Error in onChanged: $e');
                          }
                        },
                        beforeTextPaste: (text) {
                          debugPrint("Allowing to paste $text");
                          return true;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('لم تستلم الكود بعد؟',
                          style: TextStyle(
                              color: Color(0XFF6A6A6A),
                              fontSize: 20,
                              fontFamily: 'IBMPlex'))
                    ],
                  ), 
                  InkWell(
                    onTap: _isResending ? null : _resendOTP,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isResending
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : Text(
                                'اعادة ارسال',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Color(0XFF6A6A6A),
                                  fontSize: 18,
                                  fontFamily: 'IBMPlex',
                                ),
                              )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 130,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0XFF6A6A6A)),
                          ),
                        )
                      else ...[
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _handleVerifyTap,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(Icons.arrow_back_ios, size: 18, color: Color(0XFF6A6A6A)),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _handleVerifyTap,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                              child: Text(
                                'التالي',
                                style: TextStyle(
                                  color: Color(0XFF6A6A6A),
                                  fontSize: 18,
                                  fontFamily: 'IBMPlex',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
