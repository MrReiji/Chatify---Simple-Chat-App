import 'package:chatify/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatify/constants/constants.dart';

/// A widget that provides a text input field for sending messages in a chat.
///
/// The `ChatInputField` is integrated with Firestore to send messages
/// and update the group's last message. It also subscribes the user to
/// the chat group's notification topic.
///
/// ### Features:
/// - Allows users to type and send messages.
/// - Subscribes to notification topics for the chat group.
/// - Automatically updates Firestore with the message and last message details.
///
/// ### Example Usage:
/// ```dart
/// ChatInputField(chatId: "exampleChatId");
/// ```
class ChatInputField extends StatefulWidget {
  /// The unique identifier of the chat group.
  final String chatId;

  /// Constructor for the `ChatInputField` widget.
  ///
  /// - `chatId`: Required. The ID of the chat group.
  const ChatInputField({super.key, required this.chatId});

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  /// Controller for managing the text input field.
  final TextEditingController _controller = TextEditingController();

  /// The currently authenticated user.
  final User _currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    // Subscribe to notifications for the chat group.
    subscribeToChatTopic(widget.chatId);
  }

  /// Subscribes the user to the notification topic for the chat group.
  ///
  /// - `groupId`: The unique identifier of the chat group.
  void subscribeToChatTopic(String groupId) {
    NotificationService().subscribeToTopic('group_$groupId');
    debugPrint('Subscribed to topic: group_$groupId');
  }

  /// Sends a message to the chat group.
  ///
  /// This method:
  /// - Validates the input to ensure it's not empty.
  /// - Adds the message to Firestore.
  /// - Updates the group's last message and timestamp.
  /// - Clears the input field after sending the message.
  void _sendMessage() async {
    final messageText = _controller.text.trim();
    if (messageText.isEmpty) {
      debugPrint('Message text is empty. Aborting send.');
      return;
    }

    debugPrint('Attempting to send message: "$messageText"');
    debugPrint('Chat ID: ${widget.chatId}');
    debugPrint('Current User ID: ${_currentUser.uid}');

    try {
      // Fetch the current user's data for sender details.
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .get();
      debugPrint('Fetched user data for message: ${userData.data()}');

      // Create the message object.
      final newMessage = {
        'text': messageText,
        'senderId': _currentUser.uid,
        'senderName': userData['username'] ?? 'Anonymous',
        'senderImageUrl': userData['image_url'] ?? '',
        'timestamp': Timestamp.now(),
      };

      // Add the message to the Firestore messages collection for the group.
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.chatId)
          .collection('messages')
          .add(newMessage);
      debugPrint('Message successfully added to Firestore for chat ID: ${widget.chatId}');

      // Update the group's last message and timestamp in Firestore.
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.chatId)
          .update({
        'lastMessage': messageText,
        'lastMessageTimestamp': Timestamp.now(),
      });
      debugPrint('Updated last message for chat ID: ${widget.chatId} to "$messageText"');

      // Clear the input field after sending the message.
      _controller.clear();
      debugPrint('Message input field cleared.');
    } catch (error) {
      debugPrint('Failed to send message: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 32,
            color: const Color(0xFF087949).withOpacity(0.08),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding * 0.75,
                ),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sentiment_satisfied_alt_outlined,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .color!
                          .withOpacity(0.64),
                    ),
                    const SizedBox(width: kDefaultPadding / 4),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Type message",
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: kPrimaryColor),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
