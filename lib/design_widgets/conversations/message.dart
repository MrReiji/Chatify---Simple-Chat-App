import 'package:chatify/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../../../models/chat_message.dart';

/// A widget that displays a single chat message with styling and functionality.
///
/// The `Message` widget supports:
/// - Showing message text with appropriate sender/receiver styling.
/// - Displaying sender avatar and name for non-sender messages.
/// - Timestamp and message grouping logic to reduce clutter.
/// - Long press options for editing or deleting a user's own messages.
class Message extends StatelessWidget {
  /// The `ChatMessage` object representing the message details.
  final ChatMessage message;

  /// Whether to display the sender's avatar and name.
  final bool showAvatarAndName;

  /// Timestamp of the next message from the same user (used for grouping logic).
  final Timestamp? nextMessageTimestampFromSameUser;

  /// The unique identifier of the chat group the message belongs to.
  final String chatId;

  /// Constructor for the `Message` widget.
  ///
  /// - `message`: Required. The `ChatMessage` to display.
  /// - `showAvatarAndName`: Optional. Defaults to `true`. Determines whether the sender's avatar and name are shown.
  /// - `nextMessageTimestampFromSameUser`: Optional. Used for timestamp grouping.
  /// - `chatId`: Required. The ID of the chat group.
  const Message({
    super.key,
    required this.message,
    this.showAvatarAndName = true,
    this.nextMessageTimestampFromSameUser,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    // Determine whether to show the timestamp.
    bool showTimestamp = true;
    if (nextMessageTimestampFromSameUser != null) {
      final currentHourMinute = DateFormat('HH:mm').format(message.timestamp.toDate());
      final nextHourMinute =
          DateFormat('HH:mm').format(nextMessageTimestampFromSameUser!.toDate());
      showTimestamp = currentHourMinute != nextHourMinute;
    }

    return GestureDetector(
      onLongPress: () => _showMessageOptionsDialog(context),
      child: Padding(
        padding: EdgeInsets.only(
          top: showAvatarAndName ? 8.0 : 2.0,
          bottom: 4.0,
          left: message.isSender ? 40.0 : 8.0,
          right: message.isSender ? 8.0 : 40.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isSender && showAvatarAndName) ...[
              // Display sender's avatar.
              Container(
                width: 45,
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: message.senderImageUrl.isNotEmpty
                      ? NetworkImage(message.senderImageUrl)
                      : const AssetImage("assets/images/noProfileImg.png")
                          as ImageProvider,
                ),
              ),
              const SizedBox(width: 10)
            ] else if (!message.isSender && !showAvatarAndName)
              const SizedBox(width: 55),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    message.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!message.isSender && showAvatarAndName)
                    // Display sender's name.
                    Text(
                      message.senderName,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.8),
                          ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Message bubble.
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: kDefaultPadding * 0.75,
                            vertical: kDefaultPadding / 2,
                          ),
                          decoration: BoxDecoration(
                            color: message.isSender
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(message.isSender ? 20 : 0),
                              topRight: Radius.circular(message.isSender ? 0 : 20),
                              bottomLeft: const Radius.circular(20),
                              bottomRight: const Radius.circular(20),
                            ),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: message.isSender
                                  ? Colors.white
                                  : Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                          ),
                        ),
                      ),
                      // Message status dot for sender messages.
                      if (message.isSender)
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: MessageStatusDot(status: message.messageStatus),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Timestamp of the message.
                  if (showTimestamp)
                    Row(
                      mainAxisAlignment: message.isSender
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(message.timestamp.toDate()),
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Displays a dialog with options to edit or delete the message.
  ///
  /// Only the sender of the message can access these options.
  void _showMessageOptionsDialog(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.uid != message.senderId) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Message Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                title: const Text("Edit Message"),
                onTap: () {
                  Navigator.pop(context);
                  _editMessage(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete Message"),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  /// Handles message editing functionality.
  void _editMessage(BuildContext context) async {
    final newTextController = TextEditingController(text: message.text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Message"),
          content: TextField(
            controller: newTextController,
            decoration: const InputDecoration(hintText: "Enter new message text"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Save"),
              onPressed: () async {
                final newText = newTextController.text.trim();
                if (newText.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('groups')
                      .doc(chatId)
                      .collection('messages')
                      .doc(message.id)
                      .update({'text': newText});
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Handles message deletion functionality.
  void _deleteMessage(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(chatId)
        .collection('messages')
        .doc(message.id)
        .delete();
  }
}

/// A widget that represents the message status indicator.
///
/// The `MessageStatusDot` displays the status of a message using a color-coded dot:
/// - `notSent`: Red dot with an "X".
/// - `notView`: Grey dot.
/// - `viewed`: Green dot with a checkmark.
class MessageStatusDot extends StatelessWidget {
  /// The status of the message.
  final MessageStatus? status;

  /// Constructor for `MessageStatusDot`.
  const MessageStatusDot({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    /// Determines the color of the status dot based on the message status.
    Color dotColor(MessageStatus status) {
      switch (status) {
        case MessageStatus.notSent:
          return kErrorColor;
        case MessageStatus.notView:
          return Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.1);
        case MessageStatus.viewed:
          return kPrimaryColor;
        default:
          return Colors.transparent;
      }
    }

    return Container(
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: dotColor(status!),
        shape: BoxShape.circle,
      ),
      child: Icon(
        status == MessageStatus.notSent ? Icons.close : Icons.done,
        size: 8,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
