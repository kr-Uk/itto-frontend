import 'package:itto/domain/relationship/entities/relationship_detail.dart';
import 'package:itto/data/relationship/models/relationship_item_model.dart';

class RelationshipDetailModel {
  final int relationshipId;
  final RelationshipDetailUserModel otherUser;
  final String status;
  final int encounterCount;
  final String? firstEncounterAt;
  final String? lastEncounterAt;
  final String? expiresAt;
  final String createdAt;
  final String? chatRoomId;

  const RelationshipDetailModel({
    required this.relationshipId,
    required this.otherUser,
    required this.status,
    required this.encounterCount,
    this.firstEncounterAt,
    this.lastEncounterAt,
    this.expiresAt,
    required this.createdAt,
    this.chatRoomId,
  });

  factory RelationshipDetailModel.fromJson(Map<String, dynamic> json) =>
      RelationshipDetailModel(
        relationshipId: json['relationshipId'] as int,
        otherUser: RelationshipDetailUserModel.fromJson(
          json['otherUser'] as Map<String, dynamic>,
        ),
        status: json['status'] as String,
        encounterCount: json['encounterCount'] as int? ?? 0,
        firstEncounterAt: json['firstEncounterAt'] as String?,
        lastEncounterAt: json['lastEncounterAt'] as String?,
        expiresAt: json['expiresAt'] as String?,
        createdAt: json['createdAt'] as String? ?? '',
        chatRoomId: json['chatRoomId'] as String?,
      );

  RelationshipDetail toEntity() => RelationshipDetail(
        relationshipId: relationshipId,
        otherUser: otherUser.toEntity(),
        status: status,
        encounterCount: encounterCount,
        firstEncounterAt: firstEncounterAt,
        lastEncounterAt: lastEncounterAt,
        expiresAt: expiresAt,
        createdAt: createdAt,
        chatRoomId: chatRoomId,
      );
}

class RelationshipDetailUserModel {
  final int userId;
  final String nickname;
  final String? gender;
  final int? age;
  final List<RelationshipHobbyModel> hobbies;
  final String? introduction;
  final List<RelationshipPhotoModel> photos;

  const RelationshipDetailUserModel({
    required this.userId,
    required this.nickname,
    this.gender,
    this.age,
    required this.hobbies,
    this.introduction,
    required this.photos,
  });

  factory RelationshipDetailUserModel.fromJson(Map<String, dynamic> json) =>
      RelationshipDetailUserModel(
        userId: json['userId'] as int,
        nickname: json['nickname'] as String,
        gender: json['gender'] as String?,
        age: json['age'] as int?,
        hobbies: (json['hobbies'] as List<dynamic>?)
                ?.map((e) =>
                    RelationshipHobbyModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        introduction: json['introduction'] as String?,
        photos: (json['photos'] as List<dynamic>?)
                ?.map((e) =>
                    RelationshipPhotoModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  RelationshipDetailUser toEntity() => RelationshipDetailUser(
        userId: userId,
        nickname: nickname,
        gender: gender,
        age: age,
        hobbies: hobbies.map((h) => h.toEntity()).toList(),
        introduction: introduction,
        photos: photos.map((p) => p.toEntity()).toList(),
      );
}

class RelationshipPhotoModel {
  final String url;
  final bool isMosaic;
  final bool isRepresentative;

  const RelationshipPhotoModel({
    required this.url,
    this.isMosaic = false,
    this.isRepresentative = false,
  });

  factory RelationshipPhotoModel.fromJson(Map<String, dynamic> json) =>
      RelationshipPhotoModel(
        url: json['url'] as String,
        isMosaic: json['isMosaic'] as bool? ?? false,
        isRepresentative: json['isRepresentative'] as bool? ?? false,
      );

  RelationshipPhoto toEntity() => RelationshipPhoto(
        url: url,
        isMosaic: isMosaic,
        isRepresentative: isRepresentative,
      );
}
