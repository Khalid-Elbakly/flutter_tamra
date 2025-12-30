import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamra/presentation/screens/order_screen.dart';
import 'package:tamra/presentation/widgets/custom_gradient_divider.dart';
import 'package:tamra/services/orders_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrdersService _ordersService = OrdersService();

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method to get responsive font size
  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) {
      return baseSize * 0.85; // Small phones
    } else if (width < 400) {
      return baseSize * 0.9; // Medium phones
    }
    return baseSize; // Large phones and tablets
  }

  // Helper widget to display price with riyal symbol
  Widget _buildPriceWithSymbol(BuildContext context, double price,
      {double? fontSize, FontWeight? fontWeight, Color? color}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 360;

    final effectiveFontSize = fontSize ?? _getResponsiveFontSize(context, 18);
    final effectiveFontWeight = fontWeight ?? FontWeight.w700;
    final effectiveColor = color ?? Color(0XFF3D3D3D);
    final symbolSize =
        isVerySmallScreen ? effectiveFontSize * 0.9 : effectiveFontSize * 1.0;

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

  Widget _buildOrdersList(String? status) {
    return StreamBuilder<QuerySnapshot>(
      stream: _ordersService.getClientOrders(status: status),
      builder: (context, snapshot) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 400;
        final isVerySmallScreen = screenWidth < 360;
        if (snapshot.connectionState == ConnectionState.waiting) {
          final isSmallScreen = MediaQuery.of(context).size.width < 400;
          final isVerySmallScreen = MediaQuery.of(context).size.width < 360;

          return ListView(
            children: [
              SizedBox(height: 15),
              ...List.generate(3, (index) {
                if (isVerySmallScreen) {
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 16,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Color(0XFFE0E0E0),
                                  ),
                                ),
                                Container(
                                  height: 16,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Color(0XFFE0E0E0),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 14,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Color(0XFFE0E0E0),
                                  ),
                                ),
                                Container(
                                  height: 28,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Color(0XFFE0E0E0),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      CustomGradientDivider(),
                      SizedBox(height: 10),
                    ],
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 5 : 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: isSmallScreen ? 3 : 2,
                            child: Container(
                              height: 20,
                              margin: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 4 : 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Color(0XFFE0E0E0),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: isSmallScreen ? 3 : 2,
                            child: Container(
                              height: 20,
                              margin: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 4 : 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Color(0XFFE0E0E0),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: isSmallScreen ? 4 : 3,
                            child: Container(
                              height: 20,
                              margin: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 4 : 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Color(0XFFE0E0E0),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: isSmallScreen ? 4 : 3,
                            child: Container(
                              height: 20,
                              margin: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 4 : 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Color(0XFFE0E0E0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    CustomGradientDivider(),
                    SizedBox(height: 10),
                  ],
                );
              }),
            ],
          );
        }

        if (snapshot.hasError) {
          final error = snapshot.error;
          final isNetworkError = error.toString().contains('network') ||
              error.toString().contains('connection') ||
              error.toString().contains('timeout') ||
              error.toString().contains('SocketException') ||
              error.toString().contains('Failed host lookup');

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isNetworkError ? Icons.wifi_off : Icons.error_outline,
                  size: 64,
                  color: Color(0XFFD1D1D1),
                ),
                SizedBox(height: 16),
                Text(
                  isNetworkError
                      ? 'لا يوجد اتصال بالإنترنت'
                      : 'حدث خطأ في تحميل الطلبات',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0XFF5B5B5B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  isNetworkError
                      ? 'يرجى التحقق من اتصالك بالإنترنت'
                      : 'يرجى المحاولة مرة أخرى',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0XFF909090),
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'لا توجد طلبات',
                style: TextStyle(
                  color: Color(0XFF5B5B5B),
                  fontSize: 18,
                ),
              ),
            ),
          );
        }

        // للتبويب الأول (حالية)، نعرض الطلبات التي ليست delivered أو cancelled
        var orders = snapshot.data!.docs;
        if (status == null) {
          orders = orders.where((doc) {
            final orderStatus =
                (doc.data() as Map<String, dynamic>)['status'] as String?;
            return orderStatus != 'delivered' && orderStatus != 'cancelled';
          }).toList();
        }

        // ترتيب الطلبات حسب createdAt (الأحدث أولاً)
        orders.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aCreatedAt = aData['createdAt'] as Timestamp?;
          final bCreatedAt = bData['createdAt'] as Timestamp?;

          if (aCreatedAt == null && bCreatedAt == null) return 0;
          if (aCreatedAt == null) return 1;
          if (bCreatedAt == null) return -1;

          return bCreatedAt.compareTo(aCreatedAt); // descending
        });

        return ListView(
          children: [
            SizedBox(height: 15),
            ...orders.map((doc) {
              final order = doc.data() as Map<String, dynamic>;
              final orderId = doc.id;
              final orderNumber = order['orderNumber'] as String? ??
                  '#${orderId.substring(0, 6)}';
              final total = (order['total'] as num?)?.toDouble() ?? 0.0;
              final createdAt = order['createdAt'] as Timestamp?;

              // Use different layout for very small screens
              if (isVerySmallScreen)
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                orderNumber,
                                style: TextStyle(
                                  color: Color(0XFF3D3D3D),
                                  fontSize: _getResponsiveFontSize(context, 16),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              _buildPriceWithSymbol(
                                context,
                                total,
                                fontSize: _getResponsiveFontSize(context, 18),
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(createdAt),
                                style: TextStyle(
                                  color: Color(0XFF3D3D3D),
                                  fontSize: _getResponsiveFontSize(context, 14),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color(0Xff112E5B),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isVerySmallScreen ? 8 : 10,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size(0, 32),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OrderScreen(orderId: orderId),
                                    ),
                                  );
                                },
                                child: Text(
                                  'تفاصيل',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        _getResponsiveFontSize(context, 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: CustomGradientDivider(),
                    ),
                  ],
                );

              // Standard layout for larger screens
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 5 : 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: isSmallScreen ? 2 : 2,
                          child: Text(
                            orderNumber,
                            style: TextStyle(
                              color: Color(0XFF3D3D3D),
                              fontSize: _getResponsiveFontSize(context, 16),
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 4 : 8),
                        Expanded(
                          flex: isSmallScreen ? 4 : 3,
                          child: _buildPriceWithSymbol(
                            context,
                            total,
                            fontSize: _getResponsiveFontSize(context, 18),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 4 : 8),
                        Expanded(
                          flex: isSmallScreen ? 4 : 3,
                          child: Text(
                            _formatDate(createdAt),
                            style: TextStyle(
                              color: Color(0XFF3D3D3D),
                              fontSize: _getResponsiveFontSize(context, 16),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 4 : 8),
                        Expanded(
                          flex: isSmallScreen ? 4 : 3,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color(0Xff112E5B),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 6 : 10,
                                vertical: isSmallScreen ? 6 : 8,
                              ),
                              minimumSize: Size(0, isSmallScreen ? 32 : 36),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OrderScreen(orderId: orderId),
                                ),
                              );
                            },
                            child: Text(
                              'تفاصيل',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _getResponsiveFontSize(context, 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: CustomGradientDivider(),
                  ),
                ],
              );
            }).toList(),
          ],
        );
      },
    );
  }

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
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
            backgroundColor: Colors.white,
            // resizeToAvoidBottomInset: false,
            appBar: AppBar(
              elevation: 0.0,
              centerTitle: true,
              backgroundColor: Colors.white,
              toolbarHeight: kToolbarHeight,
              leadingWidth: MediaQuery.of(context).size.width < 360 ? 250 : 300,
              leading: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width < 360 ? 10 : 20),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        color: Color(0XFF575757),
                        Icons.arrow_back,
                        size: MediaQuery.of(context).size.width < 360
                            ? 26.0
                            : 30.0,
                      ),
                    ),
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width < 360 ? 10 : 20),
                  Text('طلباتي',
                      style: TextStyle(
                        color: Color(0XFF3D3D3D),
                        fontSize: _getResponsiveFontSize(context, 20),
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
              bottom: TabBar(
                indicatorColor: Color(0XFF707070),
                tabs: [
                  Tab(
                    child: Text('حالية',
                        style: TextStyle(
                          color: Color(0XFF3D3D3D),
                          fontSize: _getResponsiveFontSize(context, 18),
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                  Tab(
                    child: Text('ملغية',
                        style: TextStyle(
                          color: Color(0XFF3D3D3D),
                          fontSize: _getResponsiveFontSize(context, 18),
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                  Tab(
                    child: Text('تم التسليم',
                        style: TextStyle(
                          color: Color(0XFF3D3D3D),
                          fontSize: _getResponsiveFontSize(context, 18),
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // Tab 1: حالية (pending, confirmed, preparing, ready)
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: _buildOrdersList(
                      null), // null = all orders, ثم نفلتر في الواجهة
                ),
                // Tab 2: ملغية (cancelled)
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: _buildOrdersList('cancelled'),
                ),
                // Tab 3: تم التسليم (delivered)
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: _buildOrdersList('delivered'),
                ),
              ],
            )),
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
