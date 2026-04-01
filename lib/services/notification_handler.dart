import 'package:flutter/material.dart';
import 'package:kids_loop/feature_screens/chat_screen/chat_screen.dart';
import 'package:kids_loop/utilities/app_keys.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationHandler {
  static String? pendingChatId;
  static String? pendingChatName;

  static Future<void> initialize() async {
    OneSignal.initialize(AppKeys.oneSignalAppId);
    OneSignal.Notifications.requestPermission(true);

    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      if (data != null && data['senderId'] != null) {
        pendingChatId = data['senderId'];
        pendingChatName = data['senderName'];
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
        pendingChatId = data['senderId'];
        pendingChatName = data['senderName'];
        _handleNotificationNavigation(context);
      }
    });
  }

  static void _handleNotificationNavigation(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pendingChatId != null) {
        String chatId = pendingChatId!;
        String chatName = pendingChatName ?? "User";

        pendingChatId = null;
        pendingChatName = null;

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
