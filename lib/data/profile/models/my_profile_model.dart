import 'package:itto/data/common/models/hobby_model.dart';
import 'package:itto/data/common/models/photo_model.dart';
import 'package:itto/domain/profile/entities/my_profile.dart';

class MyProfileModel {
  final int userId;
  final String nickname;
  final String gender;
  final String birthDate;
  final int age;
  final List<HobbyModel> hobbies;
  final String? introduction;
  final List<PhotoModel> photos;
  final String verificationStatus;
  final int knots;
  final bool isPremium;
  final String createdAt;

  const MyProfileModel({
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

  factory MyProfileModel.fromJson(Map<String, dynamic> json) =>
      MyProfileModel(
        userId: json['userId'] as int,
        nickname: json['nickname'] as String? ?? '',
        gender: json['gender'] as String? ?? '',
        birthDate: json['birthDate'] as String? ?? '',
        age: json['age'] as int? ?? 0,
        hobbies: (json['hobbies'] as List<dynamic>?)
                ?.map((e) => HobbyModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        introduction: json['introduction'] as String?,
        photos: (json['photos'] as List<dynamic>?)
                ?.map((e) => PhotoModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        verificationStatus:
            json['verificationStatus'] as String? ?? 'NONE',
        knots: json['knots'] as int? ?? 0,
        isPremium: json['isPremium'] as bool? ?? false,
        createdAt: json['createdAt'] as String? ?? '',
      );

  MyProfile toEntity() => MyProfile(
        userId: userId,
        nickname: nickname,
        gender: gender,
        birthDate: birthDate,
        age: age,
        hobbies: hobbies.map((h) => h.toEntity()).toList(),
        introduction: introduction,
        photos: photos.map((p) => p.toEntity()).toList(),
        verificationStatus: verificationStatus,
        knots: knots,
        isPremium: isPremium,
        createdAt: createdAt,
      );
}
