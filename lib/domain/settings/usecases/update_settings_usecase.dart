import 'package:itto/domain/settings/entities/matching_settings.dart';
import 'package:itto/domain/settings/entities/notification_settings.dart';
import 'package:itto/domain/settings/repositories/settings_repository.dart';

class UpdateSettingsUseCase {
  final SettingsRepository repository;

  UpdateSettingsUseCase({required this.repository});

  Future<void> updateMatching(MatchingSettings settings) =>
      repository.updateMatchingSettings(settings);

  Future<void> updateNotification(NotificationSettings settings) =>
      repository.updateNotificationSettings(settings);
}
