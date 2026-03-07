import 'package:itto/domain/system/entities/version_info.dart';

class VersionInfoModel {
  final String minVersion;
  final String latestVersion;
  final bool forceUpdate;
  final String? updateUrl;

  const VersionInfoModel({
    required this.minVersion,
    required this.latestVersion,
    required this.forceUpdate,
    this.updateUrl,
  });

  factory VersionInfoModel.fromJson(Map<String, dynamic> json) =>
      VersionInfoModel(
        minVersion: json['minVersion'] as String? ?? '1.0.0',
        latestVersion: json['latestVersion'] as String? ?? '1.0.0',
        forceUpdate: json['forceUpdate'] as bool? ?? false,
        updateUrl: json['updateUrl'] as String?,
      );

  VersionInfo toEntity() => VersionInfo(
        minVersion: minVersion,
        latestVersion: latestVersion,
        forceUpdate: forceUpdate,
        updateUrl: updateUrl,
      );
}
