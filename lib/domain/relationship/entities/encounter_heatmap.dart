class EncounterHeatmap {
  final List<EncounterHeatmapCell> cells;
  final double centerLat;
  final double centerLng;

  const EncounterHeatmap({
    required this.cells,
    required this.centerLat,
    required this.centerLng,
  });
}

class EncounterHeatmapCell {
  final String h3Index;
  final List<List<double>> boundary;
  final double centerLat;
  final double centerLng;
  final int count;

  const EncounterHeatmapCell({
    required this.h3Index,
    required this.boundary,
    required this.centerLat,
    required this.centerLng,
    required this.count,
  });
}
