import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final textScaleFactor = mediaQuery.textScaleFactor.clamp(0.8, 1.2);
    
    // Responsive calculations
    final horizontalPadding = screenWidth * 0.05; // 5% of screen width
    final logoWidth = screenWidth * 0.5; // 50% of screen width, max 250
    final socialImageWidth = screenWidth * 0.75; // 75% of screen width, max 350
    final buttonHeight = screenHeight * 0.08; // 8% of screen height
    final iconSize = screenWidth * 0.08; // 8% of screen width
    final buttonIconSize = screenWidth * 0.1; // 10% of screen width
    
    // Responsive spacing
    final topSpacing = screenHeight * 0.06; // 6% of screen height
    final logoSpacing = screenHeight * 0.08; // 8% of screen height
    final textSpacing = screenHeight * 0.02; // 2% of screen height
    final socialSpacing = screenHeight * 0.03; // 3% of screen height
    final bottomPadding = screenHeight * 0.025; // 2.5% of screen height
    
    // Responsive text sizes
    final titleFontSize = screenWidth * 0.05; // 5% of screen width
    final contactFontSize = screenWidth * 0.045; // 4.5% of screen width
    
    // Responsive app bar leading width
    final leadingWidth = screenWidth * 0.75; // 75% of screen width
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: SafeArea(
        top: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            bottomOpacity: 0.0,
            elevation: 0.0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            leadingWidth: leadingWidth,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            leading: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: horizontalPadding),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    color: Color(0XFF575757),
                    Icons.arrow_back,
                    size: iconSize,
                  ),
                ),
                SizedBox(width: horizontalPadding),
                Flexible(
                  child: Text(
                    'تواصل معنا',
                    style: TextStyle(
                      color: Color(0XFF3D3D3D),
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(height: topSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo_1.png',
                        width: logoWidth.clamp(150.0, 250.0),
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  SizedBox(height: logoSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'info@tamra.sa',
                          style: TextStyle(
                            fontSize: contactFontSize * textScaleFactor,
                            fontWeight: FontWeight.w500,
                            color: Color(0XFF3D3D3D),
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: textSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          '00966543435252',
                          style: TextStyle(
                            fontSize: contactFontSize * textScaleFactor,
                            fontWeight: FontWeight.w500,
                            color: Color(0XFF3D3D3D),
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: socialSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Image.asset(
                          'assets/images/social.png',
                          width: socialImageWidth.clamp(200.0, 350.0),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: bottomPadding),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final availableWidth = constraints.maxWidth;
                            final buttonSpacing = availableWidth * 0.05;
                            final responsiveButtonWidth = (availableWidth - (buttonSpacing * 2)) / 3;
                            
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0XFF888888),
                                      minimumSize: Size(
                                        responsiveButtonWidth,
                                        buttonHeight.clamp(50.0, 80.0),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.02,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: Image.asset(
                                      'assets/images/con_tel.png',
                                      width: buttonIconSize.clamp(30.0, 50.0),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                SizedBox(width: buttonSpacing),
                                Flexible(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0XFF888888),
                                      minimumSize: Size(
                                        responsiveButtonWidth,
                                        buttonHeight.clamp(50.0, 80.0),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.02,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: Image.asset(
                                      'assets/images/con_wat.png',
                                      width: buttonIconSize.clamp(30.0, 50.0),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                SizedBox(width: buttonSpacing),
                                Flexible(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0XFF888888),
                                      minimumSize: Size(
                                        responsiveButtonWidth,
                                        buttonHeight.clamp(50.0, 80.0),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.02,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: Image.asset(
                                      'assets/images/con_let.png',
                                      width: buttonIconSize.clamp(30.0, 50.0),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
