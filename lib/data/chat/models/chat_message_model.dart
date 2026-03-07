import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itto/domain/chat/entities/chat_message.dart';

class ChatMessageModel {
  final String id;
  final int senderId;
  final String text;
  final String type;
  final DateTime createdAt;
  final List<int> readBy;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    this.type = 'text',
    required this.createdAt,
    this.readBy = const [],
  });

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessageModel(
      id: doc.id,
      senderId: data['senderId'] as int,
      text: data['text'] as String,
      type: data['type'] as String? ?? 'text',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      readBy: (data['readBy'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'senderId': senderId,
        'text': text,
        'type': type,
        'createdAt': Timestamp.fromDate(createdAt),
        'readBy': readBy,
      };

  ChatMessage toEntity() => ChatMessage(
        id: id,
        senderId: senderId,
        text: text,
        type: type,
        createdAt: createdAt,
        readBy: readBy,
      );
}
