import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
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
  final List<String> _logs = [];
  final ScrollController _logsScrollController = ScrollController();
  bool _showLogger = false;

  @override
  void initState() {
    super.initState();
    // في وضع التطوير، إضافة رقم جوال افتراضي للاختبار وإرسال تلقائي
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _phoneController.text = '0501234567'; // رقم افتراضي للاختبار
          
          // إرسال OTP تلقائياً بعد ثانيتين للاختبار السريع
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && !_isLoading && _phoneController.text.trim().isNotEmpty) {
              debugPrint('🤖 إرسال OTP تلقائياً للاختبار...');
              _sendOTP();
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _logsScrollController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    if (!mounted) return; // التحقق من mounted قبل setState
    
    final timestamp = DateTime.now().toString().substring(0, 19);
    // Also print to console
    debugPrint('[$timestamp] $message');
    
    // استخدام Future.microtask لضمان التنفيذ في main thread
    Future.microtask(() {
      if (!mounted) return;
      
      setState(() {
        _logs.add('[$timestamp] $message');
        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_logsScrollController.hasClients) {
            _logsScrollController.animateTo(
              _logsScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      });
    });
  }

  void _clearLogs() {
    if (!mounted) return; // التحقق من mounted قبل setState
    setState(() {
      _logs.clear();
    });
  }

  String _getAllLogs() {
    return _logs.join('\n');
  }

  Future<void> _sendOTP() async {
    // منع الضغط المتكرر
    if (_isLoading) return;
    
    if (!mounted) return;
    
    try {
      if (_phoneController.text.trim().isEmpty) {
        _showError('من فضلك أدخل رقم الجوال');
        _addLog('❌ خطأ: لم يتم إدخال رقم الجوال');
        return;
      }

      final phoneNumber = _phoneController.text.trim();
      _addLog('📱 محاولة إرسال OTP إلى: $phoneNumber');

      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      await _authService.sendOTP(
        phoneNumber: _phoneController.text.trim(),
        onCodeSent: (String verificationId) {
          // التأكد من أن setState و Navigator يتم استدعاؤهما في main thread
          if (!mounted) return;
          
          _addLog('✅ تم إرسال OTP بنجاح!');
          _addLog('🔑 verificationId: $verificationId');
          
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          // الانتقال إلى شاشة التحقق مع إرسال verificationId
          if (mounted) {
            _addLog('🚀 الانتقال إلى صفحة التحقق...');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerifyScreen(
                  verificationId: verificationId,
                  phoneNumber: _phoneController.text.trim(),
                ),
              ),
            );
          }
        },
        onError: (String error) {
          // التأكد من أن setState يتم استدعاؤه في main thread
          if (!mounted) return;
          
          _addLog('❌ خطأ في إرسال OTP: $error');
          
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            _showError(error);
          }
        },
      );
    } catch (e) {
      // معالجة أي أخطاء غير متوقعة
      debugPrint('خطأ في _sendOTP: $e');
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        _showError('حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى');
        _addLog('❌ خطأ غير متوقع: $e');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return; // التحقق من mounted قبل استخدام context
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
        body: GestureDetector(
          onTap: () {
            // إخفاء الكيبورد عند الضغط على مكان فارغ
            FocusScope.of(context).unfocus();
          },
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
                    height: MediaQuery.of(context).padding.top + 30,
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo_1.png', width: 170),
                  ],
                ),
                // Logger Toggle Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: IconButton(
                        icon: Icon(
                          _showLogger ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _showLogger = !_showLogger;
                          });
                        },
                        tooltip: _showLogger ? 'إخفاء السجلات' : 'إظهار السجلات',
                      ),
                    ),
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
                // Logger Widget
                if (_showLogger)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'السجلات (Logs)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.copy, color: Colors.white, size: 18),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: _getAllLogs()));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('تم نسخ السجلات'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    tooltip: 'نسخ السجلات',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.clear, color: Colors.white, size: 18),
                                    onPressed: _clearLogs,
                                    tooltip: 'مسح السجلات',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: _logs.isEmpty
                                  ? Center(
                                      child: Text(
                                        'لا توجد سجلات',
                                        style: TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    )
                                  : ListView.builder(
                                      controller: _logsScrollController,
                                      itemCount: _logs.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(vertical: 2),
                                          child: SelectableText(
                                            _logs[index],
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
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
      ),
    );
  }

}
