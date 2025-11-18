import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_report.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize notifications
  Future<void> initialize() async {
    try {
      // Request permission
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else {
        print('User declined or has not accepted permission');
      }

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        await _saveFCMToken(token);
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Handle message when app is opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Listen for report status changes
      _listenForReportUpdates();
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> _saveFCMToken(String token) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .update({'fcmToken': token});
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');

    // Show in-app notification or update UI
    if (message.data['type'] == 'report_status_update') {
      _showReportStatusNotification(message);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message clicked: ${message.messageId}');

    // Navigate to relevant screen based on message type
    if (message.data['type'] == 'report_status_update') {
      // Navigate to report history
      // This would typically be handled by a navigation service
    }
  }

  void _showReportStatusNotification(RemoteMessage message) {
    // This would show a custom in-app notification
    // For now, we'll just print the details
    print('Report status updated: ${message.data}');
  }

  void _listenForReportUpdates() {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        _firestore
            .collection('user_reports')
            .where('userId', isEqualTo: currentUser.uid)
            .snapshots()
            .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.modified) {
              UserReport report = UserReport.fromJson(
                  change.doc.data() as Map<String, dynamic>);

              // Notify about status change
              _notifyReportStatusChange(report);
            }
          }
        });
      }
    } catch (e) {
      print('Error listening for report updates: $e');
    }
  }

  void _notifyReportStatusChange(UserReport report) {
    // This would trigger a local notification or update UI
    print('Report ${report.id} status changed to ${report.status}');

    // You could use a local notification plugin here
    // or update the app state using a state management solution
  }

  // Send notification to specific user (for admin use)
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // Get user's FCM token
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists && userDoc['fcmToken'] != null) {
        String token = userDoc['fcmToken'];

        // This would typically be done via a Cloud Function
        // For now, we'll just prepare the notification data
        Map<String, dynamic> notificationData = {
          'to': token,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data ?? {},
          'priority': 'high',
        };

        print('Prepared notification: $notificationData');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Send report status update notification
  Future<void> sendReportStatusUpdate({
    required String userId,
    required String reportId,
    required String newStatus,
    String? adminNotes,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      title: 'Report Status Updated',
      body: 'Your report #$reportId has been $newStatus',
      data: {
        'type': 'report_status_update',
        'reportId': reportId,
        'newStatus': newStatus,
        'adminNotes': adminNotes ?? '',
      },
    );
  }

  // Send outage alert notification
  Future<void> sendOutageAlert({
    required String title,
    required String message,
    List<String>? affectedAreas,
  }) async {
    try {
      // Get all users' FCM tokens
      QuerySnapshot usersSnapshot = await _firestore
          .collection('users')
          .where('fcmToken', isNotEqualTo: null)
          .get();

      for (var userDoc in usersSnapshot.docs) {
        await sendNotificationToUser(
          userId: userDoc.id,
          title: title,
          body: message,
          data: {
            'type': 'outage_alert',
            'affectedAreas': affectedAreas?.join(',') ?? '',
          },
        );
      }
    } catch (e) {
      print('Error sending outage alert: $e');
    }
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  // Handle background message
}
