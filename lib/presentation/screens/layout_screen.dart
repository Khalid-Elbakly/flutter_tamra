import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tamra/presentation/screens/Providers_screen.dart';
import 'package:tamra/presentation/screens/account_screen.dart';
import 'package:tamra/presentation/screens/basket_screen.dart';
import 'package:tamra/presentation/screens/home_screen.dart';
import '../../l10n/app_localizations.dart';

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({Key? key}) : super(key: key);
  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    BasketScreen(),
    ProvidersScreen(),
    AccountScreen(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Color(0XFF7C3425),
            selectedLabelStyle:
                TextStyle(color: Color(0XFF7C3425), fontSize: 15),
            unselectedItemColor: Color(0XFF707070),
            unselectedLabelStyle:
                TextStyle(color: Color(0XFF707070), fontSize: 15),
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: AppLocalizations.of(context)?.home ?? 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                label: AppLocalizations.of(context)?.basket ?? 'السلة',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.store),
                label: AppLocalizations.of(context)?.providers ?? 'الموردين',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.manage_accounts),
                label: AppLocalizations.of(context)?.myAccount ?? 'حسابي',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
      ),
    );
  }

  startTime() async {
    var duration = new Duration(seconds: 3);
    // return new Timer(
    //     duration,route
    //    );
  }

  route() {
    // Navigator.push(context, MaterialPageRoute(
    //     builder: (context) => LoginScreen()
    //   )
    // );
  }
}
