import 'package:itto/domain/settings/entities/matching_settings.dart';
import 'package:itto/domain/settings/entities/notification_settings.dart';
import 'package:itto/domain/settings/repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository repository;

  GetSettingsUseCase({required this.repository});

  Future<MatchingSettings> getMatchingSettings() =>
      repository.getMatchingSettings();

  Future<NotificationSettings> getNotificationSettings() =>
      repository.getNotificationSettings();
}
