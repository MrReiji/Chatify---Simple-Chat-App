import 'package:chatify/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatInputField extends StatefulWidget {
  final String chatId;

  const ChatInputField({super.key, required this.chatId});

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  final User _currentUser = FirebaseAuth.instance.currentUser!;

  void _sendMessage() async {
    final messageText = _controller.text.trim();
    if (messageText.isEmpty) {
      debugPrint('Message text is empty. Aborting send.');
      return;
    }

    debugPrint('Sending message: $messageText');
    debugPrint('Chat ID: ${widget.chatId}');
    debugPrint('Current User ID: ${_currentUser.uid}');

    try {
      // Pobieranie danych użytkownika
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .get();
      debugPrint('User data fetched: ${userData.data()}');

      // Dodawanie wiadomości do kolekcji "messages" w dokumencie grupy
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'text': messageText,
        'senderId': _currentUser.uid,
        'senderName': userData['username'] ?? 'Anonim',
        'senderImageUrl': userData['image_url'] ?? '', // Zmieniono na image_url
        'timestamp': Timestamp.now(),
      });
      debugPrint('Message added to Firestore under chat ID: ${widget.chatId}');

      // Aktualizacja ostatniej wiadomości i znacznika czasu w dokumencie grupy
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.chatId)
          .update({
        'lastMessage': messageText,
        'lastMessageTimestamp': Timestamp.now(),
      });
      debugPrint('Group document updated with last message: $messageText');

      // Czyszczenie pola tekstowego
      _controller.clear();
      debugPrint('Message input field cleared.');
    } catch (error) {
      // Obsługa błędu
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
