import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/constants.dart';
import '../../screens/conversation_screen.dart';

class ChatCard extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String groupImageUrl;
  final String lastMessage;
  final DateTime lastMessageTimestamp;

  const ChatCard({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.groupImageUrl,
    required this.lastMessage,
    required this.lastMessageTimestamp,
  }) : super(key: key);

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final isToday = now.day == timestamp.day &&
        now.month == timestamp.month &&
        now.year == timestamp.year;

    if (isToday) {
      return DateFormat.Hm().format(timestamp);
    } else if (now.difference(timestamp).inDays < 7) {
      return DateFormat.E().format(timestamp);
    } else {
      return DateFormat.yMd().format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                // Obraz grupy
                CircleAvatar(
                  radius: 32,
                  backgroundImage: groupImageUrl.isNotEmpty
                      ? NetworkImage(groupImageUrl)
                      : const AssetImage("assets/images/noGroupImg.png")
                          as ImageProvider,
                  backgroundColor: kSecondaryColor.withOpacity(0.2),
                ),
                const SizedBox(width: 16),
                // Informacje o czacie
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nazwa grupy
                      Text(
                        groupName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Treść ostatniej wiadomości
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
                    ],
                  ),
                ),
                // Znacznik czasu
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTimestamp(lastMessageTimestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: kPrimaryColor,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
