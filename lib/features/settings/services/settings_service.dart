import '../../../core/network/api_client.dart';
import '../models/settings_models.dart';

class SettingsService {
  final ApiClient _client;

  SettingsService(this._client);

  Future<MatchingSettings> getMatchingSettings() async {
    final json = await _client.get('/settings/matching');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return MatchingSettings.fromJson(data);
  }

  Future<void> updateMatchingSettings(MatchingSettings settings) async {
    await _client.put('/settings/matching', data: settings.toJson());
  }

  Future<NotificationSettings> getNotificationSettings() async {
    final json = await _client.get('/settings/notifications');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return NotificationSettings.fromJson(data);
  }

  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    await _client.put('/settings/notifications', data: settings.toJson());
  }
}
