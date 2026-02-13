import '../../../core/network/api_client.dart';
import '../../profile/models/profile_models.dart';
import '../models/system_models.dart';

class SystemService {
  final ApiClient _client;

  SystemService(this._client);

  Future<VersionInfo> checkVersion() async {
    final json = await _client.get('/system/version');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return VersionInfo.fromJson(data);
  }

  Future<List<HobbyItem>> getHobbies() async {
    final json = await _client.get('/hobbies');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return (data['hobbies'] as List<dynamic>?)
            ?.map((e) => HobbyItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  Future<NicknameValidation> validateNickname(String nickname) async {
    final json = await _client.post('/nickname/validate', data: {
      'nickname': nickname,
    });
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return NicknameValidation.fromJson(data);
  }
}
