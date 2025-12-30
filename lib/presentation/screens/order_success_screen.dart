import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tamra/models/cart_item.dart';
import 'package:tamra/presentation/screens/layout_screen.dart';
import 'package:tamra/presentation/widgets/custom_gradient_divider.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String deliveryAddress;
  final String deliveryAddressName;
  final List<CartItem> items;
  final double deliveryFee;
  final double total;

  const OrderSuccessScreen({
    Key? key,
    required this.deliveryAddress,
    required this.deliveryAddressName,
    required this.items,
    required this.deliveryFee,
    required this.total,
  }) : super(key: key);

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
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
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            //  shape:Border.n
            bottomOpacity: 0.0,
            elevation: 0.0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
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
                Text('حالة الطلب',
                    style: TextStyle(
                      color: Color(0XFF3D3D3D),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 60),
                    decoration: BoxDecoration(
                      color: Color(0XFFF4F6F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Color(0XFF7C3425),
                              size: 30,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text('تم استلام الطلب',
                                style: TextStyle(
                                  color: Color(0XFF2E2E2E),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('سيتم تجهيز و توصيل طلبك في غضون 4 ساعات',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0XFF888888),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: Color(0XFFF4F6F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Color(0XFF6C7B8A),
                          size: 30,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            widget.deliveryAddressName.isNotEmpty
                                ? widget.deliveryAddressName
                                : widget.deliveryAddress,
                            style: TextStyle(
                              color: Color(0XFF7C3425),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text('الاصناف',
                          style: TextStyle(
                            color: Color(0XFF3D3D3D),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: CustomGradientDivider(),
                  ),
                  ...widget.items.map((item) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.nameAr,
                                style: TextStyle(
                                  color: Color(0XFF3D3D3D),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${item.quantity} ${item.packagingWeight}',
                                  style: TextStyle(
                                    color: Color(0XFF3D3D3D),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${item.totalPrice.toStringAsFixed(2)} رس',
                                  style: TextStyle(
                                    color: Color(0XFF3D3D3D),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: CustomGradientDivider(),
                        ),
                      ],
                    );
                  }).toList(),
                  Row(
                    children: [
                      Text('التوصيل',
                          style: TextStyle(
                            color: Color(0XFF3D3D3D),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          )),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${widget.deliveryFee.toStringAsFixed(2)} رس',
                              style: TextStyle(
                                color: Color(0XFF3D3D3D),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text('الاجمالي',
                          style: TextStyle(
                            color: Color(0XFF3D3D3D),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          )),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${widget.total.toStringAsFixed(2)} رس',
                              style: TextStyle(
                                color: Color(0XFF3D3D3D),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      // إزالة جميع الصفحات من الستاك والعودة للصفحة الرئيسية
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => LayoutScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0XFF7C3425),
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'العودة للصفحة الرئيسية',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
