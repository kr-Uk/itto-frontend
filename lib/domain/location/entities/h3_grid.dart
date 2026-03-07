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
}

class H3Grid {
  final List<H3CellInfo> cells;
  final List<String> selectedIndexes;

  const H3Grid({required this.cells, required this.selectedIndexes});
}
