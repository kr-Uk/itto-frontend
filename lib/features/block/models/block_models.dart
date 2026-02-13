class BlockItem {
  final int id;
  final BlockedUser blockedUser;
  final String createdAt;

  const BlockItem({
    required this.id,
    required this.blockedUser,
    required this.createdAt,
  });

  factory BlockItem.fromJson(Map<String, dynamic> json) => BlockItem(
        id: json['id'] as int,
        blockedUser: BlockedUser.fromJson(
            json['blockedUser'] as Map<String, dynamic>),
        createdAt: json['createdAt'] as String? ?? '',
      );
}

class BlockedUser {
  final int userId;
  final String nickname;

  const BlockedUser({required this.userId, required this.nickname});

  factory BlockedUser.fromJson(Map<String, dynamic> json) => BlockedUser(
        userId: json['userId'] as int,
        nickname: json['nickname'] as String,
      );
}

class ReportRequest {
  final int targetUserId;
  final String category;
  final String targetType;
  final String? chatRoomId;
  final String? description;

  const ReportRequest({
    required this.targetUserId,
    required this.category,
    required this.targetType,
    this.chatRoomId,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'targetUserId': targetUserId,
        'category': category,
        'targetType': targetType,
        if (chatRoomId != null) 'chatRoomId': chatRoomId,
        if (description != null) 'description': description,
      };
}
