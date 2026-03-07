import 'package:itto/core/network/api_client.dart';
import 'package:itto/data/common/models/page_response.dart';
import 'package:itto/data/relationship/models/encounter_location_model.dart';
import 'package:itto/data/relationship/models/relationship_detail_model.dart';
import 'package:itto/data/relationship/models/relationship_item_model.dart';

class RelationshipRemoteDataSource {
  final ApiClient _client;

  RelationshipRemoteDataSource(this._client);

  Future<PageResponse<RelationshipItemModel>> getList({
    required String status,
    int page = 0,
    int size = 20,
  }) async {
    final json = await _client.get(
      '/relationships',
      queryParameters: {'status': status, 'page': page, 'size': size},
    );
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return PageResponse.fromJson(data, RelationshipItemModel.fromJson);
  }

  Future<RelationshipDetailModel> getDetail(int relationshipId) async {
    final json = await _client.get('/relationships/$relationshipId');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return RelationshipDetailModel.fromJson(data);
  }

  Future<void> request(int relationshipId) async {
    await _client.post('/relationships/$relationshipId/request');
  }

  Future<void> cancel(int relationshipId) async {
    await _client.post('/relationships/$relationshipId/cancel');
  }

  Future<void> accept(int relationshipId) async {
    await _client.post('/relationships/$relationshipId/accept');
  }

  Future<void> reject(int relationshipId) async {
    await _client.post('/relationships/$relationshipId/reject');
  }

  Future<void> deleteRelationship(int relationshipId) async {
    await _client.post('/relationships/$relationshipId/delete');
  }

  Future<void> convert(int relationshipId) async {
    await _client.post('/relationships/$relationshipId/convert');
  }

  Future<void> restore(int relationshipId) async {
    await _client.post('/relationships/$relationshipId/restore');
  }

  Future<void> restoreAccept(int relationshipId) async {
    await _client.post('/relationships/$relationshipId/restore/accept');
  }

  Future<void> restoreReject(int relationshipId) async {
    await _client.post('/relationships/$relationshipId/restore/reject');
  }

  Future<EncounterLocationModel> getEncounterLocation(
    int relationshipId,
  ) async {
    final json = await _client.get(
      '/relationships/$relationshipId/encounter-location',
    );
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return EncounterLocationModel.fromJson(data);
  }
}
