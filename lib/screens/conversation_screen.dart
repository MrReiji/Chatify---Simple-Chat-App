import 'package:chatify/constants/constants.dart';
import 'package:flutter/material.dart';

import '../design_widgets/conversations/body.dart';

class ConversationScreen extends StatelessWidget {
  final String chatId;
  final String groupName;
  final String groupImageUrl;

  const ConversationScreen({
    super.key,
    required this.chatId,
    required this.groupName,
    required this.groupImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Body(chatId: chatId),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const BackButton(),
          CircleAvatar(
            backgroundImage: groupImageUrl.isNotEmpty
                ? NetworkImage(groupImageUrl)
                : const AssetImage("assets/images/noProfileImg.png")
                    as ImageProvider,
          ),
          const SizedBox(width: kDefaultPadding * 0.75),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                groupName,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          )
        ],
      ),
      actions: [
        const SizedBox(width: kDefaultPadding / 2),
      ],
    );
  }
}
