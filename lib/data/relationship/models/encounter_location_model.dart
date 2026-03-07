import 'package:itto/domain/relationship/entities/encounter_location.dart';

class EncounterLocationModel {
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? encounterAt;
  final String? mapThumbnailUrl;

  const EncounterLocationModel({
    this.address,
    this.latitude,
    this.longitude,
    this.encounterAt,
    this.mapThumbnailUrl,
  });

  factory EncounterLocationModel.fromJson(Map<String, dynamic> json) =>
      EncounterLocationModel(
        address: json['address'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        encounterAt: json['encounterAt'] as String?,
        mapThumbnailUrl: json['mapThumbnailUrl'] as String?,
      );

  EncounterLocation toEntity() => EncounterLocation(
        address: address,
        latitude: latitude,
        longitude: longitude,
        encounterAt: encounterAt,
        mapThumbnailUrl: mapThumbnailUrl,
      );
}
