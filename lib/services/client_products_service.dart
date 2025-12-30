import 'package:cloud_firestore/cloud_firestore.dart';

class ClientProductsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// جلب جميع المنتجات النشطة للبائع
  Stream<QuerySnapshot> getVendorProducts(String vendorId, {String? category}) {
    Query query = _firestore
        .collection('products')
        .where('vendorId', isEqualTo: vendorId)
        .where('isActive', isEqualTo: true);
    // Note: orderBy requires composite index - removed for now
    // Can be added later or sort in app code

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots();
  }

  /// جلب جميع المنتجات النشطة (من جميع البائعين)
  Stream<QuerySnapshot> getAllActiveProducts({String? category, String? searchQuery}) {
    Query query = _firestore
        .collection('products')
        .where('isActive', isEqualTo: true);
    // Note: orderBy requires composite index - removed for now
    // Can be added later or sort in app code

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots();
  }

  /// جلب منتج واحد
  Future<DocumentSnapshot?> getProduct(String vendorId, String productId) async {
    try {
      return await _firestore
          .collection('products')
          .doc(productId)
          .get();
    } catch (e) {
      print('خطأ في جلب المنتج: $e');
      return null;
    }
  }

  /// جلب الفئات المتاحة من منتجات بائع معين
  Future<List<String>> getVendorCategories(String vendorId) async {
    try {
      final productsSnapshot = await _firestore
          .collection('products')
          .where('vendorId', isEqualTo: vendorId)
          .where('isActive', isEqualTo: true)
          .get();

      Set<String> categories = {};
      for (var doc in productsSnapshot.docs) {
        final data = doc.data();
        if (data['category'] != null) {
          categories.add(data['category'] as String);
        }
      }

      return categories.toList();
    } catch (e) {
      print('خطأ في جلب الفئات: $e');
      return [];
    }
  }
}

