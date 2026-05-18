import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Handles FCM push notification setup, permission requests,
/// token management, and in-app message handling.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Initialize FCM: request permissions, get token, and listen for messages.
  Future<void> init(String? userId) async {
    // Request permission (iOS/web requires this, Android 13+ requires it too)
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[FCM] Notifications denied by user');
        return;
      }
    } catch (e) {
      debugPrint('[FCM] Error requesting permission: $e');
    }

    // Get and save the FCM token
    try {
      final token = await _fcm.getToken();
      if (token != null && userId != null) {
        await _saveToken(userId, token);
        debugPrint('[FCM] Token saved for user $userId');
      }
    } catch (e) {
      debugPrint('[FCM] Error getting token: $e');
    }

    // Listen for token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      if (userId != null) {
        _saveToken(userId, newToken);
        debugPrint('[FCM] Token refreshed');
      }
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Foreground message: ${message.notification?.title}');
      // The notification will be handled by the app's notification system
      // In production, you'd show a local notification or an in-app banner here
    });

    // Handle notification tap when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Notification tapped (background): ${message.data}');
      // Navigate to relevant screen based on message data
    });

    // Check if app was opened from a terminated state via notification
    try {
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[FCM] App opened from notification: ${initialMessage.data}');
      }
    } catch (e) {
      debugPrint('[FCM] Error checking initial message: $e');
    }
  }

  /// Save the FCM token to the user's Firestore profile.
  Future<void> _saveToken(String userId, String token) async {
    try {
      await _db.collection('users').doc(userId).set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[FCM] Error saving token: $e');
    }
  }

  /// Subscribe to a topic (e.g., 'new_gigs_nearby', category-based topics).
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      debugPrint('[FCM] Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('[FCM] Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      debugPrint('[FCM] Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('[FCM] Error unsubscribing from topic: $e');
    }
  }
}

/// Background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
}
