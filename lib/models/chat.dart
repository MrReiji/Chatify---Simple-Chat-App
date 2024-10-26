// models/chat.dart
class Chat {
  final String name;
  final String lastMessage;
  final String time;
  final bool isActive;
  final List<String> groupImages;

  Chat({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.isActive,
    required this.groupImages,
  });
}

// Sample data
List<Chat> chatsData = [
  Chat(
    name: "Study Group",
    lastMessage: "Let's meet at 5 PM",
    time: "3m ago",
    isActive: true,
    groupImages: [
      "assets/images/noProfileImg.png",
      "assets/images/noProfileImg.png",
      "assets/images/noProfileImg.png",
    ],
  ),
  Chat(
    name: "Project Team",
    lastMessage: "Deadline is approaching",
    time: "1h ago",
    isActive: false,
    groupImages: [
      "assets/images/noProfileImg.png",
      "assets/images/noProfileImg.png",
      "assets/images/noProfileImg.png",
    ],
  ),
  // Add more Chat instances as needed
];
