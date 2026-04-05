import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kids_loop/managers/theme_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "chat_list_screen.title".tr(),
          style: const TextStyle(color: ThemeManager.primaryTeal),
        ),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chat_rooms')
            .where('users', arrayContains: currentUserId)
            .snapshots(),
        builder: (context, streamSnapshot) {
          if (streamSnapshot.hasError) {
            return Center(child: Text("chat_list_screen.error_fetching".tr()));
          }
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: ThemeManager.primaryTeal),
            );
          }

          if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "chat_list_screen.no_messages".tr(),
                    style: const TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          final rawChats = streamSnapshot.data!.docs;

          final chats = rawChats.toList();
          chats.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            final Timestamp? timeA = aData['timestamp'] as Timestamp?;
            final Timestamp? timeB = bData['timestamp'] as Timestamp?;

            if (timeA == null && timeB == null) return 0;
            if (timeA == null) return 1;
            if (timeB == null) return -1;

            return timeB.compareTo(timeA);
          });

          List<Future<DocumentSnapshot>> userFutures = [];
          for (var chatDoc in chats) {
            final chatData = chatDoc.data() as Map<String, dynamic>;
            final List users = chatData['users'] ?? [];
            final String otherUserId = users.firstWhere(
              (id) => id != currentUserId,
              orElse: () => "",
            );

            if (otherUserId.isNotEmpty) {
              userFutures.add(
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
              );
            }
          }

          return FutureBuilder<List<DocumentSnapshot>>(
            future: Future.wait(userFutures),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: ThemeManager.primaryTeal,
                  ),
                );
              }

              if (!futureSnapshot.hasData) return const SizedBox.shrink();

              final usersData = {
                for (var doc in futureSnapshot.data!)
                  doc.id: doc.data() as Map<String, dynamic>?,
              };

              return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chatDoc = chats[index];
                  final chatData = chatDoc.data() as Map<String, dynamic>;

                  final List users = chatData['users'] ?? [];

                  final String otherUserId = users.firstWhere(
                    (id) => id != currentUserId,
                    orElse: () => "",
                  );

                  if (otherUserId.trim().isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final userData = usersData[otherUserId];
                  if (userData == null) return const SizedBox.shrink();

                  final String otherUserName =
                      userData['full_name'] ??
                      "chat_list_screen.default_user".tr();
                  final sellerImageUrl = userData['photoUrl'] ?? "";

                  final String lastSenderId =
                      chatData['lastMessageSenderId'] ?? "";
                  final bool isRead = chatData['isRead'] ?? true;
                  final bool hasUnreadMessages =
                      (lastSenderId != currentUserId) && !isRead;

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: hasUnreadMessages
                          ? (theme.brightness == Brightness.dark
                                ? theme.colorScheme.surfaceContainerHighest
                                : ThemeManager.primaryTeal.withOpacity(0.08))
                          : theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        backgroundImage: sellerImageUrl.isNotEmpty
                            ? NetworkImage(sellerImageUrl)
                            : null,
                        child: sellerImageUrl.isEmpty
                            ? Icon(
                                Icons.person,
                                color: theme.hintColor,
                                size: 20,
                              )
                            : null,
                      ),
                      title: Text(
                        otherUserName,
                        style: TextStyle(
                          fontWeight: hasUnreadMessages
                              ? FontWeight.w900
                              : FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      subtitle: Builder(
                        builder: (context) {
                          String prefix = "";
                          if (lastSenderId == currentUserId) {
                            prefix = "chat_list_screen.you_prefix".tr();
                          } else if (lastSenderId.isNotEmpty) {
                            final firstName = otherUserName.split(" ")[0];
                            prefix = "$firstName: ";
                          }

                          return Text(
                            "$prefix${chatData['lastMessage'] ?? ''}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                              fontWeight: hasUnreadMessages
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          );
                        },
                      ),
                      trailing: hasUnreadMessages
                          ? Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: ThemeManager.primaryTeal,
                                shape: BoxShape.circle,
                              ),
                            )
                          : Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color:
                                  theme.iconTheme.color?.withOpacity(0.3) ??
                                  Colors.grey,
                            ),
                      onTap: () {
                        if (hasUnreadMessages) {
                          FirebaseFirestore.instance
                              .collection('chat_rooms')
                              .doc(chatDoc.id)
                              .update({'isRead': true});
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              receiverId: otherUserId,
                              receiverName: otherUserName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
