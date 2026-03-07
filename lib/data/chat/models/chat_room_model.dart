import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itto/domain/chat/entities/chat_room.dart';

class ChatRoomModel {
  final String id;
  final List<int> participantIds;
  final Map<int, String> participantNames;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ChatRoomModel({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory ChatRoomModel.fromFirestore(
    DocumentSnapshot doc, {
    Map<int, String>? names,
    int unreadCount = 0,
  }) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final participantIds = (data['participants'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList() ??
        [];

    return ChatRoomModel(
      id: doc.id,
      participantIds: participantIds,
      participantNames: names ?? {},
      lastMessage: data['lastMessage'] as String?,
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      unreadCount: unreadCount,
    );
  }

  ChatRoom toEntity() => ChatRoom(
        id: id,
        participantIds: participantIds,
        participantNames: participantNames,
        lastMessage: lastMessage,
        lastMessageAt: lastMessageAt,
        unreadCount: unreadCount,
      );
}
