import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;

class NotificationSenderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Project ID من Firebase Console
  static const String _projectId = 'tamra-f6dab'; // من google-services.json
  
  // Service Account JSON - يجب تحميله من Firebase Console
  // TODO: ضع ملف service-account.json في assets/credentials/
  // وأضفه إلى pubspec.yaml في قسم assets
  static const String _serviceAccountPath = 'assets/credentials/service-account.json';
  
  // Cache للـ access token
  String? _cachedAccessToken;
  DateTime? _tokenExpiry;

  /// إرسال إشعار إلى تاجر عند إنشاء طلب جديد
  Future<void> sendNewOrderNotification({
    required String vendorId,
    required String orderId,
    required String orderNumber,
    required String clientName,
  }) async {
    try {
      // جلب FCM token للتاجر
      final vendorDoc = await _firestore.collection('vendors').doc(vendorId).get();
      if (!vendorDoc.exists) {
        // التاجر غير موجود
        return;
      }
      
      final vendorData = vendorDoc.data();
      final fcmToken = vendorData?['fcmToken'] as String?;
      
      if (fcmToken == null || fcmToken.isEmpty) {
        // التاجر ليس لديه FCM token
        return;
      }

      // إرسال الإشعار
      await _sendFCMNotificationV1(
        token: fcmToken,
        title: 'طلب جديد',
        body: 'تم استلام طلب جديد #$orderNumber من $clientName',
        data: {
          'type': 'new_order',
          'orderId': orderId,
          'orderNumber': orderNumber,
        },
      );
    } catch (e) {
      // خطأ في إرسال الإشعار
      // يمكن إضافة logging هنا للتحقق من الخطأ
    }
  }

  /// الحصول على OAuth2 Access Token من Service Account
  Future<String?> _getAccessToken() async {
    try {
      // التحقق من أن الـ token موجود وصالح
      if (_cachedAccessToken != null && _tokenExpiry != null) {
        if (DateTime.now().isBefore(_tokenExpiry!.subtract(Duration(minutes: 5)))) {
          return _cachedAccessToken;
        }
      }

      // قراءة Service Account JSON
      final serviceAccountJson = await rootBundle.loadString(_serviceAccountPath);
      final serviceAccount = jsonDecode(serviceAccountJson) as Map<String, dynamic>;

      // إنشاء ServiceAccountCredentials
      final credentials = ServiceAccountCredentials.fromJson(serviceAccount);

      // الحصول على access token
      final authClient = await clientViaServiceAccount(
        credentials,
        ['https://www.googleapis.com/auth/firebase.messaging'],
      );

      // حفظ الـ token
      _cachedAccessToken = authClient.credentials.accessToken.data;
      _tokenExpiry = authClient.credentials.accessToken.expiry;

      return _cachedAccessToken;
    } catch (e) {
      // خطأ في الحصول على access token
      // قد يكون الملف غير موجود - راجع التعليمات
      return null;
    }
  }

  /// إرسال إشعار عبر FCM HTTP v1 API
  Future<void> _sendFCMNotificationV1({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // الحصول على access token
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        // خطأ في الحصول على access token
        return;
      }

      // Endpoint الجديد لـ HTTP v1 API
      final url = Uri.parse('https://fcm.googleapis.com/v1/projects/$_projectId/messages:send');
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      // Payload حسب HTTP v1 API format
      final message = {
        'message': {
          'token': token,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data != null
              ? data.map((key, value) => MapEntry(key, value.toString()))
              : {},
          'android': {
            'priority': 'high',
          },
          'apns': {
            'headers': {
              'apns-priority': '10',
            },
          },
        },
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(message),
      );

      if (response.statusCode != 200) {
        // خطأ في إرسال الإشعار
        // يمكنك إضافة logging هنا للتحقق من الخطأ
      }
    } catch (e) {
      // خطأ في إرسال الإشعار
    }
  }
}
