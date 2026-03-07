import 'package:itto/domain/common/entities/hobby.dart';
import 'package:itto/domain/common/entities/photo.dart';

class MyProfile {
  final int userId;
  final String nickname;
  final String gender;
  final String birthDate;
  final int age;
  final List<Hobby> hobbies;
  final String? introduction;
  final List<Photo> photos;
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
}
