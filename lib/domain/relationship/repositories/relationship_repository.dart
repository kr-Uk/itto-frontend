import 'package:itto/domain/common/entities/page_response.dart';
import 'package:itto/domain/relationship/entities/encounter_heatmap.dart';
import 'package:itto/domain/relationship/entities/encounter_location.dart';
import 'package:itto/domain/relationship/entities/relationship.dart';
import 'package:itto/domain/relationship/entities/relationship_detail.dart';

abstract class RelationshipRepository {
  Future<PageResponse<Relationship>> getList({
    required String status,
    int page = 0,
    int size = 20,
  });
  Future<RelationshipDetail> getDetail(int relationshipId);
  Future<void> request(int relationshipId);
  Future<void> cancel(int relationshipId);
  Future<Map<String, dynamic>> accept(int relationshipId);
  Future<void> reject(int relationshipId);
  Future<void> deleteRelationship(int relationshipId);
  Future<void> convert(int relationshipId);
  Future<void> restore(int relationshipId);
  Future<void> restoreAccept(int relationshipId);
  Future<void> restoreReject(int relationshipId);
  Future<EncounterLocation> getEncounterLocation(int relationshipId);
  Future<EncounterHeatmap> getEncounterHeatmap({
    required double latitude,
    required double longitude,
  });
}
