import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../services/locale_service.dart';
import '../../main.dart';
import '../widgets/custom_gradient_divider.dart';

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({Key? key}) : super(key: key);
  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

enum SingingCharacter { english, arabic }

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  SingingCharacter? _character = SingingCharacter.arabic;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    _loadCurrentLocale();
  }

  Future<void> _loadCurrentLocale() async {
    final locale = await LocaleService.getLocale();
    setState(() {
      _character = locale.languageCode == 'en'
          ? SingingCharacter.english
          : SingingCharacter.arabic;
    });
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
      child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            //  shape:Border.n
            bottomOpacity: 0.0,
            elevation: 0.0,
            centerTitle: true,
            backgroundColor: Colors.white,
            toolbarHeight: kToolbarHeight,
            leadingWidth: 300,
            leading: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 20),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    color: Color(0XFF575757),
                    Icons.arrow_back,
                    size: 30.0,
                  ),
                ),
                SizedBox(width: 20),
                Text(
                    AppLocalizations.of(context)?.selectLanguage ??
                        'اختر اللغة',
                    style: TextStyle(
                      color: Color(0XFF3D3D3D),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ListTile(
                  title:
                      Text(AppLocalizations.of(context)?.english ?? 'English',
                          style: TextStyle(
                            color: Color(0XFF3D3D3D),
                            fontSize: 18,
                          )),
                  leading: Radio<SingingCharacter>(
                    value: SingingCharacter.english,
                    groupValue: _character,
                    onChanged: (SingingCharacter? value) async {
                      setState(() {
                        _character = value;
                      });
                      if (value == SingingCharacter.english) {
                        final appState = MyApp.of(context);
                        appState?.setLocale(Locale('en'));
                      }
                    },
                  ),
                ),
                CustomGradientDivider(),
                ListTile(
                  title: Text(AppLocalizations.of(context)?.arabic ?? 'العربية',
                      style: TextStyle(
                        color: Color(0XFF3D3D3D),
                        fontSize: 18,
                      )),
                  leading: Radio<SingingCharacter>(
                    value: SingingCharacter.arabic,
                    groupValue: _character,
                    onChanged: (SingingCharacter? value) async {
                      setState(() {
                        _character = value;
                      });
                      if (value == SingingCharacter.arabic) {
                        final appState = MyApp.of(context);
                        appState?.setLocale(Locale('ar'));
                      }
                    },
                  ),
                ),
              ],
            ),
          )),
    );
  }

  startTime() async {
    // TODO: Implement if needed
  }

  route() {
    // Navigator.push(context, MaterialPageRoute(
    //     builder: (context) => LoginScreen()
    //   )
    // );
  }
}
