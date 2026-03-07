import 'package:itto/core/network/api_client.dart';
import 'package:itto/data/settings/models/matching_settings_model.dart';
import 'package:itto/data/settings/models/notification_settings_model.dart';

class SettingsRemoteDataSource {
  final ApiClient _client;

  SettingsRemoteDataSource(this._client);

  Future<MatchingSettingsModel> getMatchingSettings() async {
    final json = await _client.get('/settings/matching');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return MatchingSettingsModel.fromJson(data);
  }

  Future<void> updateMatchingSettings(Map<String, dynamic> data) async {
    await _client.put('/settings/matching', data: data);
  }

  Future<NotificationSettingsModel> getNotificationSettings() async {
    final json = await _client.get('/settings/notifications');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return NotificationSettingsModel.fromJson(data);
  }

  Future<void> updateNotificationSettings(Map<String, dynamic> data) async {
    await _client.put('/settings/notifications', data: data);
  }
}
