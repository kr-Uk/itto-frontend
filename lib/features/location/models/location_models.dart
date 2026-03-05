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
    h3Indexes:
        (json['h3Indexes'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
  );
}

class H3CellInfo {
  final String h3Index;
  final double centerLat;
  final double centerLng;
  final List<List<double>> boundary;

  const H3CellInfo({
    required this.h3Index,
    required this.centerLat,
    required this.centerLng,
    required this.boundary,
  });

  factory H3CellInfo.fromJson(Map<String, dynamic> json) {
    final center = json['center'] as Map<String, dynamic>;
    final boundaryRaw = json['boundary'] as List<dynamic>;
    return H3CellInfo(
      h3Index: json['h3Index'] as String,
      centerLat: (center['latitude'] as num).toDouble(),
      centerLng: (center['longitude'] as num).toDouble(),
      boundary: boundaryRaw
          .map(
            (e) =>
                (e as List<dynamic>).map((v) => (v as num).toDouble()).toList(),
          )
          .toList(),
    );
  }
}

class H3GridResponse {
  final List<H3CellInfo> cells;
  final List<String> selectedIndexes;

  const H3GridResponse({required this.cells, required this.selectedIndexes});

  factory H3GridResponse.fromJson(Map<String, dynamic> json) {
    return H3GridResponse(
      cells: (json['cells'] as List<dynamic>)
          .map((e) => H3CellInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      selectedIndexes:
          (json['selectedIndexes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class LocationToggleResponse {
  final bool enabled;
  final String message;

  const LocationToggleResponse({required this.enabled, required this.message});

  factory LocationToggleResponse.fromJson(Map<String, dynamic> json) =>
      LocationToggleResponse(
        enabled: json['enabled'] as bool,
        message: json['message'] as String? ?? '',
      );
}
