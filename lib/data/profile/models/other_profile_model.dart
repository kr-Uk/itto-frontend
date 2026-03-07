import 'package:itto/data/common/models/hobby_model.dart';
import 'package:itto/domain/profile/entities/other_profile.dart';

class OtherProfileModel {
  final int userId;
  final String nickname;
  final String? relationshipStatus;
  final String? gender;
  final int? age;
  final List<HobbyModel> hobbies;
  final String? introduction;
  final List<OtherProfilePhotoModel> photos;
  final int? encounterCount;

  const OtherProfileModel({
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

  factory OtherProfileModel.fromJson(Map<String, dynamic> json) =>
      OtherProfileModel(
        userId: json['userId'] as int,
        nickname: json['nickname'] as String,
        relationshipStatus: json['relationshipStatus'] as String?,
        gender: json['gender'] as String?,
        age: json['age'] as int?,
        hobbies: (json['hobbies'] as List<dynamic>?)
                ?.map((e) => HobbyModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        introduction: json['introduction'] as String?,
        photos: (json['photos'] as List<dynamic>?)
                ?.map((e) =>
                    OtherProfilePhotoModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        encounterCount: json['encounterCount'] as int?,
      );

  OtherProfile toEntity() => OtherProfile(
        userId: userId,
        nickname: nickname,
        relationshipStatus: relationshipStatus,
        gender: gender,
        age: age,
        hobbies: hobbies.map((h) => h.toEntity()).toList(),
        introduction: introduction,
        photos: photos.map((p) => p.toEntity()).toList(),
        encounterCount: encounterCount,
      );
}

class OtherProfilePhotoModel {
  final String url;
  final bool isMosaic;
  final bool isRepresentative;

  const OtherProfilePhotoModel({
    required this.url,
    required this.isMosaic,
    required this.isRepresentative,
  });

  factory OtherProfilePhotoModel.fromJson(Map<String, dynamic> json) =>
      OtherProfilePhotoModel(
        url: json['url'] as String,
        isMosaic: json['isMosaic'] as bool? ?? false,
        isRepresentative: json['isRepresentative'] as bool? ?? false,
      );

  OtherProfilePhoto toEntity() => OtherProfilePhoto(
        url: url,
        isMosaic: isMosaic,
        isRepresentative: isRepresentative,
      );
}
