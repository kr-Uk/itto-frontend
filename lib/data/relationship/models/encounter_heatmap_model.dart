import 'package:itto/domain/relationship/entities/encounter_heatmap.dart';

class EncounterHeatmapModel {
  final List<EncounterHeatmapCellModel> cells;
  final double centerLat;
  final double centerLng;

  const EncounterHeatmapModel({
    required this.cells,
    required this.centerLat,
    required this.centerLng,
  });

  factory EncounterHeatmapModel.fromJson(Map<String, dynamic> json) =>
      EncounterHeatmapModel(
        cells: (json['cells'] as List<dynamic>? ?? [])
            .map((e) =>
                EncounterHeatmapCellModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        centerLat: (json['centerLat'] as num).toDouble(),
        centerLng: (json['centerLng'] as num).toDouble(),
      );

  EncounterHeatmap toEntity() => EncounterHeatmap(
        cells: cells.map((c) => c.toEntity()).toList(),
        centerLat: centerLat,
        centerLng: centerLng,
      );
}

class EncounterHeatmapCellModel {
  final String h3Index;
  final List<List<double>> boundary;
  final double centerLat;
  final double centerLng;
  final int count;

  const EncounterHeatmapCellModel({
    required this.h3Index,
    required this.boundary,
    required this.centerLat,
    required this.centerLng,
    required this.count,
  });

  factory EncounterHeatmapCellModel.fromJson(Map<String, dynamic> json) =>
      EncounterHeatmapCellModel(
        h3Index: json['h3Index'] as String,
        boundary: (json['boundary'] as List<dynamic>)
            .map((point) => (point as List<dynamic>)
                .map((v) => (v as num).toDouble())
                .toList())
            .toList(),
        centerLat: (json['centerLat'] as num).toDouble(),
        centerLng: (json['centerLng'] as num).toDouble(),
        count: json['count'] as int,
      );

  EncounterHeatmapCell toEntity() => EncounterHeatmapCell(
        h3Index: h3Index,
        boundary: boundary,
        centerLat: centerLat,
        centerLng: centerLng,
        count: count,
      );
}
