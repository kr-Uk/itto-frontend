import '../../../core/network/api_client.dart';
import '../models/location_models.dart';

class LocationService {
  final ApiClient _client;

  LocationService(this._client);

  Future<void> sendLocation({
    required String h3Index,
    required double latitude,
    required double longitude,
    required double accuracy,
    required String timestamp,
  }) async {
    await _client.post('/location', data: {
      'h3Index': h3Index,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': timestamp,
    });
  }

  Future<LocationToggleResponse> toggle(bool enabled) async {
    final json = await _client.put('/location/toggle', data: {'enabled': enabled});
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return LocationToggleResponse.fromJson(data);
  }

  Future<List<ExcludedArea>> listExcluded() async {
    final json = await _client.get('/location/excluded');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return (data['excludedAreas'] as List<dynamic>?)
            ?.map((e) => ExcludedArea.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  Future<ExcludedArea> addExcluded({
    required String name,
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    final json = await _client.post('/location/excluded', data: {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    });
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return ExcludedArea.fromJson(data);
  }

  Future<void> deleteExcluded(int id) async {
    await _client.delete('/location/excluded/$id');
  }
}
