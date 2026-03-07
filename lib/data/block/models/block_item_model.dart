import 'package:itto/domain/block/entities/block_item.dart';

class BlockItemModel {
  final int id;
  final BlockedUserModel blockedUser;
  final String createdAt;

  const BlockItemModel({
    required this.id,
    required this.blockedUser,
    required this.createdAt,
  });

  factory BlockItemModel.fromJson(Map<String, dynamic> json) => BlockItemModel(
        id: json['id'] as int,
        blockedUser: BlockedUserModel.fromJson(
          json['blockedUser'] as Map<String, dynamic>,
        ),
        createdAt: json['createdAt'] as String? ?? '',
      );

  BlockItem toEntity() => BlockItem(
        id: id,
        blockedUser: blockedUser.toEntity(),
        createdAt: createdAt,
      );
}

class BlockedUserModel {
  final int userId;
  final String nickname;

  const BlockedUserModel({required this.userId, required this.nickname});

  factory BlockedUserModel.fromJson(Map<String, dynamic> json) =>
      BlockedUserModel(
        userId: json['userId'] as int,
        nickname: json['nickname'] as String,
      );

  BlockedUser toEntity() => BlockedUser(userId: userId, nickname: nickname);
}
