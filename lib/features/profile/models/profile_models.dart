import '../../auth/models/signup_models.dart';

class MyProfile {
  final int userId;
  final String nickname;
  final String gender;
  final String birthDate;
  final int age;
  final List<HobbyItem> hobbies;
  final String? introduction;
  final List<PhotoItem> photos;
  final String verificationStatus;
  final int knots;
  final bool isPremium;
  final String createdAt;

  const MyProfile({
    required this.userId,
    required this.nickname,
    required this.gender,
    required this.birthDate,
    required this.age,
    required this.hobbies,
    this.introduction,
    required this.photos,
    required this.verificationStatus,
    required this.knots,
    required this.isPremium,
    required this.createdAt,
  });

  factory MyProfile.fromJson(Map<String, dynamic> json) => MyProfile(
    userId: json['userId'] as int,
    nickname: json['nickname'] as String? ?? '',
    gender: json['gender'] as String? ?? '',
    birthDate: json['birthDate'] as String? ?? '',
    age: json['age'] as int? ?? 0,
    hobbies:
        (json['hobbies'] as List<dynamic>?)
            ?.map((e) => HobbyItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    introduction: json['introduction'] as String?,
    photos:
        (json['photos'] as List<dynamic>?)
            ?.map((e) => PhotoItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    verificationStatus: json['verificationStatus'] as String? ?? 'NONE',
    knots: json['knots'] as int? ?? 0,
    isPremium: json['isPremium'] as bool? ?? false,
    createdAt: json['createdAt'] as String? ?? '',
  );
}

class HobbyItem {
  final int id;
  final String name;
  final String? category;

  const HobbyItem({required this.id, required this.name, this.category});

  factory HobbyItem.fromJson(Map<String, dynamic> json) => HobbyItem(
    id: json['id'] as int,
    name: json['name'] as String,
    category: json['category'] as String?,
  );
}

class OtherProfile {
  final int userId;
  final String nickname;
  final String? relationshipStatus;
  final String? gender;
  final int? age;
  final List<HobbyItem> hobbies;
  final String? introduction;
  final List<OtherProfilePhoto> photos;
  final int? encounterCount;

  const OtherProfile({
    required this.userId,
    required this.nickname,
    this.relationshipStatus,
    this.gender,
    this.age,
    required this.hobbies,
    this.introduction,
    required this.photos,
    this.encounterCount,
  });

  factory OtherProfile.fromJson(Map<String, dynamic> json) => OtherProfile(
    userId: json['userId'] as int,
    nickname: json['nickname'] as String,
    relationshipStatus: json['relationshipStatus'] as String?,
    gender: json['gender'] as String?,
    age: json['age'] as int?,
    hobbies:
        (json['hobbies'] as List<dynamic>?)
            ?.map((e) => HobbyItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    introduction: json['introduction'] as String?,
    photos:
        (json['photos'] as List<dynamic>?)
            ?.map((e) => OtherProfilePhoto.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    encounterCount: json['encounterCount'] as int?,
  );
}

class OtherProfilePhoto {
  final String url;
  final bool isMosaic;
  final bool isRepresentative;

  const OtherProfilePhoto({
    required this.url,
    required this.isMosaic,
    required this.isRepresentative,
  });

  factory OtherProfilePhoto.fromJson(Map<String, dynamic> json) =>
      OtherProfilePhoto(
        url: json['url'] as String,
        isMosaic: json['isMosaic'] as bool? ?? false,
        isRepresentative: json['isRepresentative'] as bool? ?? false,
      );
}
