import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../profile/models/profile_models.dart';
import '../models/signup_models.dart';

class SignupService {
  final ApiClient _client;

  SignupService(this._client);

  Future<List<HobbyItem>> getHobbies() async {
    final json = await _client.get('/hobbies');
    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => HobbyItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTerms(SignupTermsRequest request) async {
    await _client.post('/signup/terms', data: request.toJson());
  }

  Future<void> saveProfile(SignupProfileRequest request) async {
    await _client.post('/signup/profile', data: request.toJson());
  }

  Future<PhotoUploadResponse> uploadPhotos({
    required List<String> filePaths,
    required int representativeIndex,
  }) async {
    final formData = FormData();
    for (final path in filePaths) {
      formData.files.add(
        MapEntry('photos', await MultipartFile.fromFile(path)),
      );
    }
    formData.fields.add(
      MapEntry('representativeIndex', representativeIndex.toString()),
    );

    final json = await _client.postMultipart(
      '/signup/photos',
      formData: formData,
    );
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return PhotoUploadResponse.fromJson(data);
  }

  Future<void> complete() async {
    await _client.post('/signup/complete');
  }
}
