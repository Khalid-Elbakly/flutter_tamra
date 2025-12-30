import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tamra/presentation/screens/verify_screen.dart';
import 'package:tamra/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (_phoneController.text.trim().isEmpty) {
      _showError('من فضلك أدخل رقم الجوال');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await _authService.sendOTP(
      phoneNumber: _phoneController.text.trim(),
      onCodeSent: (String verificationId) {
        setState(() {
          _isLoading = false;
        });
        // الانتقال إلى شاشة التحقق مع إرسال verificationId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyScreen(
              verificationId: verificationId,
              phoneNumber: _phoneController.text.trim(),
            ),
          ),
        );
      },
      onError: (String error) {
        setState(() {
          _isLoading = false;
        });
        _showError(error);
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
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
        resizeToAvoidBottomInset: false,
        body: Directionality(
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
                    height: MediaQuery.of(context).padding.top + 30,
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
                    Text('من فضلك ادخل رقم جوالك',
                        style: TextStyle(
                          color: Color(0XFF6A6A6A),
                          fontSize: 20,
                        ))
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: '05xxxxxxxx',
                              prefixText: '+966 ',
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                // SizedBox(height: 20),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Text('هل لديك حساب',
                //         style: TextStyle(
                //             color: Color(0XFF575757),
                //             fontSize: 20,
                //             ))
                //   ],
                // ),
                SizedBox(
                  height: 180,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0XFF575757)),
                        ),
                      )
                    else ...[
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _sendOTP,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(Icons.arrow_back_ios, size: 18, color: Color(0XFF575757)),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _sendOTP,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                            child: Text(
                              'التالي',
                              style: TextStyle(
                                color: Color(0XFF575757),
                                fontSize: 18,
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
    );
  }

}
