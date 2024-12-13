import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../../../models/chat_message.dart';
import 'chat_input_field.dart';
import 'message.dart';

/// A widget that represents the body of a chat screen.
///
/// The `Body` widget displays a list of chat messages for a specific chat group,
/// allows users to send new messages, and organizes messages with timestamps and date headers.
///
/// ### Features:
/// - Real-time updates using Firestore's `snapshots`.
/// - Displays a loading spinner while fetching messages.
/// - Shows date headers when messages are from different days.
/// - Supports user avatars and message grouping by sender.
/// - Includes an input field for sending messages.
///
/// ### Example Usage:
/// ```dart
/// Body(chatId: "exampleChatId");
/// ```
class Body extends StatelessWidget {
  /// The unique identifier of the chat group.
  final String chatId;

  /// Constructor for the `Body` widget.
  ///
  /// - `chatId`: Required. The ID of the chat group to display messages for.
  const Body({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    // Retrieve the currently authenticated user.
    final currentUser = FirebaseAuth.instance.currentUser!;
    debugPrint('Current User ID: ${currentUser.uid}');
    debugPrint('Chat ID: $chatId');

    return Column(
      children: [
        // Expanded ensures the message list takes up available space.
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            // Set up a Firestore stream to fetch messages ordered by timestamp (ascending).
            stream: FirebaseFirestore.instance
                .collection('groups')
                .doc(chatId)
                .collection('messages')
                .orderBy('timestamp', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              // Display a loading spinner while fetching data.
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Show an error message if there is an issue fetching data.
              if (snapshot.hasError) {
                debugPrint('Error loading messages: ${snapshot.error}');
                return const Center(child: Text('Something went wrong...'));
              }

              // Show a message if no messages are found.
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                debugPrint('No messages found for chat ID: $chatId');
                return const Center(child: Text('No messages yet.'));
              }

              // Retrieve the message documents from the snapshot.
              final messages = snapshot.data?.docs ?? [];
              debugPrint('Total Messages Found: ${messages.length}');

              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  // Extract the message data as a map.
                  final data = messages[index].data() as Map<String, dynamic>?;
                  if (data == null) return SizedBox.shrink();

                  // Convert the Firestore document to a `ChatMessage` object.
                  final message = ChatMessage.fromDocument(
                      messages[index], currentUser.uid);

                  // Determine if a date header should be shown (when the day changes).
                  final DateTime currentMessageDate = message.timestamp.toDate();
                  final bool showDateHeader = index == 0 ||
                      currentMessageDate.day !=
                          (messages[index - 1].data()
                                  as Map<String, dynamic>?)?['timestamp']
                              .toDate()
                              .day;

                  // Determine if the avatar and name should be shown (first message from sender).
                  final showAvatarAndName = index == 0 ||
                      (messages[index - 1].data()
                              as Map<String, dynamic>?)?['senderId'] !=
                          data['senderId'];

                  // Get the timestamp of the next message from the same sender, if applicable.
                  Timestamp? nextMessageTimestampFromSameUser;
                  if (index < messages.length - 1) {
                    final nextData = messages[index + 1].data();
                    if (nextData is Map<String, dynamic> &&
                        nextData['senderId'] == data['senderId']) {
                      nextMessageTimestampFromSameUser = nextData['timestamp'] as Timestamp?;
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display a date header if it's a new day.
                      if (showDateHeader)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              DateFormat('dd.MM.yyyy').format(currentMessageDate),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.grey),
                            ),
                          ),
                        ),
                      // Display the `Message` widget for each message.
                      Message(
                        message: message,
                        showAvatarAndName: showAvatarAndName,
                        nextMessageTimestampFromSameUser: nextMessageTimestampFromSameUser,
                        chatId: chatId,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        // Input field for typing and sending new messages.
        ChatInputField(chatId: chatId),
      ],
    );
  }
}
