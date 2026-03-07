import 'package:itto/domain/location/entities/excluded_area.dart';
import 'package:itto/domain/location/entities/h3_grid.dart';
import 'package:itto/domain/location/entities/location_toggle_result.dart';

abstract class LocationRepository {
  Future<void> sendLocation({
    required double latitude,
    required double longitude,
    required double accuracy,
    required String timestamp,
  });
  Future<LocationToggleResult> toggle(bool enabled);
  Future<List<ExcludedArea>> listExcluded();
  Future<ExcludedArea> addExcluded({
    required String name,
    required double latitude,
    required double longitude,
    required int radius,
  });
  Future<void> deleteExcluded(int id);
  Future<H3Grid> getH3Grid({
    required double latitude,
    required double longitude,
    int k = 4,
  });
  Future<void> saveExcludedCells(List<String> h3Indexes);
}
