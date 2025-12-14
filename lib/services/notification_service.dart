import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eco_venture/services/shared_preferences_helper.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  // Initialize
  Future<void> initNotifications() async {
    // 1. Request Permission
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // 2. Setup Local Notifications (For Foreground)
    // FIX: Use @mipmap/ic_launcher (Standard Flutter default)
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );
    await _localNotifications.initialize(initSettings);

    // 3. Create Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Save Token
    String? token = await _fcm.getToken();
    if (token != null) _saveToken(token);
    _fcm.onTokenRefresh.listen(_saveToken);

    // 5. LISTEN: FOREGROUND MESSAGES
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        // --- FIX: Wrap in try-catch to prevent APP CRASH ---
        try {
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                // FIX: Use @mipmap/ic_launcher
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        } catch (e) {
          print("❌ Notification Error (App would have crashed): $e");
        }
      }
    });
  }

  Future<void> _saveToken(String token) async {
    String? uid = _auth.currentUser?.uid ??
        await SharedPreferencesHelper.instance.getUserId();
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update({'fcmToken': token});
  }
}