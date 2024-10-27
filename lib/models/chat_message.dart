import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatMessageType { text, image }

enum MessageStatus { notSent, notView, viewed }

class ChatMessage {
  final String id;
  final String text;
  final ChatMessageType messageType;
  final MessageStatus messageStatus;
  final bool isSender;
  final String senderId;
  final String senderName;
  final String senderImageUrl;
  final Timestamp timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.messageType,
    required this.messageStatus,
    required this.isSender,
    required this.senderId,
    required this.senderName,
    required this.senderImageUrl,
    required this.timestamp,
  });

  factory ChatMessage.fromDocument(DocumentSnapshot doc, String currentUserId) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatMessage(
      id: doc.id,
      text: data['text'] ?? '',
      messageType: ChatMessageType.text,
      messageStatus: MessageStatus.viewed,
      isSender: data['senderId'] == currentUserId,
      senderId: data['senderId'],
      senderName: data['senderName'] ?? '',
      senderImageUrl: data['senderImageUrl'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}
