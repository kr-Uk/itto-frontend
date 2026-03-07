import 'package:itto/domain/location/entities/excluded_area.dart';
import 'package:itto/domain/location/entities/h3_grid.dart';
import 'package:itto/domain/location/entities/location_toggle_result.dart';
import 'package:itto/domain/location/repositories/location_repository.dart';
import 'package:itto/data/location/datasources/location_remote_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;

  LocationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> sendLocation({
    required double latitude,
    required double longitude,
    required double accuracy,
    required String timestamp,
  }) =>
      remoteDataSource.sendLocation(
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        timestamp: timestamp,
      );

  @override
  Future<LocationToggleResult> toggle(bool enabled) async {
    final model = await remoteDataSource.toggle(enabled);
    return model.toEntity();
  }

  @override
  Future<List<ExcludedArea>> listExcluded() async {
    final models = await remoteDataSource.listExcluded();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ExcludedArea> addExcluded({
    required String name,
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    final model = await remoteDataSource.addExcluded(
      name: name,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteExcluded(int id) => remoteDataSource.deleteExcluded(id);

  @override
  Future<H3Grid> getH3Grid({
    required double latitude,
    required double longitude,
    int k = 4,
  }) async {
    final model = await remoteDataSource.getH3Grid(
      latitude: latitude,
      longitude: longitude,
      k: k,
    );
    return model.toEntity();
  }

  @override
  Future<void> saveExcludedCells(List<String> h3Indexes) =>
      remoteDataSource.saveExcludedCells(h3Indexes);
}
