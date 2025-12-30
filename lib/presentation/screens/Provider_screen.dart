import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tamra/services/client_products_service.dart';
import 'package:tamra/services/vendors_service.dart';
import 'package:tamra/providers/cart_provider.dart';
import 'package:tamra/models/cart_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderScreen extends StatefulWidget {
  final String vendorId;
  final Map<String, dynamic> vendorData;

  const ProviderScreen({
    Key? key,
    required this.vendorId,
    required this.vendorData,
  }) : super(key: key);

  @override
  State<ProviderScreen> createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {
  final ClientProductsService _productsService = ClientProductsService();
  final VendorsService _vendorsService = VendorsService();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  int _selected = 0; // 0 = الكل، 1 = فواكه، 2 = خضار، إلخ

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateQuantity(String productId, int delta, Map<String, dynamic> product) {
    // إضافة/تحديث المنتج في السلة مباشرة
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartItem = cartProvider.cart.getItem(productId);
    final currentQuantity = cartItem?.quantity ?? 0;
    final newQuantity = currentQuantity + delta;
    
    if (newQuantity > 0) {
      // إذا كان المنتج موجود بالفعل، استخدم updateQuantity
      if (cartItem != null) {
        cartProvider.updateQuantity(productId, newQuantity);
      } else {
        // إذا كان المنتج غير موجود، أضفه جديد
        final newItem = CartItem(
          productId: productId,
          nameAr: product['nameAr'] ?? '',
          nameEn: product['nameEn'] ?? '',
          price: (product['price'] as num?)?.toDouble() ?? 0.0,
          packagingWeight: product['packagingWeight'] ?? '',
          imageUrl: product['imageUrl'] ?? '',
          vendorId: product['vendorId'] ?? '',
          quantity: newQuantity,
        );
        cartProvider.addItem(newItem);
      }
    } else {
      cartProvider.removeItem(productId);
    }
  }

  // Helper widget to display price with riyal symbol
  Widget _buildPriceWithSymbol(BuildContext context, double price, {double? fontSize, FontWeight? fontWeight, Color? color}) {
    final effectiveFontSize = fontSize ?? 14.0;
    final effectiveFontWeight = fontWeight ?? FontWeight.w500;
    final effectiveColor = color ?? Color(0XFF5B5B5B);
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

  void _selectCategory(int categoryIndex) {
    setState(() {
      // إذا كانت الفئة المحددة هي نفس الفئة النشطة حالياً، قم بإلغاء الفلتر
      if (_selected == categoryIndex) {
        _selected = 0;
        _selectedCategory = null; // الكل
      } else {
        _selected = categoryIndex;
        // تحديد الفئة حسب الاختيار
        switch (categoryIndex) {
          case 1:
            _selectedCategory = 'فواكه';
            break;
          case 2:
            _selectedCategory = 'خضار';
            break;
          case 3:
            _selectedCategory = 'ورقيات';
            break;
          default:
            _selectedCategory = null; // الكل
        }
      }
    });
  }

  Widget _buildCategoryFilter({
    required int categoryIndex,
    required String categoryName,
    required String iconPath,
    required String iconLightPath,
    double borderWidth = 1.0,
  }) {
    final isSelected = _selected == categoryIndex;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectCategory(categoryIndex),
        borderRadius: BorderRadius.circular(20),
        child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0XFF7C3425) : Color(0XFFD1D1D1),
            width: borderWidth,
            style: BorderStyle.solid,
          ),
          color: isSelected ? Color(0XFF7C3425) : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              isSelected ? iconLightPath : iconPath,
              height: 30,
            ),
            SizedBox(width: 10),
            Text(
              categoryName,
              style: TextStyle(
                color: isSelected ? Colors.white : Color(0XFF909090),
                fontSize: 18,
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selected = 0;
                    _selectedCategory = null;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
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
    final vendorName = widget.vendorData['businessName'] ?? 
                      widget.vendorData['name'] ?? 
                      widget.vendorData['nameAr'] ?? 
                      widget.vendorData['phoneNumber'] ?? 
                      'بائع';
    final vendorImage = widget.vendorData['imageUrl'] ?? 
                       widget.vendorData['logoUrl'] ?? 
                       '';
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
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    color: Color(0XFF575757),
                    Icons.arrow_back,
                    size: 30.0,
                  ),
                ),
              ),
              SizedBox(width: 20),
              Text(
                vendorName,
                style: TextStyle(
                  color: Color(0XFF3D3D3D),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    vendorImage.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              vendorImage,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/store1.png',
                                  width: 100,
                                );
                              },
                            ),
                          )
                        : Image.asset('assets/images/store1.png', width: 100),
                    SizedBox(width: 10),
                    FutureBuilder<int>(
                      future: _vendorsService.getVendorProductsCount(widget.vendorId),
                      builder: (context, snapshot) {
                        final productsCount = snapshot.data ?? 0;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vendorName,
                              style: TextStyle(
                                color: Color(0XFF5B5B5B),
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$productsCount منتج',
                              style: TextStyle(
                                color: Color(0XFF5B5B5B),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: Icon(Icons.search),
                          hintText: 'البحث عن منتج',
                        ),
                        onChanged: (value) {
                          // يمكن إضافة وظيفة البحث هنا لاحقاً
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildCategoryFilter(
                        categoryIndex: 1,
                        categoryName: 'فواكه',
                        iconPath: 'assets/images/ic_cat_1.png',
                        iconLightPath: 'assets/images/ic_cat_1_light.png',
                        borderWidth: 2.0,
                      ),
                      SizedBox(width: 10),
                      _buildCategoryFilter(
                        categoryIndex: 2,
                        categoryName: 'خضار',
                        iconPath: 'assets/images/ic_cat_2.png',
                        iconLightPath: 'assets/images/ic_cat_2_light.png',
                        borderWidth: 1.0,
                      ),
                      SizedBox(width: 10),
                      _buildCategoryFilter(
                        categoryIndex: 3,
                        categoryName: 'ورقيات',
                        iconPath: 'assets/images/ic_cat_3.png',
                        iconLightPath: 'assets/images/ic_cat_3_light.png',
                        borderWidth: 1.0,
                      ),
                      SizedBox(width: 10),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Color(0XFFD1D1D1),
                              width: 1.0,
                              style: BorderStyle.solid),
                          color: Colors.white,
                        ),
                        child: Row(children: [
                          Image.asset('assets/images/ic_cat_4.png', height: 30),
                          SizedBox(
                            width: 10,
                          ),
                          Text('حمضيات',
                              style: TextStyle(
                                color: Color(0XFF909090),
                                fontSize: 18,
                              )),
                        ]),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      // Container(
                      //   padding:
                      //       EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(20),
                      //     border: Border.all(
                      //         color: Color(0XFFD1D1D1),
                      //         width: 1.0,
                      //         style: BorderStyle.solid),
                      //     color: Colors.white,
                      //   ),
                      //   child: Row(children: [
                      //     Image.asset('assets/images/ic_cat_5.png', height: 30),
                      //     SizedBox(
                      //       width: 10,
                      //     ),
                      //     Text('استوائة',
                      //         style: TextStyle(
                      //           color: Color(0XFF909090),
                      //           fontSize: 18,
                      //         )),
                      //   ]),
                      // ),
                      // SizedBox(
                      //   width: 10,
                      // ),
                      // Container(
                      //   padding:
                      //       EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(20),
                      //     border: Border.all(
                      //         color: Color(0XFFD1D1D1),
                      //         width: 1.0,
                      //         style: BorderStyle.solid),
                      //     color: Colors.white,
                      //   ),
                      //   child: Row(children: [
                      //     Image.asset('assets/images/ic_cat_6.png', height: 30),
                      //     SizedBox(
                      //       width: 10,
                      //     ),
                      //     Text('محليه',
                      //         style: TextStyle(
                      //           color: Color(0XFF909090),
                      //           fontSize: 18,
                      //         )),
                      //   ]),
                      // ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _productsService.getVendorProducts(
                      widget.vendorId,
                      category: _selectedCategory,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListView(
                          children: List.generate(5, (index) {
                            return Container(
                              padding: EdgeInsets.only(top: 15, bottom: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    width: 0.5,
                                    style: BorderStyle.solid,
                                    color: Color(0XFF707070),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            color: Color(0XFFE0E0E0),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 20,
                                                width: 150,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(4),
                                                  color: Color(0XFFE0E0E0),
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Container(
                                                height: 16,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(4),
                                                  color: Color(0XFFE0E0E0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
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
                                            children: [
                                              Container(
                                                width: 45,
                                                height: 45,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(4),
                                                  color: Color(0XFFE0E0E0),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(1),
                                                  border: Border.all(
                                                    color: Color(0XFFD1D1D1),
                                                    width: 1.0,
                                                    style: BorderStyle.solid,
                                                  ),
                                                  color: Color(0XFFE0E0E0),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Container(
                                                width: 45,
                                                height: 45,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(4),
                                                  color: Color(0XFFE0E0E0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
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
                                  : 'حدث خطأ في تحميل المنتجات',
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
                          child: Text(
                            'لا توجد منتجات',
                            style: TextStyle(
                              color: Color(0XFF5B5B5B),
                              fontSize: 18,
                            ),
                          ),
                        );
                      }

                      final products = snapshot.data!.docs;

                      return Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          return ListView(
                            children: [
                          ...products.map((doc) {
                            final product = doc.data() as Map<String, dynamic>;
                            final productId = doc.id;
                            final nameAr = product['nameAr'] as String? ?? '';
                            final price = product['price'] as num? ?? 0.0;
                            final packagingWeight = product['packagingWeight'] as String? ?? '';
                            final imageUrl = product['imageUrl'] as String? ?? '';
                            final quantity = cartProvider.cart.getItem(productId)?.quantity ?? 0;

                        return Container(
                          padding: EdgeInsets.only(top: 15, bottom: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                width: 0.5,
                                style: BorderStyle.solid,
                                color: Color(0XFF707070),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    imageUrl.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              imageUrl,
                                              height: 90,
                                              width: 90,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/images/pr_1.png',
                                                  height: 90,
                                                );
                                              },
                                            ),
                                          )
                                        : Image.asset(
                                            'assets/images/pr_1.png',
                                            height: 90,
                                          ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nameAr,
                                          style: TextStyle(
                                            color: Color(0XFF5B5B5B),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        _buildPriceWithSymbol(
                                          context,
                                          price.toDouble(),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        if (packagingWeight.isNotEmpty)
                                          Text(
                                            packagingWeight,
                                            style: TextStyle(
                                              color: Color(0XFF5B5B5B),
                                              fontSize: 14,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // إذا كانت الكمية 0، عرض زر إضافة مباشر
                                    if (quantity == 0)
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _updateQuantity(productId, 1, product),
                                          borderRadius: BorderRadius.circular(25),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(25),
                                              color: Color(0XFF7C3425),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color(0XFF7C3425).withOpacity(0.3),
                                                  spreadRadius: 0,
                                                  blurRadius: 8,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.add_shopping_cart,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'إضافة',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      // إذا كانت الكمية أكبر من 0، عرض أزرار + و - و الكمية
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
                                                onTap: () => _updateQuantity(productId, 1, product),
                                                borderRadius: BorderRadius.circular(25),
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
                                                borderRadius: BorderRadius.circular(1),
                                                border: Border.all(
                                                  color: Color(0XFFD1D1D1),
                                                  width: 1.0,
                                                  style: BorderStyle.solid,
                                                ),
                                                color: Colors.white,
                                              ),
                                              child: Text(
                                                quantity.toString(),
                                                style: TextStyle(
                                                  color: Color(0XFF5B5B5B),
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            // زر النقصان (على اليسار في RTL)
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () => _updateQuantity(productId, -1, product),
                                                borderRadius: BorderRadius.circular(25),
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
                            ],
                          ),
                        );
                      }).toList(),
                            ],
                          );
                        },
                      );
                    },
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
