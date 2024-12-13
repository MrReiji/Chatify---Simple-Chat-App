import 'package:chatify/constants/constants.dart';
import 'package:flutter/material.dart';

import '../../../models/chat_message.dart';

class TextMessage extends StatelessWidget {
  const TextMessage({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
  padding: const EdgeInsets.symmetric(
    horizontal: kDefaultPadding,
    vertical: kDefaultPadding / 2,
  ),
  decoration: BoxDecoration(
    color: kPrimaryColor.withOpacity(message.isSender ? 0.9 : 0.1),
    borderRadius: BorderRadius.circular(24), // Większe zaokrąglenie
  ),
  child: Text(
    message.text,
    style: TextStyle(
      fontSize: 15, // Zwiększony rozmiar tekstu dla lepszej czytelności
      color: message.isSender ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color,
    ),
  ),
);

  }
}
