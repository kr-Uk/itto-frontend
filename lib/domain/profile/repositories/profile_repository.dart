import 'package:itto/domain/common/entities/hobby.dart';
import 'package:itto/domain/common/entities/photo.dart';
import 'package:itto/domain/profile/entities/my_profile.dart';
import 'package:itto/domain/profile/entities/other_profile.dart';

abstract class ProfileRepository {
  Future<MyProfile> getMyProfile();
  Future<void> updateProfile({
    String? nickname,
    List<int>? hobbyIds,
    String? introduction,
  });
  Future<List<Photo>> updatePhotos({
    List<String>? newPhotoPaths,
    List<int>? existingPhotoIds,
    required int representativeIndex,
  });
  Future<void> deletePhoto(int photoId);
  Future<void> reverify(String filePath);
  Future<List<Hobby>> getHobbies();
  Future<OtherProfile> getOtherProfile(int userId);
}
