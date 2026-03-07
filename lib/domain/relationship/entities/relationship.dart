class Relationship {
  final int relationshipId;
  final RelationshipOtherUser otherUser;
  final String status;
  final int encounterCount;
  final String? lastEncounterAt;
  final String? expiresAt;
  final String createdAt;
  final List<RelationshipHobby> hobbies;
  final String? chatRoomId;
  final bool destinyBadge;

  const Relationship({
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
}

class RelationshipOtherUser {
  final int userId;
  final String nickname;
  final String? representativePhoto;
  final bool isMosaic;

  const RelationshipOtherUser({
    required this.userId,
    required this.nickname,
    this.representativePhoto,
    this.isMosaic = false,
  });
}

class RelationshipHobby {
  final int id;
  final String name;

  const RelationshipHobby({required this.id, required this.name});
}
