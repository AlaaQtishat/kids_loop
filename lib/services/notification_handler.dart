import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bottom_navigation_pages/chat_screen/chat_screen.dart';
import '../utilities/app_keys.dart';

class NotificationHandler {
  static String? notificationPayloadId;
  static String? notificationPayloadName;

  static Future<void> initialize() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(AppKeys.oneSignalAppId);
    OneSignal.Notifications.requestPermission(true);

    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      if (data != null && data['senderId'] != null) {
        notificationPayloadId = data['senderId'];
        notificationPayloadName = data['senderName'];
      }
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      OneSignal.login(currentUser.uid);
    }
  }

  static void setup(BuildContext context) {
    _handleNotificationNavigation(context);

    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      if (data != null && data['senderId'] != null) {
        notificationPayloadId = data['senderId'];
        notificationPayloadName = data['senderName'];
        _handleNotificationNavigation(context);
      }
    });
  }

  static void _handleNotificationNavigation(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (notificationPayloadId != null) {
        String chatId = notificationPayloadId!;
        String chatName = notificationPayloadName ?? "User";

        notificationPayloadId = null;
        notificationPayloadName = null;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatScreen(receiverId: chatId, receiverName: chatName),
          ),
        );
      }
    });
  }
}
