import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tamra/presentation/screens/Provider_screen.dart';
import 'package:tamra/services/vendors_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({Key? key}) : super(key: key);
  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  final VendorsService _vendorsService = VendorsService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'الموردين',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0XFF3D3D3D),
                            fontFamily: 'IBMPlex',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Search Field
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Color(0XFFD1D1D1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Color(0XFFD1D1D1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Color(0XFF7C3425), width: 2),
                        ),
                        prefixIcon: Icon(Icons.search, color: Color(0XFF707070)),
                        hintText: 'ابحث عن مورد...',
                        hintStyle: TextStyle(
                          color: Color(0XFF909090),
                          fontFamily: 'IBMPlex',
                        ),
                        filled: true,
                        fillColor: Color(0XFFF4F6F9),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim();
                        });
                      },
                    ),
                  ],
                ),
              ),
              // Vendors List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _vendorsService.getAllVendors(),
                  builder: (context, snapshot) {
                    return AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: _buildVendorsContent(snapshot),
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

  Widget _buildVendorPlaceholderCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Color(0XFFE5E5E5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0XFFE0E0E0),
            ),
          ),
          SizedBox(height: 15),
          Container(
            height: 20,
            width: 120,
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Color(0XFFE0E0E0),
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0XFFE0E0E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              height: 16,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Color(0XFFD0D0D0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorsContent(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
      // عرض placeholder أثناء تحميل قائمة الموردين
      return GridView.builder(
        key: ValueKey('vendors_loading'),
        padding: EdgeInsets.all(15),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 20,
          childAspectRatio: 0.75,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return _buildVendorPlaceholderCard();
        },
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
        key: ValueKey('vendors_error'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isNetworkError ? Icons.wifi_off : Icons.error_outline,
              size: 80,
              color: Color(0XFFD1D1D1),
            ),
            SizedBox(height: 20),
            Text(
              isNetworkError 
                ? 'لا يوجد اتصال بالإنترنت'
                : 'حدث خطأ في تحميل البيانات',
              style: TextStyle(
                fontSize: 20,
                color: Color(0XFF5B5B5B),
                fontFamily: 'IBMPlex',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              isNetworkError
                ? 'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى'
                : 'يرجى المحاولة مرة أخرى',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0XFF909090),
                fontFamily: 'IBMPlex',
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  // إعادة بناء الـ StreamBuilder
                });
              },
              icon: Icon(Icons.refresh),
              label: Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0XFF7C3425),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (snapshot.data!.docs.isEmpty) {
      return Center(
        key: ValueKey('vendors_empty'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 80,
              color: Color(0XFFD1D1D1),
            ),
            SizedBox(height: 20),
            Text(
              'لا يوجد موردين',
              style: TextStyle(
                fontSize: 20,
                color: Color(0XFF5B5B5B),
                fontFamily: 'IBMPlex',
              ),
            ),
          ],
        ),
      );
    }

    var vendors = snapshot.data!.docs;

    // Filter vendors based on search query
    if (_searchQuery.isNotEmpty) {
      vendors = vendors.where((doc) {
        final vendorData = doc.data() as Map<String, dynamic>;
        final name = ((vendorData['businessName'] ?? 
                     vendorData['name'] ?? 
                     vendorData['nameAr'] ?? 
                     vendorData['phoneNumber'] ?? 
                     '') as String).toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (vendors.isEmpty) {
      return Center(
        key: ValueKey('vendors_search_empty'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Color(0XFFD1D1D1),
            ),
            SizedBox(height: 20),
            Text(
              'لا توجد نتائج للبحث',
              style: TextStyle(
                fontSize: 20,
                color: Color(0XFF5B5B5B),
                fontFamily: 'IBMPlex',
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      key: ValueKey('vendors_${vendors.length}_${_searchQuery}'),
      padding: EdgeInsets.all(15),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 20,
        childAspectRatio: 0.75,
      ),
      itemCount: vendors.length,
      itemBuilder: (context, index) {
        final vendorDoc = vendors[index];
        final vendorData = vendorDoc.data() as Map<String, dynamic>;
        final vendorId = vendorDoc.id;
        final vendorName = vendorData['businessName'] ?? 
                         vendorData['name'] ?? 
                         vendorData['nameAr'] ?? 
                         vendorData['phoneNumber'] ?? 
                         'بائع';
        final vendorImage = vendorData['imageUrl'] ?? 
                          vendorData['logoUrl'] ?? 
                          '';

        return _VendorCard(
          vendorId: vendorId,
          vendorName: vendorName,
          imageUrl: vendorImage,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProviderScreen(
                  vendorId: vendorId,
                  vendorData: vendorData,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _VendorCard extends StatelessWidget {
  final String vendorId;
  final String vendorName;
  final String? imageUrl;
  final VoidCallback onTap;

  const _VendorCard({
    required this.vendorId,
    required this.vendorName,
    this.imageUrl,
    required this.onTap,
  });

  Widget _buildCardPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Color(0XFFE5E5E5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0XFFE0E0E0),
            ),
          ),
          SizedBox(height: 15),
          Container(
            height: 20,
            width: 120,
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Color(0XFFE0E0E0),
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0XFFE0E0E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              height: 16,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Color(0XFFD0D0D0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: VendorsService().getVendorProductsCount(vendorId),
      builder: (context, snapshot) {
        // إذا كان في حالة تحميل، عرض placeholder للبطاقة
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCardPlaceholder();
        }
        
        final count = snapshot.data ?? 0;
        
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: Color(0XFFE5E5E5),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Vendor Image
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0XFF7C3425).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? Image.network(
                            imageUrl!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/store1.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/store1.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                SizedBox(height: 15),
                // Vendor Name
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    vendorName,
                    style: TextStyle(
                      color: Color(0XFF3D3D3D),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlex',
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 8),
                // Products Count
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0XFF7C3425).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color: Color(0XFF7C3425),
                      ),
                      SizedBox(width: 5),
                      Text(
                        '$count منتج',
                        style: TextStyle(
                          color: Color(0XFF7C3425),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'IBMPlex',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
