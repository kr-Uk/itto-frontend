import 'package:itto/domain/common/entities/hobby.dart';

class OtherProfile {
  final int userId;
  final String nickname;
  final String? relationshipStatus;
  final String? gender;
  final int? age;
  final List<Hobby> hobbies;
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
}
