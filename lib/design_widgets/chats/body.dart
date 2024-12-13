import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_card.dart';

/// A widget that displays a list of chat groups the current user is a participant in.
///
/// This widget listens to changes in the Firestore collection `groups`
/// and dynamically updates the list of groups displayed. It also supports
/// filtering groups based on a search query.
///
/// ### Features:
/// - Real-time updates from Firestore.
/// - Displays a loading indicator while data is being fetched.
/// - Shows a placeholder when no groups exist or no groups match the search query.
/// - Dynamically filters the list of groups based on the provided `searchQuery`.
///
/// ### Example Usage:
/// ```dart
/// Body(
///   searchQuery: "group name",
/// );
/// ```
class Body extends StatelessWidget {
  /// The search query used to filter the displayed chat groups.
  final String searchQuery;

  /// Constructor for the `Body` widget.
  ///
  /// - `searchQuery`: Required. Filters the groups based on this query.
  const Body({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    // Get the currently authenticated user.
    final currentUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder<QuerySnapshot>(
      // Stream to fetch all groups where the current user is a participant.
      stream: FirebaseFirestore.instance
          .collection('groups')
          .where('participants', arrayContains: currentUser.uid)
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        // Show a loading spinner while waiting for data.
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Show a placeholder if no data or no groups exist.
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/noGroupsImg.png',
                  scale: 2.5, // Resize the image
                ),
                const SizedBox(height: 16), // Add spacing
                const Text(
                  "No groups yet! Create your first group.",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Filter groups based on the search query.
        final groups = chatSnapshots.data!.docs
            .where((doc) => (doc['name'] as String)
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
            .toList();

        // Show a placeholder if no groups match the search query.
        if (groups.isEmpty) {
          return const Center(
            child: Text(
              "No chats found",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        // Build a list of chat groups.
        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            // Extract group data.
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

            // Create a chat card for each group.
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
