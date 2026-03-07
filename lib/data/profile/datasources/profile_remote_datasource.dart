import 'package:dio/dio.dart';
import 'package:itto/core/network/api_client.dart';
import 'package:itto/data/common/models/hobby_model.dart';
import 'package:itto/data/common/models/photo_model.dart';
import 'package:itto/data/profile/models/my_profile_model.dart';
import 'package:itto/data/profile/models/other_profile_model.dart';

class ProfileRemoteDataSource {
  final ApiClient _client;

  ProfileRemoteDataSource(this._client);

  Future<MyProfileModel> getMyProfile() async {
    final json = await _client.get('/profile/me');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return MyProfileModel.fromJson(data);
  }

  Future<void> updateProfile({
    String? nickname,
    List<int>? hobbyIds,
    String? introduction,
  }) async {
    await _client.patch(
      '/profile/me',
      data: {
        if (nickname != null) 'nickname': nickname,
        if (hobbyIds != null) 'hobbyIds': hobbyIds,
        if (introduction != null) 'introduction': introduction,
      },
    );
  }

  Future<List<PhotoModel>> updatePhotos({
    List<String>? newPhotoPaths,
    List<int>? existingPhotoIds,
    required int representativeIndex,
  }) async {
    final formData = FormData();
    if (newPhotoPaths != null) {
      for (final path in newPhotoPaths) {
        formData.files.add(
          MapEntry('photos', await MultipartFile.fromFile(path)),
        );
      }
    }
    if (existingPhotoIds != null) {
      for (final id in existingPhotoIds) {
        formData.fields.add(MapEntry('existingPhotoIds', id.toString()));
      }
    }
    formData.fields.add(
      MapEntry('representativeIndex', representativeIndex.toString()),
    );

    final json = await _client.putMultipart(
      '/profile/photos',
      formData: formData,
    );
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final photos = data['photos'] as List<dynamic>? ?? [];
    return photos
        .map((e) => PhotoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deletePhoto(int photoId) async {
    await _client.delete('/profile/photos/$photoId');
  }

  Future<void> reverify(String filePath) async {
    final formData = FormData.fromMap({
      'selfie': await MultipartFile.fromFile(filePath),
    });
    await _client.postMultipart('/profile/reverify', formData: formData);
  }

  Future<List<HobbyModel>> getHobbies() async {
    final json = await _client.get('/hobbies');
    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => HobbyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OtherProfileModel> getOtherProfile(int userId) async {
    final json = await _client.get('/profile/$userId');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return OtherProfileModel.fromJson(data);
  }
}
