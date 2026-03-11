
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static const String serverUrl = "https://be-chatx-2.onrender.com/send";

  static Future<bool> sendNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "title": title,
          "body": body,
        }),
      );
      print("data body >>>>> $body");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("response data >>>>> $data");
        return data['success'] == true;
      } else {
        print(" Error sending notification: ${response.body}");
        return false;
      }
    } catch (e) {
      print(" Exception sending notification: $e");
      return false;
    }
  }

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _initializeLocalNotifications();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showNotification(message.notification);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await _showNotification(message.notification);
    });

    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await saveDeviceToken(token);
    }

    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      await saveDeviceToken(newToken);
    });
  }

  Future<void> saveDeviceToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "fcmToken": token,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(settings);

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'CHATX_CHANNEL',
        'ChatX Notifications',
        description: 'Chat messages and updates',
        importance: Importance.max,
      );

      final androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(channel);
      }
    }
  }

  Future<void> _showNotification(RemoteNotification? notification) async {
    if (notification == null) return;

    const iosDetails = DarwinNotificationDetails();
    final androidDetails = AndroidNotificationDetails(
      'CHATX_CHANNEL',
      'ChatX Notifications',
      channelDescription: 'Chat messages and updates',
      importance: Importance.max,
      priority: Priority.high,
    );

    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title,
      notification.body,
      details,
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  const settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await flutterLocalNotificationsPlugin.initialize(settings);

  if (message.notification != null) {
    final androidDetails = AndroidNotificationDetails(
      'CHATX_CHANNEL',
      'ChatX Notifications',
      channelDescription: 'Chat messages and updates',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification!.title,
      message.notification!.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}





















// import 'dart:developer';
// import 'dart:io';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// String? fcmToken;

// // Global instance of FlutterLocalNotificationsPlugin
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// /// Show a push notification (used for FCM)
// Future<void> showNotification(RemoteNotification? notification) async {
//   if (notification == null) {
//     debugPrint("Notification suppressed: maintenance mode or null");
//     return;
//   }

//   try {
//     final androidDetails = AndroidNotificationDetails(
//       'TASKMAN_CHANNEL_ID',
//       'Taskman Notifications',
//       channelDescription: 'Notifications for Taskman app',
//       importance: Importance.max,
//       priority: Priority.high,
//       showWhen: true,
//       icon: '@mipmap/ic_launcher',
//       playSound: true,
//       enableVibration: true,
//       enableLights: true,
//       color: Colors.transparent,
//       ledColor: Colors.transparent,
//       ledOnMs: 1000,
//       ledOffMs: 500,
//       styleInformation: BigTextStyleInformation(
//         notification.body ?? '',
//         htmlFormatBigText: true,
//         contentTitle: notification.title,
//         htmlFormatContentTitle: true,
//       ),
//     );

//     const iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     final details =
//         NotificationDetails(android: androidDetails, iOS: iosDetails);

//     await flutterLocalNotificationsPlugin.show(
//       DateTime.now().millisecondsSinceEpoch ~/ 1000,
//       notification.title,
//       notification.body,
//       details,
//     );
//   } catch (e) {
//     //
//   }
// }

// /// Show notification from custom socket event
// Future<void> showNotificationFromSocket(String title, String body) async {
//   try {
//     final androidDetails = AndroidNotificationDetails(
//       'TASKMAN_CHANNEL_ID',
//       'Taskman Notifications',
//       channelDescription: 'Notifications for Taskman app',
//       importance: Importance.max,
//       priority: Priority.high,
//       showWhen: true,
//       icon: '@mipmap/ic_launcher',
//       playSound: true,
//       enableVibration: true,
//       enableLights: true,
//       styleInformation: BigTextStyleInformation(body),
//     );

//     const iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     final details =
//         NotificationDetails(android: androidDetails, iOS: iosDetails);

//     await flutterLocalNotificationsPlugin.show(
//       DateTime.now().millisecondsSinceEpoch ~/ 1000,
//       title,
//       body,
//       details,
//     );
//   } catch (e) {
//     log(e.toString());
//   }
// }

// /// Background handler for FCM messages
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

//   final isMaintenance =
//       message.notification?.body?.toLowerCase() == "maintenance_mode" ||
//           message.data['body']?.toString().toLowerCase() == "maintenance_mode";

//   if (isMaintenance) {
//     return;
//   }

//   const settings = InitializationSettings(
//     android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//     iOS: DarwinInitializationSettings(),
//   );

//   await flutterLocalNotificationsPlugin.initialize(settings);
//   await showNotification(message.notification);
// }

// class PushNotificationService {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   Future<void> initialize() async {
//     // Request notification permissions
//     await _firebaseMessaging.requestPermission(
//       alert: true,
//       announcement: true,
//       badge: true,
//       sound: true,
//     );

//     // Initialize local notifications
//     await _initializeLocalNotifications();

//     // Handle background messages
//     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       print('Foreground message: ${message.notification?.body}');
//       await showNotification(message.notification);
//     });

//     // When user taps on the notification and opens the app
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
//       if (message.notification?.body?.toLowerCase() == "maintenance_mode") {
//         return;
//       }
//       await showNotification(message.notification);
//     });

//     // App opened from terminated state via notification
//     RemoteMessage? initialMessage =
//         await _firebaseMessaging.getInitialMessage();
//     if (initialMessage != null &&
//         initialMessage.notification?.body?.toLowerCase() !=
//             "maintenance_mode") {
//       await showNotification(initialMessage.notification);
//     }

//     // Get FCM token
//     _firebaseMessaging.getToken().then((token) {
//       fcmToken = token;
//     });
//   }

//   /// Initialize local notification settings
//   Future<void> _initializeLocalNotifications() async {
//     const androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const settings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await flutterLocalNotificationsPlugin.initialize(settings);

//     if (Platform.isAndroid) {
//       const channel = AndroidNotificationChannel(
//         'TASKMAN_CHANNEL_ID',
//         'Taskman Notifications',
//         description: 'Notifications for Taskman app',
//         importance: Importance.max,
//         playSound: true,
//         enableVibration: true,
//         showBadge: true,
//       );

//       final androidImplementation =
//           flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>();

//       if (androidImplementation != null) {
//         await androidImplementation.createNotificationChannel(channel);
//       }
//     }
//   }
// }
