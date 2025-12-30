import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_sender_service.dart';

class OrdersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationSenderService _notificationSender = NotificationSenderService();

  // Get current client ID
  String? get _clientId => _auth.currentUser?.uid;

  /// إنشاء طلب جديد
  Future<Map<String, dynamic>> createOrder({
    required String vendorId,
    required List<Map<String, dynamic>> items, // [{productId, nameAr, quantity, price, packagingWeight}]
    required String deliveryAddress,
    required String deliveryAddressName,
    double deliveryFee = 0.0,
    String? deliveryAddressId, // ID العنوان من addresses collection
  }) async {
    try {
      final clientId = _clientId;
      if (clientId == null) {
        return {'success': false, 'message': 'يجب تسجيل الدخول أولاً'};
      }

      if (items.isEmpty) {
        return {'success': false, 'message': 'السلة فارغة'};
      }

      // حساب الإجمالي
      double total = 0.0;
      for (var item in items) {
        final quantity = item['quantity'] as int? ?? 0;
        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
        total += quantity * price;
      }
      total += deliveryFee;

      // إنشاء الطلب في Firestore
      final orderRef = _firestore.collection('orders').doc();
      final orderNumber = _generateOrderNumber();

      await orderRef.set({
        'orderId': orderRef.id,
        'orderNumber': orderNumber,
        'clientId': clientId,
        'vendorId': vendorId,
        'items': items,
        'deliveryAddress': deliveryAddress,
        'deliveryAddressName': deliveryAddressName,
        'deliveryAddressId': deliveryAddressId,
        'deliveryFee': deliveryFee,
        'subtotal': total - deliveryFee,
        'total': total,
        'status': 'pending', // pending, confirmed, preparing, ready, delivered, cancelled
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // إرسال إشعار للتاجر
      try {
        final clientDoc = await _firestore.collection('clients').doc(clientId).get();
        final clientData = clientDoc.data();
        final clientName = clientData?['name'] as String? ?? 'عميل';
        
        _notificationSender.sendNewOrderNotification(
          vendorId: vendorId,
          orderId: orderRef.id,
          orderNumber: orderNumber,
          clientName: clientName,
        );
      } catch (e) {
        // خطأ في إرسال الإشعار (لا يؤثر على إنشاء الطلب)
      }

      return {
        'success': true,
        'message': 'تم إنشاء الطلب بنجاح',
        'orderId': orderRef.id,
      };
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ: ${e.toString()}'};
    }
  }

  /// جلب طلبات العميل
  Stream<QuerySnapshot> getClientOrders({String? status}) {
    final clientId = _clientId;
    if (clientId == null) {
      return const Stream.empty();
    }

    Query query = _firestore
        .collection('orders')
        .where('clientId', isEqualTo: clientId);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    // Note: Removed orderBy to avoid composite index requirement
    // Sorting will be done in the UI code if needed
    return query.snapshots();
  }

  /// جلب طلب واحد
  Future<DocumentSnapshot?> getOrder(String orderId) async {
    try {
      return await _firestore.collection('orders').doc(orderId).get();
    } catch (e) {
      print('خطأ في جلب الطلب: $e');
      return null;
    }
  }

  /// توليد رقم طلب عشوائي
  String _generateOrderNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return '#$random';
  }
}

