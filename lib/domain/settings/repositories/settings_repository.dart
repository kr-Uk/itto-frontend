import 'package:itto/domain/settings/entities/matching_settings.dart';
import 'package:itto/domain/settings/entities/notification_settings.dart';

abstract class SettingsRepository {
  Future<MatchingSettings> getMatchingSettings();
  Future<void> updateMatchingSettings(MatchingSettings settings);
  Future<NotificationSettings> getNotificationSettings();
  Future<void> updateNotificationSettings(NotificationSettings settings);
}
