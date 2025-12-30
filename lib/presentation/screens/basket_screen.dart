import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamra/presentation/screens/order_success_screen.dart';
import 'package:tamra/presentation/screens/addresses_screen.dart';
import 'package:tamra/services/orders_service.dart';
import 'package:tamra/services/auth_service.dart';
import 'package:tamra/providers/cart_provider.dart';
import 'package:tamra/models/cart_item.dart';
import 'package:tamra/presentation/widgets/custom_gradient_divider.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({Key? key}) : super(key: key);
  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  final OrdersService _ordersService = OrdersService();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _selectedAddressId;
  String? _clientAddress;
  String? _clientAddressName;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  // Helper widget to display price with riyal symbol
  Widget _buildPriceWithSymbol(BuildContext context, double price,
      {double? fontSize, FontWeight? fontWeight, Color? color}) {
    final effectiveFontSize = fontSize ?? 16.0;
    final effectiveFontWeight = fontWeight ?? FontWeight.w600;
    final effectiveColor = color ?? Color(0XFF7C3425);
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

  Future<void> _loadDefaultAddress() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      // جلب العنوان الافتراضي
      final addressesSnapshot = await _firestore
          .collection('clients')
          .doc(user.uid)
          .collection('addresses')
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (addressesSnapshot.docs.isNotEmpty && mounted) {
        final addressData = addressesSnapshot.docs.first.data();
        setState(() {
          _selectedAddressId = addressesSnapshot.docs.first.id;
          _clientAddress = addressData['addressDescription'] ?? '';
          _clientAddressName = addressData['addressName'] ?? '';
        });
      } else {
        // إذا لم يوجد عنوان افتراضي، جلب أول عنوان
        final allAddressesSnapshot = await _firestore
            .collection('clients')
            .doc(user.uid)
            .collection('addresses')
            .limit(1)
            .get();

        if (allAddressesSnapshot.docs.isNotEmpty && mounted) {
          final addressData = allAddressesSnapshot.docs.first.data();
          setState(() {
            _selectedAddressId = allAddressesSnapshot.docs.first.id;
            _clientAddress = addressData['addressDescription'] ?? '';
            _clientAddressName = addressData['addressName'] ?? '';
          });
        }
      }
    } catch (e) {
      // Error loading address
    }
  }

  Future<void> _selectAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressesScreen(
          selectedAddressId: _selectedAddressId,
          onAddressSelected: (addressId, addressName, addressDescription) {
            setState(() {
              _selectedAddressId = addressId;
              _clientAddress = addressDescription;
              _clientAddressName = addressName;
            });
          },
        ),
      ),
    );

    // إعادة تحميل العنوان بعد العودة
    if (result == true) {
      _loadDefaultAddress();
    }
  }

  Future<void> _createOrder() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cart = cartProvider.cart;

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('السلة فارغة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (cart.vendorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ في تحديد البائع'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedAddressId == null ||
        _clientAddress == null ||
        _clientAddress!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار عنوان التوصيل'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _ordersService.createOrder(
      vendorId: cart.vendorId!,
      items: cart.toOrderItemsList(),
      deliveryAddress: _clientAddress!,
      deliveryAddressName: _clientAddressName ?? '',
      deliveryFee: cart.deliveryFee,
      deliveryAddressId: _selectedAddressId,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true && mounted) {
      // حفظ البيانات قبل مسح السلة
      final savedItems = List<CartItem>.from(cart.items);
      final savedDeliveryAddress = _clientAddress ?? '';
      final savedDeliveryAddressName = _clientAddressName ?? '';
      final savedDeliveryFee = cart.deliveryFee;
      final savedTotal = cart.total;

      cartProvider.clear();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(
            deliveryAddress: savedDeliveryAddress,
            deliveryAddressName: savedDeliveryAddressName,
            items: savedItems,
            deliveryFee: savedDeliveryFee,
            total: savedTotal,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'فشل إنشاء الطلب'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cart = cartProvider.cart;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('السلة',
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                                color: Color(0XFF3D3D3D))),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0XFFF4F6F9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // البائع - بطاقة منفصلة
                          if (cart.vendorId != null)
                            Container(
                              padding: EdgeInsets.all(15),
                              margin: EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0XFF7C3425).withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: FutureBuilder<DocumentSnapshot?>(
                                future: _firestore
                                    .collection('vendors')
                                    .doc(cart.vendorId)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Row(
                                      textDirection: TextDirection.rtl,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0XFFE0E0E0),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Container(
                                          height: 18,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: Color(0XFFE0E0E0),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  String vendorName = 'البائع';
                                  if (snapshot.hasData &&
                                      snapshot.data != null &&
                                      snapshot.data!.exists) {
                                    final data = snapshot.data!.data()
                                        as Map<String, dynamic>?;
                                    vendorName = data?['businessName'] ??
                                        data?['nameAr'] ??
                                        data?['name'] ??
                                        data?['phoneNumber'] ??
                                        'البائع';
                                  }
                                  return Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0XFF7C3425)
                                              .withOpacity(0.1),
                                        ),
                                        child: Icon(
                                          Icons.store,
                                          color: Color(0XFF7C3425),
                                          size: 22,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'المتجر',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0XFF909090),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              vendorName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Color(0XFF7C3425),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          // العنوان - بطاقة منفصلة
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(0XFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            Color(0XFF1EB7CD).withOpacity(0.1),
                                      ),
                                      child: Icon(
                                        Icons.location_on,
                                        color: Color(0XFF1EB7CD),
                                        size: 22,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'عنوان التوصيل',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0XFF3D3D3D),
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          // اسم العنوان
                                          if (_clientAddressName == null &&
                                              _clientAddress == null)
                                            // Placeholder أثناء التحميل
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 16,
                                                  width: 120,
                                                  margin: EdgeInsets.only(
                                                      bottom: 6),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    color: Color(0XFFE0E0E0),
                                                  ),
                                                ),
                                                Container(
                                                  height: 14,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    color: Color(0XFFE0E0E0),
                                                  ),
                                                ),
                                              ],
                                            )
                                          else
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (_clientAddressName !=
                                                        null &&
                                                    _clientAddressName!
                                                        .isNotEmpty)
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: Color(0XFF7C3425)
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Text(
                                                      _clientAddressName!,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Color(0XFF7C3425),
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                if (_clientAddressName !=
                                                        null &&
                                                    _clientAddressName!
                                                        .isNotEmpty)
                                                  SizedBox(height: 8),
                                                Text(
                                                  _clientAddress ??
                                                      'لم يتم تحديد العنوان',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0XFF3D3D3D),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                // زر تغيير العنوان
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Color(0XFF7C3425),
                                      side: BorderSide(
                                        color: Color(0XFF7C3425),
                                        width: 1.5,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: _selectAddress,
                                    icon:
                                        Icon(Icons.edit_location_alt, size: 18),
                                    label: Text(
                                      'تغيير العنوان',
                                      style: TextStyle(
                                        color: Color(0XFF7C3425),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    // عنوان الأصناف
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'الأصناف',
                          style: TextStyle(
                            color: Color(0XFF3D3D3D),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.shopping_cart,
                          color: Color(0XFF7C3425),
                          size: 22,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    CustomGradientDivider(),
                    if (cart.isEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: Color(0XFFD1D1D1),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'السلة فارغة',
                              style: TextStyle(
                                color: Color(0XFF5B5B5B),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...cart.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isLast = index == cart.items.length - 1;

                        return Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // معلومات المنتج (على الشمال في RTL - أقصى الشمال)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.nameAr,
                                          style: TextStyle(
                                            color: Color(0XFF3D3D3D),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.left,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 10),
                                        _buildPriceWithSymbol(
                                          context,
                                          item.totalPrice,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0XFF7C3425),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  // أزرار الكمية (على اليمين في RTL - أقصى اليمين)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Color(0XFFeeeeee),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      textDirection: TextDirection.rtl,
                                      children: [
                                        // زر الإضافة (على اليمين في RTL)
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              cartProvider.updateQuantity(
                                                item.productId,
                                                item.quantity + 1,
                                              );
                                            },
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            child: Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Image.asset(
                                                'assets/images/add_icon.png',
                                                height: 45,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        // الكمية في المنتصف
                                        Container(
                                          alignment: Alignment.center,
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(1),
                                            border: Border.all(
                                              color: Color(0XFFD1D1D1),
                                              width: 1.0,
                                              style: BorderStyle.solid,
                                            ),
                                            color: Colors.white,
                                          ),
                                          child: Text(
                                            '${item.quantity}',
                                            style: TextStyle(
                                              color: Color(0XFF5B5B5B),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        // زر النقصان (على اليسار في RTL)
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              cartProvider.updateQuantity(
                                                item.productId,
                                                item.quantity - 1,
                                              );
                                            },
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            child: Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Image.asset(
                                                'assets/images/min_icon.png',
                                                height: 45,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast) SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    if (!cart.isEmpty) ...[
                      SizedBox(height: 10),
                      CustomGradientDivider(),
                    ],
                    if (!cart.isEmpty) ...[
                      SizedBox(height: 15),
                      // التوصيل
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        decoration: BoxDecoration(
                          color: Color(0XFFF4F6F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'التوصيل',
                              style: TextStyle(
                                color: Color(0XFF5B5B5B),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            _buildPriceWithSymbol(
                              context,
                              cart.deliveryFee,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0XFF5B5B5B),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      // الإجمالي
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(
                          color: Color(0XFF7C3425).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0XFF7C3425).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'الإجمالي',
                              style: TextStyle(
                                color: Color(0XFF7C3425),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _buildPriceWithSymbol(
                              context,
                              cart.total,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0XFF7C3425),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(
                      height: 20,
                    ),
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
                          onPressed:
                              _isLoading || cart.isEmpty ? null : _createOrder,
                          child: _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Text('الدفع',
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
                    SizedBox(
                      height: 10,
                    )
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
