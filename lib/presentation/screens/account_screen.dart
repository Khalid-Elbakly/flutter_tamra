import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tamra/presentation/screens/addresses_screen.dart';
import 'package:tamra/presentation/screens/contact_screen.dart';
import 'package:tamra/presentation/screens/login_screen.dart';
import 'package:tamra/presentation/screens/orders_screen.dart';
import 'package:tamra/presentation/screens/privacy_policy_screen.dart';
import 'package:tamra/presentation/screens/select_language_screen.dart';
import 'package:tamra/presentation/screens/terms_screen.dart';
import 'package:tamra/presentation/screens/update_account_screen.dart';
import 'package:tamra/presentation/widgets/custom_gradient_divider.dart';
import 'package:tamra/services/auth_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Widget _buildClickableRow({
    required VoidCallback onTap,
    required String iconPath,
    required String text,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(9.0),
                child: Image.asset(iconPath, width: 30, height: 30),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Color(0XFF3D3D3D),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Container(
        color: Colors.white,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(children: [
                      SizedBox(height: MediaQuery.of(context).padding.top + 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/logo_1.png', width: 170),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      _buildClickableRow(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      UpdateAccountScreen(isEditing: true)));
                        },
                        iconPath: 'assets/images/acc.png',
                        text: 'حسابي',
                      ),
                      CustomGradientDivider(),
                      _buildClickableRow(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrdersScreen()));
                        },
                        iconPath: 'assets/images/ord.png',
                        text: 'طلباتي',
                      ),
                      CustomGradientDivider(),
                      _buildClickableRow(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SelectLanguageScreen()));
                        },
                        iconPath: 'assets/images/lang.png',
                        text: 'اللغة',
                      ),
                      CustomGradientDivider(),
                      _buildClickableRow(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddressesScreen()));
                        },
                        iconPath: 'assets/images/addr.png',
                        text: 'عناويني',
                      ),
                      CustomGradientDivider(),
                      _buildClickableRow(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PrivacyPolicyScreen()));
                        },
                        iconPath: 'assets/images/poli.png',
                        text: 'سياسة الخصوصية',
                      ),
                      CustomGradientDivider(),
                      _buildClickableRow(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TermsScreen()));
                        },
                        iconPath: 'assets/images/prpoli.png',
                        text: 'سياسة الاستخدام',
                      ),
                      CustomGradientDivider(),
                      _buildClickableRow(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ContactScreen()));
                        },
                        iconPath: 'assets/images/cont.png',
                        text: 'تواصل معنا',
                      ),
                      CustomGradientDivider(),
                      _buildClickableRow(
                        onTap: () {},
                        iconPath: 'assets/images/share.png',
                        text: 'شارك التطبيق',
                      ),
                      CustomGradientDivider(),
                      _buildClickableRow(
                        onTap: () async {
                          // Show confirmation dialog
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('تسجيل الخروج'),
                                content: Text('هل أنت متأكد من تسجيل الخروج؟'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text('إلغاء'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text('تسجيل الخروج',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );

                          if (shouldLogout == true) {
                            try {
                              await _authService.signOut();
                              if (mounted) {
                                // Navigate to login screen and remove all previous routes
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                  (route) => false,
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('حدث خطأ أثناء تسجيل الخروج'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        iconPath: 'assets/images/log.png',
                        text: 'تسجيل الخروج',
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
