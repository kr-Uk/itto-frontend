import 'package:itto/domain/profile/entities/my_profile.dart';
import 'package:itto/domain/profile/repositories/profile_repository.dart';

class GetMyProfileUseCase {
  final ProfileRepository repository;

  GetMyProfileUseCase({required this.repository});

  Future<MyProfile> execute() => repository.getMyProfile();
}
