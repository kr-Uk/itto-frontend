import 'package:itto/core/network/api_client.dart';
import 'package:itto/data/location/models/excluded_area_model.dart';
import 'package:itto/data/location/models/h3_grid_model.dart';
import 'package:itto/data/location/models/location_toggle_model.dart';

class LocationRemoteDataSource {
  final ApiClient _client;

  LocationRemoteDataSource(this._client);

  Future<void> sendLocation({
    required double latitude,
    required double longitude,
    required double accuracy,
    required String timestamp,
  }) async {
    await _client.post(
      '/location',
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'timestamp': timestamp,
      },
    );
  }

  Future<LocationToggleModel> toggle(bool enabled) async {
    final json = await _client.put(
      '/location/toggle',
      data: {'enabled': enabled},
    );
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return LocationToggleModel.fromJson(data);
  }

  Future<List<ExcludedAreaModel>> listExcluded() async {
    final json = await _client.get('/location/excluded');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return (data['excludedAreas'] as List<dynamic>?)
            ?.map(
                (e) => ExcludedAreaModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  Future<ExcludedAreaModel> addExcluded({
    required String name,
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    final json = await _client.post(
      '/location/excluded',
      data: {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      },
    );
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return ExcludedAreaModel.fromJson(data);
  }

  Future<void> deleteExcluded(int id) async {
    await _client.delete('/location/excluded/$id');
  }

  Future<H3GridModel> getH3Grid({
    required double latitude,
    required double longitude,
    int k = 4,
  }) async {
    final json = await _client.post(
      '/location/h3/grid',
      data: {'latitude': latitude, 'longitude': longitude, 'k': k},
    );
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return H3GridModel.fromJson(data);
  }

  Future<void> saveExcludedCells(List<String> h3Indexes) async {
    await _client.put(
      '/location/excluded/cells',
      data: {'h3Indexes': h3Indexes},
    );
  }
}
