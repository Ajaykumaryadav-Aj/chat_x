import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

String? fcmToken;

// Global instance of FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Show a push notification (used for FCM)
Future<void> showNotification(RemoteNotification? notification) async {
  if (notification == null) {
    debugPrint("Notification suppressed: maintenance mode or null");
    return;
  }

  try {
    final androidDetails = AndroidNotificationDetails(
      'TASKMAN_CHANNEL_ID',
      'Taskman Notifications',
      channelDescription: 'Notifications for Taskman app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      enableLights: true,
      color: Colors.transparent,
      ledColor: Colors.transparent,
      ledOnMs: 1000,
      ledOffMs: 500,
      styleInformation: BigTextStyleInformation(
        notification.body ?? '',
        htmlFormatBigText: true,
        contentTitle: notification.title,
        htmlFormatContentTitle: true,
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title,
      notification.body,
      details,
    );
  } catch (e) {
    //
  }
}

/// Show notification from custom socket event
Future<void> showNotificationFromSocket(String title, String body) async {
  try {
    final androidDetails = AndroidNotificationDetails(
      'TASKMAN_CHANNEL_ID',
      'Taskman Notifications',
      channelDescription: 'Notifications for Taskman app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      enableLights: true,
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  } catch (e) {
    log(e.toString());
  }
}

/// Background handler for FCM messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  final isMaintenance =
      message.notification?.body?.toLowerCase() == "maintenance_mode" ||
          message.data['body']?.toString().toLowerCase() == "maintenance_mode";

  if (isMaintenance) {
    return;
  }

  const settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );

  await flutterLocalNotificationsPlugin.initialize(settings);
  await showNotification(message.notification);
}

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request notification permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Foreground message: ${message.notification?.body}');
      await showNotification(message.notification);
    });

    // When user taps on the notification and opens the app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.notification?.body?.toLowerCase() == "maintenance_mode") {
        return;
      }
      await showNotification(message.notification);
    });

    // App opened from terminated state via notification
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null &&
        initialMessage.notification?.body?.toLowerCase() !=
            "maintenance_mode") {
      await showNotification(initialMessage.notification);
    }

    // Get FCM token
    _firebaseMessaging.getToken().then((token) {
      fcmToken = token;
    });
  }

  /// Initialize local notification settings
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(settings);

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'TASKMAN_CHANNEL_ID',
        'Taskman Notifications',
        description: 'Notifications for Taskman app',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      final androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(channel);
      }
    }
  }
}
