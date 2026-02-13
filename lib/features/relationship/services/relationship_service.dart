import '../../../core/network/api_client.dart';
import '../../../shared/models/page_response.dart';
import '../models/relationship_models.dart';

class RelationshipService {
  final ApiClient _client;

  RelationshipService(this._client);

  Future<PageResponse<RelationshipItem>> getList({
    required String status,
    int page = 0,
    int size = 20,
  }) async {
    final json = await _client.get('/relationships', queryParameters: {
      'status': status,
      'page': page,
      'size': size,
    });
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return PageResponse.fromJson(data, RelationshipItem.fromJson);
  }

  Future<RelationshipDetail> getDetail(int relationshipId) async {
    final json = await _client.get('/relationships/$relationshipId');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return RelationshipDetail.fromJson(data);
  }

  Future<Map<String, dynamic>> request(int relationshipId) async {
    final json = await _client.post('/relationships/$relationshipId/request');
    return json['data'] as Map<String, dynamic>? ?? json;
  }

  Future<Map<String, dynamic>> cancel(int relationshipId) async {
    final json = await _client.post('/relationships/$relationshipId/cancel');
    return json['data'] as Map<String, dynamic>? ?? json;
  }

  Future<Map<String, dynamic>> accept(int relationshipId) async {
    final json = await _client.post('/relationships/$relationshipId/accept');
    return json['data'] as Map<String, dynamic>? ?? json;
  }

  Future<Map<String, dynamic>> reject(int relationshipId) async {
    final json = await _client.post('/relationships/$relationshipId/reject');
    return json['data'] as Map<String, dynamic>? ?? json;
  }

  Future<Map<String, dynamic>> deleteRelationship(int relationshipId) async {
    final json = await _client.post('/relationships/$relationshipId/delete');
    return json['data'] as Map<String, dynamic>? ?? json;
  }

  Future<Map<String, dynamic>> convert(int relationshipId) async {
    final json = await _client.post('/relationships/$relationshipId/convert');
    return json['data'] as Map<String, dynamic>? ?? json;
  }

  Future<Map<String, dynamic>> restore(int relationshipId) async {
    final json = await _client.post('/relationships/$relationshipId/restore');
    return json['data'] as Map<String, dynamic>? ?? json;
  }

  Future<Map<String, dynamic>> restoreAccept(int relationshipId) async {
    final json = await _client.post('/relationships/$relationshipId/restore/accept');
    return json['data'] as Map<String, dynamic>? ?? json;
  }

  Future<Map<String, dynamic>> restoreReject(int relationshipId) async {
    final json = await _client.post('/relationships/$relationshipId/restore/reject');
    return json['data'] as Map<String, dynamic>? ?? json;
  }

  Future<EncounterLocation> getEncounterLocation(int relationshipId) async {
    final json = await _client.get('/relationships/$relationshipId/encounter-location');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return EncounterLocation.fromJson(data);
  }
}
