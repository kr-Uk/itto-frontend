import 'package:itto/domain/location/entities/excluded_area.dart';

class ExcludedAreaModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int radius;
  final List<String> h3Indexes;

  const ExcludedAreaModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.h3Indexes = const [],
  });

  factory ExcludedAreaModel.fromJson(Map<String, dynamic> json) =>
      ExcludedAreaModel(
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

  ExcludedArea toEntity() => ExcludedArea(
        id: id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        h3Indexes: h3Indexes,
      );
}
