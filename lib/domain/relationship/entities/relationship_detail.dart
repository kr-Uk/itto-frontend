import 'package:itto/domain/relationship/entities/relationship.dart';

class RelationshipDetail {
  final int relationshipId;
  final RelationshipDetailUser otherUser;
  final String status;
  final int encounterCount;
  final String? firstEncounterAt;
  final String? lastEncounterAt;
  final String? expiresAt;
  final String createdAt;
  final String? chatRoomId;

  const RelationshipDetail({
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
}

class RelationshipDetailUser {
  final int userId;
  final String nickname;
  final String? gender;
  final int? age;
  final List<RelationshipHobby> hobbies;
  final String? introduction;
  final List<RelationshipPhoto> photos;

  const RelationshipDetailUser({
    required this.userId,
    required this.nickname,
    this.gender,
    this.age,
    required this.hobbies,
    this.introduction,
    required this.photos,
  });
}

class RelationshipPhoto {
  final String url;
  final bool isMosaic;
  final bool isRepresentative;

  const RelationshipPhoto({
    required this.url,
    this.isMosaic = false,
    this.isRepresentative = false,
  });
}
