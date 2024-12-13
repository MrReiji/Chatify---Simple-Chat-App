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
      appBar: AppBar(
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        const BackButton(),
        CircleAvatar(
          radius: 22, // Zwiększ rozmiar, by awatar był bardziej wyrazisty
          backgroundImage: groupImageUrl.isNotEmpty
              ? NetworkImage(groupImageUrl)
              : const AssetImage("assets/images/noProfileImg.png")
                  as ImageProvider,
        ),
        const SizedBox(width: kDefaultPadding),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              groupName,
              style: Theme.of(context).textTheme.titleLarge, // Zastosowanie większego rozmiaru tekstu
            ),
          ],
        ),
      ],
    ),
  ),
      body: Body(chatId: chatId),
    );
  }


}
