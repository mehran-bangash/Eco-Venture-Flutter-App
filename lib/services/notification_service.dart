import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eco_venture/services/shared_preferences_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Initialize
  Future<void> initNotifications() async {
    // 1. Request Permission
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // 2. Setup Local Notifications (For Foreground)
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // 3. Create Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Save Token
    String? token = await _fcm.getToken();
    if (token != null) _saveToken(token);
    _fcm.onTokenRefresh.listen(_saveToken);

    // 5. LISTEN: FOREGROUND MESSAGES
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // DEFENSIVE CHECK:
      // Verify if this message is meant for the currently logged-in role.
      // You can add a 'targetRole' data field to your Node.js payloads to enforce this.

      final prefs = await SharedPreferences.getInstance();
      final currentRole = prefs.getString('user_role');

      // If message has 'targetRole' and it doesn't match, IGNORE IT.
      if (message.data.containsKey('targetRole')) {
        if (message.data['targetRole'] != currentRole) {
          print("⚠️ Ignoring notification for wrong role.");
          return;
        }
      }

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

  }

  Future<void> _saveToken(String token) async {
    String? uid = _auth.currentUser?.uid ?? await SharedPreferencesHelper.instance.getUserId();
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update({'fcmToken': token});
  }
}