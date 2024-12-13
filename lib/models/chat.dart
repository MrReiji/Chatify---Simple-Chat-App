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
