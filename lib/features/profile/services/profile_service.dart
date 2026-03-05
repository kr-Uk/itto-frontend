import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/profile_models.dart';
import '../../auth/models/signup_models.dart';

class ProfileService {
  final ApiClient _client;

  ProfileService(this._client);

  Future<MyProfile> getMyProfile() async {
    final json = await _client.get('/profile/me');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return MyProfile.fromJson(data);
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

  Future<PhotoUploadResponse> updatePhotos({
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
    return PhotoUploadResponse.fromJson(data);
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

  Future<List<HobbyItem>> getHobbies() async {
    final json = await _client.get('/hobbies');
    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => HobbyItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OtherProfile> getOtherProfile(int userId) async {
    final json = await _client.get('/profile/$userId');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return OtherProfile.fromJson(data);
  }
}
