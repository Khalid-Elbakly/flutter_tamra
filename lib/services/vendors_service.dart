import 'package:cloud_firestore/cloud_firestore.dart';

class VendorsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// جلب جميع البائعين
  Stream<QuerySnapshot> getAllVendors() {
    return _firestore
        .collection('vendors')
        .where('userType', isEqualTo: 'vendor')
        .snapshots();
  }

  /// جلب بائع واحد
  Future<DocumentSnapshot?> getVendor(String vendorId) async {
    try {
      return await _firestore.collection('vendors').doc(vendorId).get();
    } catch (e) {
      print('خطأ في جلب البائع: $e');
      return null;
    }
  }

  /// جلب عدد المنتجات النشطة للبائع
  Future<int> getVendorProductsCount(String vendorId) async {
    try {
      final productsSnapshot = await _firestore
          .collection('products')
          .where('vendorId', isEqualTo: vendorId)
          .where('isActive', isEqualTo: true)
          .get();
      
      return productsSnapshot.docs.length;
    } catch (e) {
      print('خطأ في جلب عدد المنتجات: $e');
      return 0;
    }
  }
}


