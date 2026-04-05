import 'package:easy_localization/easy_localization.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kids_loop/managers/theme_manager.dart';
import 'package:kids_loop/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final Map<String, dynamic>? productData;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    this.productData,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _attachedProduct;
  void _handleForegroundNotification(OSNotificationWillDisplayEvent event) {
    final data = event.notification.additionalData;

    if (data != null && data['senderId'] == widget.receiverId) {
      event.preventDefault();
    }
  }

  @override
  void initState() {
    super.initState();

    _attachedProduct = widget.productData;
    OneSignal.Notifications.clearAll();
    OneSignal.Notifications.addForegroundWillDisplayListener(
      _handleForegroundNotification,
    );
  }

  @override
  void dispose() {
    OneSignal.Notifications.removeForegroundWillDisplayListener(
      _handleForegroundNotification,
    );

    _messageController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      String msgText = _messageController.text.trim();
      _messageController.clear();

      await _chatService.sendMessage(
        widget.receiverId,
        msgText,
        productAttachment: _attachedProduct,
      );

      if (_attachedProduct != null) {
        setState(() {
          _attachedProduct = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.receiverName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: ThemeManager.primaryTeal,
          ),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),

          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(
        _auth.currentUser!.uid,
        widget.receiverId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("chat_screen.error_fetching".tr()));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: ThemeManager.primaryTeal),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "chat_screen.say_hi".tr(),
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        final messages = snapshot.data!.docs;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          bool needsRoomUpdate = false;

          for (var doc in messages) {
            final msgData = doc.data() as Map<String, dynamic>;

            if (msgData['senderId'] != _auth.currentUser!.uid &&
                msgData['isRead'] == false) {
              doc.reference.update({'isRead': true});
              needsRoomUpdate = true;
            }
          }

          if (needsRoomUpdate) {
            List<String> ids = [_auth.currentUser!.uid, widget.receiverId];
            ids.sort();
            String chatRoomId = ids.join("_");

            FirebaseFirestore.instance
                .collection('chat_rooms')
                .doc(chatRoomId)
                .update({'isRead': true});
          }
        });
        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final data = messages[index].data() as Map<String, dynamic>;
            return _buildMessageBubble(data);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> data) {
    bool isMe = data['senderId'] == _auth.currentUser!.uid;
    Map<String, dynamic>? attachedProduct = data['productAttachment'];
    bool isRead = data['isRead'] ?? false;

    String timeString = "";
    if (data['timestamp'] != null) {
      DateTime date = (data['timestamp'] as Timestamp).toDate();
      int hour = date.hour > 12
          ? date.hour - 12
          : (date.hour == 0 ? 12 : date.hour);
      String amPm = date.hour >= 12
          ? "chat_screen.pm".tr()
          : "chat_screen.am".tr();
      String minute = date.minute.toString().padLeft(2, '0');
      timeString = "$hour:$minute $amPm";
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),

        padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 8),
        decoration: BoxDecoration(
          color: isMe ? ThemeManager.primaryTeal : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (attachedProduct != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child:
                          attachedProduct['images'] != null &&
                              attachedProduct['images'].isNotEmpty
                          ? Image.network(
                              attachedProduct['images'][0],
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 20),
                            ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attachedProduct['title'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "${attachedProduct['price']} ${'chat_screen.currency'.tr()}",
                          style: const TextStyle(
                            color: ThemeManager.primaryYellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: 12.0,
                    bottom: 2.0,
                  ),
                  child: Text(
                    data['message'],
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeString,
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.done_all,
                        size: 15,
                        color: isRead
                            ? ThemeManager.primaryYellow
                            : Colors.white70,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "chat_screen.type_message".tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: ThemeManager.primaryTeal,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
