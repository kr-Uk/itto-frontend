import 'package:itto/domain/chat/entities/chat_room.dart';

/// 백엔드 ChatRoomSummary JSON 페이로드 매핑.
///
/// 백엔드 필드 → 도메인 엔티티 변환 규칙:
///   - chatRoomId(BIGINT) → id(String)
///   - otherUserId/otherUserNickname → participantIds=[otherUserId], participantNames={otherUserId: nickname}
///   - lastMessage/lastMessageAt/unreadCount: 그대로 전달
class ChatRoomModel {
  final int chatRoomId;
  final int? relationshipId;
  final int otherUserId;
  final String otherUserNickname;
  final String? otherUserPhotoUrl;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime? expiresAt;

  const ChatRoomModel({
    required this.chatRoomId,
    required this.relationshipId,
    required this.otherUserId,
    required this.otherUserNickname,
    required this.otherUserPhotoUrl,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.expiresAt,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      chatRoomId: (json['chatRoomId'] as num).toInt(),
      relationshipId: (json['relationshipId'] as num?)?.toInt(),
      otherUserId: (json['otherUserId'] as num).toInt(),
      otherUserNickname: json['otherUserNickname'] as String? ?? '',
      otherUserPhotoUrl: json['otherUserPhotoUrl'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : null,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  ChatRoom toEntity() => ChatRoom(
        id: chatRoomId.toString(),
        participantIds: [otherUserId],
        participantNames: {otherUserId: otherUserNickname},
        lastMessage: lastMessage,
        lastMessageAt: lastMessageAt,
        unreadCount: unreadCount,
      );
}
