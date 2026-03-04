import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final List<int> participantIds;
  final Map<int, String> participantNames;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ChatRoom({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory ChatRoom.fromFirestore(
    DocumentSnapshot doc,
    int currentUserId, {
    Map<int, String>? names,
  }) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final participantIds =
        (data['participants'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList() ??
        [];

    return ChatRoom(
      id: doc.id,
      participantIds: participantIds,
      participantNames: names ?? {},
      lastMessage: data['lastMessage'] as String?,
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      unreadCount: 0, // Will be calculated separately
    );
  }

  String getOtherUserName(int currentUserId) {
    final otherId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );
    return participantNames[otherId] ?? '알 수 없음';
  }

  int getOtherUserId(int currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );
  }
}

class ChatMessage {
  final String id;
  final int senderId;
  final String text;
  final String type;
  final DateTime createdAt;
  final List<int> readBy;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.type = 'text',
    required this.createdAt,
    this.readBy = const [],
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as int,
      text: data['text'] as String,
      type: data['type'] as String? ?? 'text',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      readBy:
          (data['readBy'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'text': text,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
      'readBy': readBy,
    };
  }

  bool isReadBy(int userId) => readBy.contains(userId);
}
