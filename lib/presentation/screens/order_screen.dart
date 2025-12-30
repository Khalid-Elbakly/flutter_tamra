import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamra/presentation/widgets/custom_gradient_divider.dart';
import 'package:tamra/services/orders_service.dart';

class OrderScreen extends StatefulWidget {
  final String orderId;
  const OrderScreen({Key? key, required this.orderId}) : super(key: key);
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final OrdersService _ordersService = OrdersService();

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

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'تم التأكيد';
      case 'preparing':
        return 'قيد التحضير';
      case 'ready':
        return 'جاهز';
      case 'delivered':
        return 'تم التسليم';
      case 'cancelled':
        return 'ملغى';
      default:
        return status ?? 'غير معروف';
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper widget to display price with riyal symbol
  Widget _buildPriceWithSymbol(BuildContext context, double price,
      {double? fontSize, FontWeight? fontWeight, Color? color}) {
    final effectiveFontSize = fontSize ?? 18.0;
    final effectiveFontWeight = fontWeight ?? FontWeight.w600;
    final effectiveColor = color ?? Color(0XFF3D3D3D);
    final symbolSize = effectiveFontSize * 1.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          price.toStringAsFixed(2),
          style: TextStyle(
            color: effectiveColor,
            fontSize: effectiveFontSize,
            fontWeight: effectiveFontWeight,
          ),
        ),
        SizedBox(width: 4),
        Image.asset(
          'assets/images/riyal_symbol.png',
          width: symbolSize,
          height: symbolSize,
          fit: BoxFit.contain,
        ),
      ],
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
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
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
              Text('حالة الطلب',
                  style: TextStyle(
                    color: Color(0XFF3D3D3D),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ),
        body: FutureBuilder<DocumentSnapshot?>(
          future: _ordersService.getOrder(widget.orderId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(horizontal: 60, vertical: 60),
                        decoration: BoxDecoration(
                          color: Color(0XFFF4F6F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0XFFE0E0E0),
                              ),
                            ),
                            SizedBox(height: 15),
                            Container(
                              height: 24,
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Color(0XFFE0E0E0),
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 20,
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Color(0XFFE0E0E0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0XFFF4F6F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 20,
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Color(0XFFE0E0E0),
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 16,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Color(0XFFE0E0E0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      ...List.generate(3, (index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 15),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Color(0XFFF4F6F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color(0XFFE0E0E0),
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 18,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Color(0XFFE0E0E0),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      height: 16,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Color(0XFFE0E0E0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 20,
                                width: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Color(0XFFE0E0E0),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                !snapshot.data!.exists) {
              return Center(
                child: Text('حدث خطأ في جلب بيانات الطلب'),
              );
            }

            final orderData = snapshot.data!.data() as Map<String, dynamic>;
            final status = orderData['status'] as String? ?? 'pending';
            final createdAt = orderData['createdAt'] as Timestamp?;
            final items = (orderData['items'] as List<dynamic>?) ?? [];
            final deliveryFee =
                (orderData['deliveryFee'] as num?)?.toDouble() ?? 0.0;
            final total = (orderData['total'] as num?)?.toDouble() ?? 0.0;
            final vendorId = orderData['vendorId'] as String?;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(horizontal: 60, vertical: 60),
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
                                status == 'delivered'
                                    ? Icons.check_circle_rounded
                                    : status == 'cancelled'
                                        ? Icons.cancel
                                        : Icons.pending,
                                color: Color(0XFF7C3425),
                                size: 30,
                              ),
                              SizedBox(width: 10),
                              Text(
                                _getStatusLabel(status),
                                style: TextStyle(
                                  color: Color(0XFF2E2E2E),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            _formatDate(createdAt),
                            style: TextStyle(
                              color: Color(0XFF888888),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    if (vendorId != null)
                      FutureBuilder<DocumentSnapshot?>(
                        future: FirebaseFirestore.instance
                            .collection('vendors')
                            .doc(vendorId)
                            .get(),
                        builder: (context, vendorSnapshot) {
                          String vendorName = 'البائع';
                          if (vendorSnapshot.hasData &&
                              vendorSnapshot.data != null &&
                              vendorSnapshot.data!.exists) {
                            final data = vendorSnapshot.data!.data()
                                as Map<String, dynamic>?;
                            vendorName = data?['businessName'] ?? 'البائع';
                          }
                          return Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
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
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    vendorName,
                                    style: TextStyle(
                                      color: Color(0XFF7C3425),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    SizedBox(height: 20),
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
                    ...items.map<Widget>((item) {
                      final itemMap = item as Map<String, dynamic>;
                      final nameAr = itemMap['nameAr'] ?? '';
                      final quantity = itemMap['quantity'] ?? 0;
                      final price =
                          (itemMap['price'] as num?)?.toDouble() ?? 0.0;
                      final packagingWeight = itemMap['packagingWeight'] ?? '';
                      final itemTotal = quantity * price;

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  nameAr,
                                  style: TextStyle(
                                    color: Color(0XFF3D3D3D),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (packagingWeight.isNotEmpty)
                                      Text(
                                        '$quantity x $packagingWeight',
                                        style: TextStyle(
                                          color: Color(0XFF3D3D3D),
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    _buildPriceWithSymbol(
                                      context,
                                      itemTotal,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                              )
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
                              _buildPriceWithSymbol(
                                context,
                                deliveryFee,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
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
                              _buildPriceWithSymbol(
                                context,
                                total,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0XFF7C3425),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    if (status == 'delivered')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color(0Xff7C3425),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 8),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                              ),
                            ),
                            onPressed: () {
                              // TODO: إعادة الطلب
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('ميزة إعادة الطلب قريباً'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              textDirection: TextDirection.rtl,
                              children: [
                                Text('اعادة هذا الطلب',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    )),
                                SizedBox(width: 5),
                                Icon(
                                  color: Colors.white,
                                  Icons.arrow_forward_ios,
                                  size: 18.0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
