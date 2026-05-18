import 'package:itto/domain/relationship/entities/relationship.dart';

class RelationshipItemModel {
  final int relationshipId;
  final RelationshipOtherUserModel otherUser;
  final String status;
  final int encounterCount;
  final String? lastEncounterAt;
  final String? expiresAt;
  final String createdAt;
  final List<RelationshipHobbyModel> hobbies;
  final String? chatRoomId;
  final bool destinyBadge;

  const RelationshipItemModel({
    required this.relationshipId,
    required this.otherUser,
    required this.status,
    required this.encounterCount,
    this.lastEncounterAt,
    this.expiresAt,
    required this.createdAt,
    this.hobbies = const [],
    this.chatRoomId,
    this.destinyBadge = false,
  });

  factory RelationshipItemModel.fromJson(Map<String, dynamic> json) =>
      RelationshipItemModel(
        relationshipId: json['relationshipId'] as int,
        otherUser: RelationshipOtherUserModel.fromJson(
          json['otherUser'] as Map<String, dynamic>,
        ),
        status: json['status'] as String,
        encounterCount: json['encounterCount'] as int? ?? 0,
        lastEncounterAt: json['lastEncounterAt'] as String?,
        expiresAt: json['expiresAt'] as String?,
        createdAt: json['createdAt'] as String? ?? '',
        hobbies: (json['hobbies'] as List<dynamic>?)
                ?.map((e) =>
                    RelationshipHobbyModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        chatRoomId: json['chatRoomId'] as String?,
        destinyBadge: json['destinyBadge'] as bool? ?? false,
      );

  Relationship toEntity() => Relationship(
        relationshipId: relationshipId,
        otherUser: otherUser.toEntity(),
        status: status,
        encounterCount: encounterCount,
        lastEncounterAt: lastEncounterAt,
        expiresAt: expiresAt,
        createdAt: createdAt,
        hobbies: hobbies.map((h) => h.toEntity()).toList(),
        chatRoomId: chatRoomId,
        destinyBadge: destinyBadge,
      );
}

class RelationshipOtherUserModel {
  final int userId;
  final String nickname;
  final String? representativePhoto;
  final bool isMosaic;
  final String? introduction;

  const RelationshipOtherUserModel({
    required this.userId,
    required this.nickname,
    this.representativePhoto,
    this.isMosaic = false,
    this.introduction,
  });

  factory RelationshipOtherUserModel.fromJson(Map<String, dynamic> json) =>
      RelationshipOtherUserModel(
        userId: json['userId'] as int,
        nickname: json['nickname'] as String,
        representativePhoto: json['representativePhoto'] as String?,
        isMosaic: json['isMosaic'] as bool? ?? false,
        introduction: json['introduction'] as String?,
      );

  RelationshipOtherUser toEntity() => RelationshipOtherUser(
        userId: userId,
        nickname: nickname,
        representativePhoto: representativePhoto,
        isMosaic: isMosaic,
        introduction: introduction,
      );
}

class RelationshipHobbyModel {
  final int id;
  final String name;

  const RelationshipHobbyModel({required this.id, required this.name});

  factory RelationshipHobbyModel.fromJson(Map<String, dynamic> json) =>
      RelationshipHobbyModel(
        id: json['id'] as int,
        name: json['name'] as String,
      );

  RelationshipHobby toEntity() => RelationshipHobby(id: id, name: name);
}
