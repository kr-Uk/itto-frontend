class ExcludedArea {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int radius;
  final List<String> h3Indexes;

  const ExcludedArea({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.h3Indexes = const [],
  });

  factory ExcludedArea.fromJson(Map<String, dynamic> json) => ExcludedArea(
        id: json['id'] as int,
        name: json['name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        radius: json['radius'] as int? ?? 100,
        h3Indexes: (json['h3Indexes'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );
}

class LocationToggleResponse {
  final bool enabled;
  final String message;

  const LocationToggleResponse({
    required this.enabled,
    required this.message,
  });

  factory LocationToggleResponse.fromJson(Map<String, dynamic> json) =>
      LocationToggleResponse(
        enabled: json['enabled'] as bool,
        message: json['message'] as String? ?? '',
      );
}
