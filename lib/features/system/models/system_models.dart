class VersionInfo {
  final String minVersion;
  final String latestVersion;
  final bool forceUpdate;
  final String? updateUrl;

  const VersionInfo({
    required this.minVersion,
    required this.latestVersion,
    required this.forceUpdate,
    this.updateUrl,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) => VersionInfo(
        minVersion: json['minVersion'] as String? ?? '1.0.0',
        latestVersion: json['latestVersion'] as String? ?? '1.0.0',
        forceUpdate: json['forceUpdate'] as bool? ?? false,
        updateUrl: json['updateUrl'] as String?,
      );
}

class NicknameValidation {
  final bool valid;
  final String message;
  final String? code;

  const NicknameValidation({
    required this.valid,
    required this.message,
    this.code,
  });

  factory NicknameValidation.fromJson(Map<String, dynamic> json) =>
      NicknameValidation(
        valid: json['valid'] as bool? ?? false,
        message: json['message'] as String? ?? '',
        code: json['code'] as String?,
      );
}
