import 'package:itto/domain/system/entities/nickname_validation.dart';
import 'package:itto/domain/system/repositories/system_repository.dart';

class ValidateNicknameUseCase {
  final SystemRepository repository;

  ValidateNicknameUseCase({required this.repository});

  Future<NicknameValidation> execute(String nickname) =>
      repository.validateNickname(nickname);
}
