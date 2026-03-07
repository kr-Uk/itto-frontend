import 'package:itto/domain/common/entities/hobby.dart';
import 'package:itto/domain/common/entities/photo.dart';

abstract class SignupRepository {
  Future<List<Hobby>> getHobbies();
  Future<void> saveTerms({
    required bool serviceTerms,
    required bool privacyPolicy,
    required bool locationTerms,
    bool marketingConsent = false,
  });
  Future<void> saveProfile({
    required String nickname,
    required String gender,
    required String birthDate,
    required List<int> hobbyIds,
    String? introduction,
  });
  Future<List<Photo>> uploadPhotos({
    required List<String> filePaths,
    required int representativeIndex,
  });
  Future<void> complete();
}
