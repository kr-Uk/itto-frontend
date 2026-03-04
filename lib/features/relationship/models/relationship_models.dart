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

  factory RelationshipOtherUser.fromJson(Map<String, dynamic> json) =>
      RelationshipOtherUser(
        userId: json['userId'] as int,
        nickname: json['nickname'] as String,
        representativePhoto: json['representativePhoto'] as String?,
        isMosaic: json['isMosaic'] as bool? ?? false,
      );
}

class RelationshipItem {
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

  const RelationshipItem({
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

  factory RelationshipItem.fromJson(Map<String, dynamic> json) =>
      RelationshipItem(
        relationshipId: json['relationshipId'] as int,
        otherUser: RelationshipOtherUser.fromJson(
          json['otherUser'] as Map<String, dynamic>,
        ),
        status: json['status'] as String,
        encounterCount: json['encounterCount'] as int? ?? 0,
        lastEncounterAt: json['lastEncounterAt'] as String?,
        expiresAt: json['expiresAt'] as String?,
        createdAt: json['createdAt'] as String? ?? '',
        hobbies:
            (json['hobbies'] as List<dynamic>?)
                ?.map(
                  (e) => RelationshipHobby.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
        chatRoomId: json['chatRoomId'] as String?,
        destinyBadge: json['destinyBadge'] as bool? ?? false,
      );
}

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

  factory RelationshipDetail.fromJson(Map<String, dynamic> json) =>
      RelationshipDetail(
        relationshipId: json['relationshipId'] as int,
        otherUser: RelationshipDetailUser.fromJson(
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

  factory RelationshipDetailUser.fromJson(
    Map<String, dynamic> json,
  ) => RelationshipDetailUser(
    userId: json['userId'] as int,
    nickname: json['nickname'] as String,
    gender: json['gender'] as String?,
    age: json['age'] as int?,
    hobbies:
        (json['hobbies'] as List<dynamic>?)
            ?.map((e) => RelationshipHobby.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    introduction: json['introduction'] as String?,
    photos:
        (json['photos'] as List<dynamic>?)
            ?.map((e) => RelationshipPhoto.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

class RelationshipHobby {
  final int id;
  final String name;

  const RelationshipHobby({required this.id, required this.name});

  factory RelationshipHobby.fromJson(Map<String, dynamic> json) =>
      RelationshipHobby(id: json['id'] as int, name: json['name'] as String);
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

  factory RelationshipPhoto.fromJson(Map<String, dynamic> json) =>
      RelationshipPhoto(
        url: json['url'] as String,
        isMosaic: json['isMosaic'] as bool? ?? false,
        isRepresentative: json['isRepresentative'] as bool? ?? false,
      );
}

class EncounterLocation {
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? encounterAt;
  final String? mapThumbnailUrl;

  const EncounterLocation({
    this.address,
    this.latitude,
    this.longitude,
    this.encounterAt,
    this.mapThumbnailUrl,
  });

  factory EncounterLocation.fromJson(Map<String, dynamic> json) =>
      EncounterLocation(
        address: json['address'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        encounterAt: json['encounterAt'] as String?,
        mapThumbnailUrl: json['mapThumbnailUrl'] as String?,
      );
}
