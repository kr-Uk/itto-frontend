import 'package:itto/domain/location/entities/excluded_area.dart';
import 'package:itto/domain/location/entities/h3_grid.dart';
import 'package:itto/domain/location/repositories/location_repository.dart';

class ManageExcludedAreaUseCase {
  final LocationRepository repository;

  ManageExcludedAreaUseCase({required this.repository});

  Future<List<ExcludedArea>> list() => repository.listExcluded();

  Future<ExcludedArea> add({
    required String name,
    required double latitude,
    required double longitude,
    required int radius,
  }) =>
      repository.addExcluded(
        name: name,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

  Future<void> delete(int id) => repository.deleteExcluded(id);

  Future<H3Grid> getH3Grid({
    required double latitude,
    required double longitude,
    int k = 4,
  }) =>
      repository.getH3Grid(latitude: latitude, longitude: longitude, k: k);

  Future<void> saveExcludedCells(List<String> h3Indexes) =>
      repository.saveExcludedCells(h3Indexes);
}
