import 'package:chat_ease/widgets/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No Messages Yet!'),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong!'),
            );
          }

          final loadedMessages = snapshot.data!.docs;
          return ListView.builder(
              padding: EdgeInsets.only(bottom: 40, left: 20, right: 20),
              reverse: true,
              itemCount: loadedMessages.length,
              itemBuilder: (ctx, index) {
                final chatMsg = loadedMessages[index].data();
                final nextChatMsg = index + 1 < loadedMessages.length
                    ? loadedMessages[index + 1].data()
                    : null;

                final currentMsgUserId = chatMsg['userId'];
                final nextMsgUserId =
                    nextChatMsg != null ? nextChatMsg['userId'] : null;

                final nextUserIsSame = nextMsgUserId == currentMsgUserId;
                if (nextUserIsSame) {
                  return MessageBubble.next(
                    message: chatMsg['text'],
                    isMe: authenticatedUser.uid == currentMsgUserId,
                  );
                } else {
                  return MessageBubble.first(
                    userImage: chatMsg['userImage'],
                    username: chatMsg['userName'],
                    message: chatMsg['text'],
                    isMe: authenticatedUser.uid == currentMsgUserId,
                  );
                }
              });
        });
  }
}
