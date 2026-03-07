import 'package:itto/core/network/api_client.dart';
import 'package:itto/data/common/models/hobby_model.dart';
import 'package:itto/data/system/models/nickname_validation_model.dart';
import 'package:itto/data/system/models/version_info_model.dart';

class SystemRemoteDataSource {
  final ApiClient _client;

  SystemRemoteDataSource(this._client);

  Future<VersionInfoModel> checkVersion() async {
    final json = await _client.get('/system/version');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return VersionInfoModel.fromJson(data);
  }

  Future<List<HobbyModel>> getHobbies() async {
    final json = await _client.get('/hobbies');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return (data['hobbies'] as List<dynamic>?)
            ?.map((e) => HobbyModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  Future<NicknameValidationModel> validateNickname(String nickname) async {
    final json = await _client.post(
      '/nickname/validate',
      data: {'nickname': nickname},
    );
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return NicknameValidationModel.fromJson(data);
  }
}
