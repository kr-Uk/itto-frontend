import 'package:itto/domain/common/entities/hobby.dart';
import 'package:itto/domain/common/entities/photo.dart';
import 'package:itto/domain/profile/entities/my_profile.dart';
import 'package:itto/domain/profile/entities/other_profile.dart';
import 'package:itto/domain/profile/repositories/profile_repository.dart';
import 'package:itto/data/profile/datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<MyProfile> getMyProfile() async {
    final model = await remoteDataSource.getMyProfile();
    return model.toEntity();
  }

  @override
  Future<void> updateProfile({
    String? nickname,
    List<int>? hobbyIds,
    String? introduction,
  }) =>
      remoteDataSource.updateProfile(
        nickname: nickname,
        hobbyIds: hobbyIds,
        introduction: introduction,
      );

  @override
  Future<List<Photo>> updatePhotos({
    List<String>? newPhotoPaths,
    List<int>? existingPhotoIds,
    required int representativeIndex,
  }) async {
    final models = await remoteDataSource.updatePhotos(
      newPhotoPaths: newPhotoPaths,
      existingPhotoIds: existingPhotoIds,
      representativeIndex: representativeIndex,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> deletePhoto(int photoId) =>
      remoteDataSource.deletePhoto(photoId);

  @override
  Future<void> reverify(String filePath) =>
      remoteDataSource.reverify(filePath);

  @override
  Future<List<Hobby>> getHobbies() async {
    final models = await remoteDataSource.getHobbies();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<OtherProfile> getOtherProfile(int userId) async {
    final model = await remoteDataSource.getOtherProfile(userId);
    return model.toEntity();
  }
}
