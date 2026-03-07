import 'package:itto/domain/profile/repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase({required this.repository});

  Future<void> execute({
    String? nickname,
    List<int>? hobbyIds,
    String? introduction,
  }) =>
      repository.updateProfile(
        nickname: nickname,
        hobbyIds: hobbyIds,
        introduction: introduction,
      );
}
