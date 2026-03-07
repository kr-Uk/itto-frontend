import 'package:itto/domain/common/entities/hobby.dart';
import 'package:itto/domain/system/entities/nickname_validation.dart';
import 'package:itto/domain/system/entities/version_info.dart';

abstract class SystemRepository {
  Future<VersionInfo> checkVersion();
  Future<List<Hobby>> getHobbies();
  Future<NicknameValidation> validateNickname(String nickname);
}
