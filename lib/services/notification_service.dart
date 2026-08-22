import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  NotificationService({
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance;

  Future<void> initialize(
      {Function(String bookingId)? onNavigateToBooking}) async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint(
          'FCM Notification permission status: ${settings.authorizationStatus}');

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await _messaging.getToken();
        if (token != null) {
          await registerDeviceToken(user.uid, token);
        }
      }

      _messaging.onTokenRefresh.listen((newToken) async {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await registerDeviceToken(currentUser.uid, newToken);
        }
      });

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
            'Foreground FCM message received: ${message.notification?.title}');
        _handleIncomingMessage(message);
      });

      // Background notification tap listener
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Background notification tapped: ${message.data}');
        final bookingId = message.data['bookingId'] as String?;
        if (bookingId != null && onNavigateToBooking != null) {
          onNavigateToBooking(bookingId);
        }
      });

      // Terminated notification tap listener
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        final bookingId = initialMessage.data['bookingId'] as String?;
        if (bookingId != null && onNavigateToBooking != null) {
          onNavigateToBooking(bookingId);
        }
      }
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
    }
  }

  Future<void> registerDeviceToken(String uid, String token) async {
    if (uid.isEmpty || token.isEmpty) return;
    try {
      final deviceId = token.hashCode.toString();
      final deviceRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('devices')
          .doc(deviceId);

      await deviceRef.set({
        'fcmToken': token,
        'platform': defaultTargetPlatform.name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('FCM Device token registered successfully.');
    } catch (e) {
      debugPrint('Error registering device token: $e');
    }
  }

  Future<void> markNotificationAsRead({
    required String uid,
    required String notificationId,
  }) async {
    if (uid.isEmpty || notificationId.isEmpty) return;
    try {
      final notifRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc(notificationId);

      await notifRef.update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Notification marked as read successfully.');
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  void _handleIncomingMessage(RemoteMessage message) {
    final title = message.notification?.title ?? 'Appointment Update';
    final body =
        message.notification?.body ?? 'Your appointment status has changed.';
    debugPrint('Foreground notification received: $title - $body');
    // Foreground experience: Displays in-app banner UI and refreshes Riverpod state.
    // Client does NOT write authoritative notification history to Firestore.
  }

  static List<Map<String, dynamic>> getMockNotifications() => [];
}
