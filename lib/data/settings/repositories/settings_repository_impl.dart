import 'package:itto/domain/settings/entities/matching_settings.dart';
import 'package:itto/domain/settings/entities/notification_settings.dart';
import 'package:itto/domain/settings/repositories/settings_repository.dart';
import 'package:itto/data/settings/datasources/settings_remote_datasource.dart';
import 'package:itto/data/settings/models/matching_settings_model.dart';
import 'package:itto/data/settings/models/notification_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<MatchingSettings> getMatchingSettings() async {
    final model = await remoteDataSource.getMatchingSettings();
    return model.toEntity();
  }

  @override
  Future<void> updateMatchingSettings(MatchingSettings settings) {
    final model = MatchingSettingsModel.fromEntity(settings);
    return remoteDataSource.updateMatchingSettings(model.toJson());
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    final model = await remoteDataSource.getNotificationSettings();
    return model.toEntity();
  }

  @override
  Future<void> updateNotificationSettings(NotificationSettings settings) {
    final model = NotificationSettingsModel.fromEntity(settings);
    return remoteDataSource.updateNotificationSettings(model.toJson());
  }
}
