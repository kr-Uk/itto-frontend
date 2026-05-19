import 'package:itto/domain/chat/entities/chat_message.dart';

/// 백엔드 ChatMessageResponse JSON 페이로드 매핑.
///
/// 백엔드 필드 → 도메인 엔티티 변환 규칙:
///   - imageUrl 이 있으면 type='image', text=imageUrl
///   - imageUrl 이 없으면 type='text', text=content
///   - isRead==true 이면 readBy=[senderId, 0]  (1:1 채팅에서 상대가 읽음을 의미하는 sentinel)
///     isRead==false 이면 readBy=[senderId]
class ChatMessageModel {
  final int messageId;
  final int chatRoomId;
  final int senderId;
  final String? content;
  final String? imageUrl;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.messageId,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    required this.imageUrl,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      messageId: (json['messageId'] as num).toInt(),
      chatRoomId: (json['chatRoomId'] as num).toInt(),
      senderId: (json['senderId'] as num).toInt(),
      content: json['content'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  ChatMessage toEntity() {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return ChatMessage(
      id: messageId.toString(),
      senderId: senderId,
      text: hasImage ? imageUrl! : (content ?? ''),
      type: hasImage ? 'image' : 'text',
      createdAt: createdAt,
      readBy: isRead ? [senderId, 0] : [senderId],
    );
  }
}
