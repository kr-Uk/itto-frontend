import 'package:itto/domain/location/entities/h3_grid.dart';

class H3CellInfoModel {
  final String h3Index;
  final double centerLat;
  final double centerLng;
  final List<List<double>> boundary;

  const H3CellInfoModel({
    required this.h3Index,
    required this.centerLat,
    required this.centerLng,
    required this.boundary,
  });

  factory H3CellInfoModel.fromJson(Map<String, dynamic> json) {
    final center = json['center'] as Map<String, dynamic>;
    final boundaryRaw = json['boundary'] as List<dynamic>;
    return H3CellInfoModel(
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

  H3CellInfo toEntity() => H3CellInfo(
        h3Index: h3Index,
        centerLat: centerLat,
        centerLng: centerLng,
        boundary: boundary,
      );
}

class H3GridModel {
  final List<H3CellInfoModel> cells;
  final List<String> selectedIndexes;

  const H3GridModel({required this.cells, required this.selectedIndexes});

  factory H3GridModel.fromJson(Map<String, dynamic> json) => H3GridModel(
        cells: (json['cells'] as List<dynamic>)
            .map((e) => H3CellInfoModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        selectedIndexes: (json['selectedIndexes'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );

  H3Grid toEntity() => H3Grid(
        cells: cells.map((c) => c.toEntity()).toList(),
        selectedIndexes: selectedIndexes,
      );
}
