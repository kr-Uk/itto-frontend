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
}
