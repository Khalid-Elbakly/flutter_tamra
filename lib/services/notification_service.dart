import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// Handler للإشعارات عند فتح التطبيق من الإشعار
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // يمكنك إضافة منطق هنا عند استقبال إشعار في الخلفية
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // تهيئة خدمة الإشعارات
  Future<void> initialize() async {
    // طلب صلاحيات الإشعارات
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // تهيئة الإشعارات المحلية
      await _initializeLocalNotifications();

      // تسجيل handler للإشعارات في الخلفية
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // معالج الإشعارات عند فتح التطبيق
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // معالج الإشعارات عند فتح التطبيق من الإشعار
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // الحصول على token وحفظه
      await _saveTokenToFirestore();
    }
  }

  // تهيئة الإشعارات المحلية
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // إنشاء قناة إشعارات للأندرويد
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // معالج الإشعارات في الواجهة الأمامية
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('تم استقبال إشعار في الواجهة الأمامية: ${message.notification?.title}');
    final notification = message.notification;

    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data['orderId'],
      );
      debugPrint('تم عرض الإشعار المحلي: ${notification.title}');
    } else {
      debugPrint('الإشعار لا يحتوي على notification object');
    }
  }

  // معالج عند فتح الإشعار
  void _handleMessageOpenedApp(RemoteMessage message) {
    // يمكن إضافة منطق للانتقال إلى صفحة معينة
  }

  // معالج عند النقر على الإشعار
  void _onNotificationTapped(NotificationResponse response) {
    // يمكن إضافة منطق للانتقال إلى صفحة معينة
  }

  // حفظ FCM token في Firestore
  Future<void> _saveTokenToFirestore() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        // إذا لم يكن المستخدم مسجل الدخول، استمع لتغييرات حالة المصادقة
        _auth.authStateChanges().listen((User? user) {
          if (user != null) {
            _saveTokenForUser(user.uid);
          }
        });
        return;
      }

      await _saveTokenForUser(user.uid);

      // الاستماع لتغييرات token
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.uid.isNotEmpty) {
          await _firestore.collection('clients').doc(currentUser.uid).set({
            'fcmToken': newToken,
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      });
    } catch (e) {
      // خطأ في حفظ token
      debugPrint('خطأ في حفظ FCM token: $e');
    }
  }

  // حفظ token لمستخدم محدد
  Future<void> _saveTokenForUser(String userId) async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null && userId.isNotEmpty) {
        debugPrint('جاري حفظ FCM token للمستخدم: $userId');
        await _firestore.collection('clients').doc(userId).set({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('تم حفظ FCM token بنجاح للمستخدم: $userId');
      } else {
        debugPrint('لا يوجد FCM token أو userId فارغ - userId: $userId');
      }
    } catch (e) {
      debugPrint('خطأ في حفظ FCM token للمستخدم: $e');
    }
  }

  // دالة عامة لحفظ token (يمكن استدعاؤها بعد تسجيل الدخول)
  Future<void> saveToken() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _saveTokenForUser(user.uid);
    }
  }

  // الحصول على FCM token
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // حذف token (عند تسجيل الخروج)
  Future<void> deleteToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('clients').doc(user.uid).update({
          'fcmToken': FieldValue.delete(),
        });
      }
      await _firebaseMessaging.deleteToken();
    } catch (e) {
      // خطأ في حذف token
    }
  }
}


