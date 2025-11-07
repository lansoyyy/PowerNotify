// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import '../models/power_status.dart';

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FlutterLocalNotificationsPlugin _localNotifications =
//       FlutterLocalNotificationsPlugin();
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   bool _initialized = false;

//   Future<void> initialize() async {
//     if (_initialized) return;

//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _localNotifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: _onNotificationTapped,
//     );

//     _initialized = true;
//   }

//   void _onNotificationTapped(NotificationResponse response) {
//     // Handle notification tap
//   }

//   Future<void> _initializeFirebaseMessaging() async {
//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       _showLocalNotification(
//         message.notification?.title ?? 'Power Alert',
//         message.notification?.body ?? '',
//       );
//     });
//   }

//   Future<void> _showLocalNotification(String title, String body) async {
//     const androidDetails = AndroidNotificationDetails(
//       'power_alerts',
//       'Power Alerts',
//       channelDescription: 'Notifications for power outages and updates',
//       importance: Importance.high,
//       priority: Priority.high,
//     );

//     const iosDetails = DarwinNotificationDetails();

//     const details = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await _localNotifications.show(
//       DateTime.now().millisecondsSinceEpoch ~/ 1000,
//       title,
//       body,
//       details,
//     );
//   }

//   Future<void> showPowerOutageAlert(PowerStatusType type, String message) async {
//     String title;
//     switch (type) {
//       case PowerStatusType.outage:
//         title = '⚡ Power Outage Alert';
//         break;
//       case PowerStatusType.scheduled:
//         title = '🔧 Scheduled Maintenance';
//         break;
//       case PowerStatusType.normal:
//         title = '✅ Power Restored';
//         break;
//     }

//     await _showLocalNotification(title, message);
//   }
// }
