import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Service for handling push notifications via Firebase Cloud Messaging.
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Initialize notification settings.
  Future<void> initialize() async {
    // Request permission (iOS/Web)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('[Notifications] Permission granted');
    }

    // Handle background/terminated messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Get the FCM token
    final token = await _fcm.getToken();
    if (token != null) {
      debugPrint('[Notifications] FCM Token: $token');
      // In a real app, you'd send this to your backend/Firestore
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[Notifications] Foreground: ${message.notification?.title}');
      // Here you could show a local notification or snackbar
    });

    // Handle message opening
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[Notifications] Opened from notification: ${message.data}');
      // Navigate to relevant screen based on message.data
    });
  }

  /// Subscribe to a topic (e.g., district-wide alerts).
  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
    debugPrint('[Notifications] Subscribed to $topic');
  }

  /// Unsubscribe from a topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
    debugPrint('[Notifications] Unsubscribed from $topic');
  }
}

/// Global background message handler.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, 
  // you must call Firebase.initializeApp() here.
  debugPrint('[Notifications] Background message: ${message.messageId}');
}

/// Notification types sent by Cloud Functions.
enum NotificationType {
  territoryCaptured,   // "Your territory was captured"
  districtConquered,   // "District conquered"
  rivalNearby,         // "Rival nearby"
  leaderboardChanged,  // "Leaderboard rank changed"
  streakAchieved,      // "Streak milestone"
}
