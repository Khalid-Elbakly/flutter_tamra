import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current client ID
  String? get _clientId => _auth.currentUser?.uid;

  /// إضافة عنوان جديد
  Future<Map<String, dynamic>> addAddress({
    required String addressName,
    required String addressDescription,
  }) async {
    try {
      final clientId = _clientId;
      if (clientId == null) {
        return {'success': false, 'message': 'يجب تسجيل الدخول أولاً'};
      }

      if (addressName.trim().isEmpty) {
        return {'success': false, 'message': 'من فضلك أدخل اسم العنوان'};
      }

      if (addressDescription.trim().isEmpty) {
        return {'success': false, 'message': 'من فضلك أدخل وصف العنوان'};
      }

      // إضافة العنوان في subcollection
      final addressRef = _firestore
          .collection('clients')
          .doc(clientId)
          .collection('addresses')
          .doc();

      await addressRef.set({
        'addressId': addressRef.id,
        'addressName': addressName.trim(),
        'addressDescription': addressDescription.trim(),
        'isDefault': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'تم إضافة العنوان بنجاح',
        'addressId': addressRef.id,
      };
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ: ${e.toString()}'};
    }
  }

  /// جلب جميع عناوين العميل
  Stream<QuerySnapshot> getClientAddresses() {
    final clientId = _clientId;
    if (clientId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('clients')
        .doc(clientId)
        .collection('addresses')
        .snapshots();
  }

  /// جلب عنوان واحد
  Future<DocumentSnapshot?> getAddress(String addressId) async {
    try {
      final clientId = _clientId;
      if (clientId == null) return null;

      return await _firestore
          .collection('clients')
          .doc(clientId)
          .collection('addresses')
          .doc(addressId)
          .get();
    } catch (e) {
      print('خطأ في جلب العنوان: $e');
      return null;
    }
  }

  /// تحديث عنوان
  Future<Map<String, dynamic>> updateAddress({
    required String addressId,
    required String addressName,
    required String addressDescription,
  }) async {
    try {
      final clientId = _clientId;
      if (clientId == null) {
        return {'success': false, 'message': 'يجب تسجيل الدخول أولاً'};
      }

      if (addressName.trim().isEmpty) {
        return {'success': false, 'message': 'من فضلك أدخل اسم العنوان'};
      }

      if (addressDescription.trim().isEmpty) {
        return {'success': false, 'message': 'من فضلك أدخل وصف العنوان'};
      }

      await _firestore
          .collection('clients')
          .doc(clientId)
          .collection('addresses')
          .doc(addressId)
          .update({
        'addressName': addressName.trim(),
        'addressDescription': addressDescription.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'تم تحديث العنوان بنجاح',
      };
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ: ${e.toString()}'};
    }
  }

  /// حذف عنوان
  Future<Map<String, dynamic>> deleteAddress(String addressId) async {
    try {
      final clientId = _clientId;
      if (clientId == null) {
        return {'success': false, 'message': 'يجب تسجيل الدخول أولاً'};
      }

      await _firestore
          .collection('clients')
          .doc(clientId)
          .collection('addresses')
          .doc(addressId)
          .delete();

      return {
        'success': true,
        'message': 'تم حذف العنوان بنجاح',
      };
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ: ${e.toString()}'};
    }
  }

  /// تعيين عنوان كافتراضي
  Future<Map<String, dynamic>> setDefaultAddress(String addressId) async {
    try {
      final clientId = _clientId;
      if (clientId == null) {
        return {'success': false, 'message': 'يجب تسجيل الدخول أولاً'};
      }

      // إزالة الافتراضي من جميع العناوين
      final addressesSnapshot = await _firestore
          .collection('clients')
          .doc(clientId)
          .collection('addresses')
          .get();

      final batch = _firestore.batch();
      for (var doc in addressesSnapshot.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
      await batch.commit();

      // تعيين العنوان المحدد كافتراضي
      await _firestore
          .collection('clients')
          .doc(clientId)
          .collection('addresses')
          .doc(addressId)
          .update({
        'isDefault': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'تم تعيين العنوان كافتراضي',
      };
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ: ${e.toString()}'};
    }
  }
}





