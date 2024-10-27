import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/chat_message.dart';
import 'chat_input_field.dart';
import 'message.dart';

class Body extends StatelessWidget {
  final String chatId;

  const Body({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    debugPrint('Current User ID: ${currentUser.uid}');
    debugPrint('Chat ID: $chatId');

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('groups')
                .doc(chatId)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              debugPrint('StreamBuilder Connection State: ${snapshot.connectionState}');

              if (snapshot.connectionState == ConnectionState.waiting) {
                debugPrint('Waiting for messages to load...');
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                debugPrint('Error loading messages: ${snapshot.error}');
                return const Center(child: Text('Something went wrong...'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                debugPrint('No messages found for chat ID: $chatId');
                return const Center(child: Text('No messages yet.'));
              }

              final messages = snapshot.data?.docs ?? [];
              debugPrint('Total Messages Found: ${messages.length}');

              return ListView.builder(
                reverse: true, // Najnowsze wiadomości na dole
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final messageDoc = messages[index];
                  debugPrint('Message Document ID at index $index: ${messageDoc.id}');
                  debugPrint('Raw Message Data at index $index: ${messageDoc.data()}');

                  final message = ChatMessage.fromDocument(messageDoc, currentUser.uid);
                  debugPrint(
                      'Parsed Message Text at index $index: ${message.text}, Sent by: ${message.senderId}');
                  debugPrint('Timestamp at index $index: ${message.timestamp}');

                  return Message(message: message);
                },
              );
            },
          ),
        ),
        ChatInputField(chatId: chatId),
      ],
    );
  }
}
