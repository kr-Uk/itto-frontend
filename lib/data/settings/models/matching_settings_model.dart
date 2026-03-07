import 'package:itto/domain/settings/entities/matching_settings.dart';

class MatchingSettingsModel {
  final String? genderFilter;
  final int ageRangeMin;
  final int ageRangeMax;

  const MatchingSettingsModel({
    this.genderFilter,
    required this.ageRangeMin,
    required this.ageRangeMax,
  });

  factory MatchingSettingsModel.fromJson(Map<String, dynamic> json) =>
      MatchingSettingsModel(
        genderFilter: json['genderFilter'] as String?,
        ageRangeMin: json['ageRangeMin'] as int? ?? 20,
        ageRangeMax: json['ageRangeMax'] as int? ?? 35,
      );

  factory MatchingSettingsModel.fromEntity(MatchingSettings entity) =>
      MatchingSettingsModel(
        genderFilter: entity.genderFilter,
        ageRangeMin: entity.ageRangeMin,
        ageRangeMax: entity.ageRangeMax,
      );

  Map<String, dynamic> toJson() => {
        'genderFilter': genderFilter,
        'ageRangeMin': ageRangeMin,
        'ageRangeMax': ageRangeMax,
      };

  MatchingSettings toEntity() => MatchingSettings(
        genderFilter: genderFilter,
        ageRangeMin: ageRangeMin,
        ageRangeMax: ageRangeMax,
      );
}
