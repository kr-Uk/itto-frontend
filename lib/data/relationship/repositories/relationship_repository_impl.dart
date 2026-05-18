import 'package:itto/data/common/models/page_response.dart';
import 'package:itto/domain/relationship/entities/encounter_heatmap.dart';
import 'package:itto/domain/relationship/entities/encounter_location.dart';
import 'package:itto/domain/relationship/entities/relationship.dart';
import 'package:itto/domain/relationship/entities/relationship_detail.dart';
import 'package:itto/domain/relationship/repositories/relationship_repository.dart';
import 'package:itto/data/relationship/datasources/relationship_remote_datasource.dart';

class RelationshipRepositoryImpl implements RelationshipRepository {
  final RelationshipRemoteDataSource remoteDataSource;

  RelationshipRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PageResponse<Relationship>> getList({
    required String status,
    int page = 0,
    int size = 20,
  }) async {
    final result =
        await remoteDataSource.getList(status: status, page: page, size: size);
    return PageResponse(
      content: result.content.map((m) => m.toEntity()).toList(),
      page: result.page,
      size: result.size,
      totalElements: result.totalElements,
      totalPages: result.totalPages,
    );
  }

  @override
  Future<RelationshipDetail> getDetail(int relationshipId) async {
    final model = await remoteDataSource.getDetail(relationshipId);
    return model.toEntity();
  }

  @override
  Future<void> request(int relationshipId) =>
      remoteDataSource.request(relationshipId);

  @override
  Future<void> cancel(int relationshipId) =>
      remoteDataSource.cancel(relationshipId);

  @override
  Future<Map<String, dynamic>> accept(int relationshipId) =>
      remoteDataSource.accept(relationshipId);

  @override
  Future<void> reject(int relationshipId) =>
      remoteDataSource.reject(relationshipId);

  @override
  Future<void> deleteRelationship(int relationshipId) =>
      remoteDataSource.deleteRelationship(relationshipId);

  @override
  Future<void> convert(int relationshipId) =>
      remoteDataSource.convert(relationshipId);

  @override
  Future<void> restore(int relationshipId) =>
      remoteDataSource.restore(relationshipId);

  @override
  Future<void> restoreAccept(int relationshipId) =>
      remoteDataSource.restoreAccept(relationshipId);

  @override
  Future<void> restoreReject(int relationshipId) =>
      remoteDataSource.restoreReject(relationshipId);

  @override
  Future<EncounterLocation> getEncounterLocation(int relationshipId) async {
    final model = await remoteDataSource.getEncounterLocation(relationshipId);
    return model.toEntity();
  }

  @override
  Future<EncounterHeatmap> getEncounterHeatmap({
    required double latitude,
    required double longitude,
  }) async {
    final model = await remoteDataSource.getEncounterHeatmap(
      latitude: latitude,
      longitude: longitude,
    );
    return model.toEntity();
  }
}
