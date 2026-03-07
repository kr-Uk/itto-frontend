import 'package:dio/dio.dart';
import 'package:itto/core/network/api_client.dart';
import 'package:itto/data/common/models/hobby_model.dart';
import 'package:itto/data/common/models/photo_model.dart';

class SignupRemoteDataSource {
  final ApiClient _client;

  SignupRemoteDataSource(this._client);

  Future<List<HobbyModel>> getHobbies() async {
    final json = await _client.get('/hobbies');
    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => HobbyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTerms(Map<String, dynamic> data) async {
    await _client.post('/signup/terms', data: data);
  }

  Future<void> saveProfile(Map<String, dynamic> data) async {
    await _client.post('/signup/profile', data: data);
  }

  Future<List<PhotoModel>> uploadPhotos({
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
    final data = json['data'];
    if (data is List) {
      return data
          .map((e) => PhotoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    final mapData = data as Map<String, dynamic>;
    final photos = mapData['photos'] as List<dynamic>? ?? [];
    return photos
        .map((e) => PhotoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> complete() async {
    await _client.post('/signup/complete');
  }
}
