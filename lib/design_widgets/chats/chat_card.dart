import 'package:chatify/blocs/chat/group_creation_form_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatify/screens/group_editing_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants/constants.dart';
import '../../screens/conversation_screen.dart';

/// A widget that represents a single chat group card in the chat list.
///
/// The `ChatCard` widget displays key information about a group, such as:
/// - Group name
/// - Group image
/// - Last message in the chat
/// - Timestamp of the last message
/// - A settings option for group creators
///
/// It also allows navigation to:
/// - The group chat screen (`ConversationScreen`)
/// - The group editing screen for group creators.
///
/// ### Features:
/// - Conditional styling based on dark/light mode.
/// - Displays a settings icon for group creators to edit or delete the group.
/// - Provides feedback for user actions, such as taps or long presses.
class ChatCard extends StatelessWidget {
  /// The unique identifier of the group.
  final String groupId;

  /// The name of the group.
  final String groupName;

  /// The URL of the group's image.
  final String groupImageUrl;

  /// The last message sent in the group chat.
  final String lastMessage;

  /// The timestamp of the last message in the chat.
  final DateTime lastMessageTimestamp;

  /// Constructor for `ChatCard`.
  ///
  /// - `groupId`: Required. The unique ID of the group.
  /// - `groupName`: Required. The group's name.
  /// - `groupImageUrl`: Required. The group's image URL.
  /// - `lastMessage`: Required. The last message sent in the group.
  /// - `lastMessageTimestamp`: Required. The timestamp of the last message.
  const ChatCard({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.groupImageUrl,
    required this.lastMessage,
    required this.lastMessageTimestamp,
  }) : super(key: key);

  /// Formats the given timestamp for display.
  ///
  /// - If the timestamp is from today, it shows the time in `HH:mm` format.
  /// - If within the last week, it displays the day of the week.
  /// - Otherwise, it shows the date in `dd MMM yyyy` format.
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final isToday = now.day == timestamp.day &&
        now.month == timestamp.month &&
        now.year == timestamp.year;

    if (isToday) {
      return DateFormat.Hm().format(timestamp);
    } else if (now.difference(timestamp).inDays < 7) {
      return 'Last ${DateFormat.EEEE().format(timestamp)}';
    } else {
      return DateFormat('dd MMM yyyy').format(timestamp);
    }
  }

  /// Checks if the current user is the creator of the group.
  Future<bool> _isGroupCreator() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
    return groupDoc.exists && groupDoc['creatorId'] == currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    // Detect the current theme mode.
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<bool>(
      future: _isGroupCreator(),
      builder: (context, snapshot) {
        final isCreator = snapshot.data ?? false;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Ink(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1F1F2A) : kIvoryWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!isDarkMode)
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              splashColor: kPrimaryColor.withOpacity(0.2),
              onTap: () {
                // Navigate to the conversation screen on tap.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConversationScreen(
                      chatId: groupId,
                      groupName: groupName,
                      groupImageUrl: groupImageUrl,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Group image as a circular avatar.
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: groupImageUrl.isNotEmpty
                          ? NetworkImage(groupImageUrl)
                          : const AssetImage("assets/images/noGroupImg.png")
                              as ImageProvider,
                      backgroundColor: kSecondaryColor.withOpacity(0.2),
                    ),
                    const SizedBox(width: 16),
                    // Group name, last message, and timestamp.
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Group name.
                          Text(
                            groupName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : kPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Last message in the group.
                          Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              fontStyle: lastMessage == "No messages yet"
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Timestamp of the last message.
                          Text(
                            _formatTimestamp(lastMessageTimestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCreator)
                      // Settings icon for group creators.
                      IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: kPrimaryColor,
                        ),
                        onPressed: () {
                          _showSettingsDialog(context);
                        },
                      ),
                    // Decorative arrow icon.
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: kPrimaryColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Displays a settings dialog for the group.
  ///
  /// Options include:
  /// - Editing the group
  /// - Deleting the group
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Group Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit group option.
              ListTile(
                leading: const Icon(Icons.edit, color: kPrimaryColor),
                title: const Text("Edit Group"),
                onTap: () {
                  Navigator.pop(context); // Close the dialog.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupEditingScreen(
                        groupId: groupId,
                        groupName: groupName,
                        groupImageUrl: groupImageUrl,
                      ),
                    ),
                  );
                },
              ),
              // Delete group option.
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete Group"),
                onTap: () {
                  Navigator.pop(context); // Close the dialog.
                  deleteGroup(context, groupId);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
