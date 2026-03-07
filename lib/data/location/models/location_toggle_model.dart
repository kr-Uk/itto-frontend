import 'package:itto/domain/location/entities/location_toggle_result.dart';

class LocationToggleModel {
  final bool enabled;
  final String message;

  const LocationToggleModel({required this.enabled, required this.message});

  factory LocationToggleModel.fromJson(Map<String, dynamic> json) =>
      LocationToggleModel(
        enabled: json['enabled'] as bool,
        message: json['message'] as String? ?? '',
      );

  LocationToggleResult toEntity() =>
      LocationToggleResult(enabled: enabled, message: message);
}
