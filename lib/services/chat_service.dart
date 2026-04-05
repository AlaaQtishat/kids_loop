import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kids_loop/utilities/app_keys.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join("_");
  }

  Future<void> sendMessage(
    String receiverId,
    String message, {
    Map<String, dynamic>? productAttachment,
  }) async {
    final String currentUserId = _auth.currentUser!.uid;

    Map<String, dynamic> newMessage = {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'productAttachment': productAttachment,
      'isRead': false,
    };

    String chatRoomId = getChatRoomId(currentUserId, receiverId);

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage);

    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'users': [currentUserId, receiverId],
      'lastMessage': message,

      'timestamp': FieldValue.serverTimestamp(),
      'lastMessageSenderId': currentUserId,
      'isRead': false,
    }, SetOptions(merge: true));
    await sendNotification(receiverId, message);
  }

  Future<void> sendNotification(String receiverId, String message) async {
    final currentUserDoc = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
    final senderName = currentUserDoc.data()?['full_name'] ?? 'KidsLoop User';

    final url = Uri.parse('https://onesignal.com/api/v1/notifications');

    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Basic ${AppKeys.oneSignalRestApiKey}',
    };
    final body = jsonEncode({
      "app_id": AppKeys.oneSignalAppId,
      "target_channel": "push",
      "include_aliases": {
        "external_id": [receiverId],
      },

      "headings": {
        "en": "New message from $senderName",
        "ar": "رسالة جديدة من $senderName",
      },

      "contents": {"en": message, "ar": message},
      "data": {"senderId": _auth.currentUser!.uid, "senderName": senderName},
    });

    try {
      await http.post(url, headers: headers, body: body);
    } catch (_) {}
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    String chatRoomId = getChatRoomId(userId, otherUserId);

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
