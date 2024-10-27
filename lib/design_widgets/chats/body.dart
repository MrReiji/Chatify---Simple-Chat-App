import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_card.dart';
import '../../../constants/constants.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    debugPrint('Current User ID: ${currentUser.uid}');

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .where('participants', arrayContains: currentUser.uid)
          .snapshots(), // Usunięto sortowanie
      builder: (ctx, chatSnapshots) {
        debugPrint('StreamBuilder State: ${chatSnapshots.connectionState}');

        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          debugPrint('Waiting for data...');
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          debugPrint('No group data found or no groups exist.');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/noGroupsImg.png',
                  scale: 2.5,
                ),
                const SizedBox(height: 16),
                const Text(
                  "No groups yet! Create your first group.",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final groups = chatSnapshots.data!.docs;
        debugPrint('Total Groups Found: ${groups.length}');
        debugPrint(!chatSnapshots.hasData ? 'No data found' : 'Data found');
        debugPrint(chatSnapshots.data!.docs.isEmpty ? 'No groups exist' : 'Groups exist');

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final groupData = groups[index].data() as Map<String, dynamic>;
            final groupId = groups[index].id;
            final groupName = groupData['name'] ?? 'No Name';
            final groupImageUrl = groupData['groupImageUrl'] ?? '';
            final lastMessage = groupData['lastMessage'] != ''
                ? groupData['lastMessage']
                : "No messages yet";
            final lastMessageTimestamp = groupData['lastMessageTimestamp'] != null
                ? (groupData['lastMessageTimestamp'] as Timestamp).toDate()
                : DateTime.now();

            debugPrint('Group ID: $groupId');
            debugPrint('Group Name: $groupName');
            debugPrint('Last Message: $lastMessage');
            debugPrint('Last Message Timestamp: $lastMessageTimestamp');

            return ChatCard(
              groupId: groupId,
              groupName: groupName,
              groupImageUrl: groupImageUrl,
              lastMessage: lastMessage,
              lastMessageTimestamp: lastMessageTimestamp,
            );
          },
        );
      },
    );
  }
}
