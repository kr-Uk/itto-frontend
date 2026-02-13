import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/signup_models.dart';

class SignupService {
  final ApiClient _client;

  SignupService(this._client);

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
      formData.files.add(MapEntry(
        'photos',
        await MultipartFile.fromFile(path),
      ));
    }
    formData.fields.add(MapEntry('representativeIndex', representativeIndex.toString()));

    final json = await _client.postMultipart('/signup/photos', formData: formData);
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return PhotoUploadResponse.fromJson(data);
  }

  Future<Map<String, dynamic>> uploadVerification(String filePath) async {
    final formData = FormData.fromMap({
      'selfie': await MultipartFile.fromFile(filePath),
    });
    final json = await _client.postMultipart('/signup/verification', formData: formData);
    return json['data'] as Map<String, dynamic>? ?? json;
  }

  Future<void> complete() async {
    await _client.post('/signup/complete');
  }
}
