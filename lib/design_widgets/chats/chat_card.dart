import 'package:flutter/material.dart';
import 'package:chatify/constants/constants.dart';
import '../../../models/chat.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({
    super.key,
    required this.chat,
    required this.press,
  });

  final Chat chat;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: kDefaultPadding,
          vertical: kDefaultPadding * 0.75,
        ),
        child: Row(
          children: [
            GroupAvatar(images: chat.groupImages),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Opacity(
                      opacity: 0.64,
                      child: Text(
                        chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: 0.64,
              child: Text(chat.time),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupAvatar extends StatelessWidget {
  const GroupAvatar({
    super.key,
    required this.images,
  });

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    const double size = 48;
    const double overlap = 16;
    return SizedBox(
      width: size + (images.length - 1) * (size - overlap),
      height: size,
      child: Stack(
        children: images.asMap().entries.map((entry) {
          int idx = entry.key;
          String image = entry.value;
          return Positioned(
            left: idx * (size - overlap),
            child: CircleAvatar(
              radius: size / 2,
              backgroundImage: AssetImage(image),
            ),
          );
        }).toList(),
      ),
    );
  }
}
