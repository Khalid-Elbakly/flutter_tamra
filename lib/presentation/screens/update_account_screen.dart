import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import 'layout_screen.dart';

class UpdateAccountScreen extends StatefulWidget {
  final bool isEditing;
  const UpdateAccountScreen({Key? key, this.isEditing = false})
      : super(key: key);
  @override
  State<UpdateAccountScreen> createState() => _UpdateAccountScreenState();
}

class _UpdateAccountScreenState extends State<UpdateAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    _loadUserData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _formatPhoneForDisplay(String phone) {
    if (phone.isEmpty) return '';
    // إزالة +966 إذا كان موجوداً لأنها ستكون في prefix
    if (phone.startsWith('+966')) {
      phone = phone.substring(4);
    } else if (phone.startsWith('966')) {
      phone = phone.substring(3);
    }
    // إزالة أي مسافات أو شرطات
    phone = phone.replaceAll(RegExp(r'[\s-]'), '');
    // إرجاع الرقم بدون +966
    return phone;
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _authService.getUserProfile(user.uid, 'client');
      if (!mounted || _isDisposed) return;

      if (userData != null) {
        try {
          setState(() {
            _nameController.text = userData['fullName'] ?? '';
            _emailController.text = userData['email'] ?? '';
            String phone = userData['phoneNumber'] ?? user.phoneNumber ?? '';
            _phoneController.text = _formatPhoneForDisplay(phone);
          });
        } catch (e) {
          // Controller تم dispose، تجاهل
          debugPrint('Error setting controller values: $e');
        }
      } else if (user.phoneNumber != null) {
        try {
          setState(() {
            _phoneController.text = _formatPhoneForDisplay(user.phoneNumber!);
          });
        } catch (e) {
          // Controller تم dispose، تجاهل
          debugPrint('Error setting phone controller: $e');
        }
      } else {
        // إذا لم يكن هناك رقم جوال، اترك الحقل فارغاً (prefix +966 سيظهر)
        try {
          setState(() {
            _phoneController.text = '';
          });
        } catch (e) {
          debugPrint('Error setting default phone: $e');
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!mounted || _isDisposed) return;

    // حفظ القيم في متغيرات محلية قبل أي async operations
    String fullName;
    String email;

    try {
      fullName = _nameController.text.trim();
      email = _emailController.text.trim();
    } catch (e) {
      // Controller تم dispose، تجاهل
      debugPrint('Error accessing controllers: $e');
      return;
    }

    if (fullName.isEmpty) {
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('من فضلك أدخل الاسم الكامل'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (email.isEmpty) {
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('من فضلك أدخل البريد الإلكتروني'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // التحقق من صحة البريد الإلكتروني
    if (!email.contains('@')) {
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('البريد الإلكتروني غير صحيح'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!mounted || _isDisposed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('المستخدم غير مسجل دخول');
      }

      // نستخدم رقم الجوال الموثق من Auth إذا كان موجوداً
      // هذا يضمن عدم تخريب الرقم (مثلاً +20 لا يصبح +966+20)
      String phoneNumber = user.phoneNumber ?? '';

      // إذا لم يكن هناك رقم في Auth (نادر)، نستخدم الرقم من الحقل مع معالجته
      if (phoneNumber.isEmpty) {
        phoneNumber = _phoneController.text.trim();
        // إذا كان الرقم المدخل في الحقل يبدأ بـ +، نعتبره كاملاً
        if (!phoneNumber.startsWith('+')) {
          // إذا لم يبدأ بـ +، نفترض أنه سعودي ونضيف +966
          if (phoneNumber.startsWith('966')) {
            phoneNumber = '+$phoneNumber';
          } else {
            phoneNumber = '+966$phoneNumber';
          }
        }
      }

      await _authService.updateUserProfile(
        userId: user.uid,
        userType: 'client',
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
      );

      if (!mounted || _isDisposed) return;

      if (widget.isEditing) {
        // إذا كنا في وضع التعديل، نظهر رسالة نجاح ونعود للخلف
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تعديل البيانات بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
        Navigator.pop(context);
      } else {
        // إذا كنا في وضع إنشاء الحساب، ننتقل للشاشة الرئيسية
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LayoutScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted || _isDisposed) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                    SizedBox(height: MediaQuery.of(context).padding.top + 30),
                    // زر الرجوع (يظهر فقط عند فتح الصفحة من account_screen)
                    if (widget.isEditing)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back,
                                color: Color(0XFF6A6A6A),
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 20),
                  // اللوجو
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo_1.png', width: 170),
                    ],
                  ),
                  SizedBox(height: 80),
                  // العنوان
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.isEditing ? 'تعديل البيانات' : 'أكمل بياناتك',
                        style: TextStyle(
                          color: Color(0XFF6A6A6A),
                          fontSize: 20,
                          fontFamily: 'IBMPlex',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  // حقل الاسم
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الاسم الكامل',
                          style: TextStyle(
                            color: Color(0XFF6A6A6A),
                            fontSize: 18,
                            fontFamily: 'IBMPlex',
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          style: TextStyle(
                            fontFamily: 'IBMPlex',
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Color(0XffBE6F47), width: 2),
                            ),
                            hintText: 'ادخل اسمك الكامل',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontFamily: 'IBMPlex',
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // حقل البريد الإلكتروني
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'البريد الإلكتروني',
                          style: TextStyle(
                            color: Color(0XFF6A6A6A),
                            fontSize: 18,
                            fontFamily: 'IBMPlex',
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            fontFamily: 'IBMPlex',
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Color(0XffBE6F47), width: 2),
                            ),
                            hintText: 'example@email.com',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontFamily: 'IBMPlex',
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // حقل رقم الجوال
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رقم الجوال',
                          style: TextStyle(
                            color: Color(0XFF6A6A6A),
                            fontSize: 18,
                            fontFamily: 'IBMPlex',
                          ),
                        ),
                        SizedBox(height: 8),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: TextField(
                            textAlign: TextAlign.right,
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            enabled: false,
                            style: TextStyle(
                              fontFamily: 'IBMPlex',
                              fontSize: 16,
                              color: Color(0XFF6A6A6A),
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                  // زر الحفظ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: _isLoading ? null : _saveProfile,
                        child: _isLoading
                            ? Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0XFF6A6A6A)),
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.isEditing ? 'حفظ' : 'التالي',
                                    style: TextStyle(
                                      color: Color(0XFF6A6A6A),
                                      fontSize: 18,
                                      fontFamily: 'IBMPlex',
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(Icons.arrow_forward_ios,
                                      size: 18, color: Color(0XFF6A6A6A)),
                                ],
                              ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
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
