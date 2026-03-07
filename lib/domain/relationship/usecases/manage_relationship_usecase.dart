import 'package:itto/domain/relationship/entities/encounter_location.dart';
import 'package:itto/domain/relationship/entities/relationship_detail.dart';
import 'package:itto/domain/relationship/repositories/relationship_repository.dart';

class ManageRelationshipUseCase {
  final RelationshipRepository repository;

  ManageRelationshipUseCase({required this.repository});

  Future<RelationshipDetail> getDetail(int relationshipId) =>
      repository.getDetail(relationshipId);

  Future<void> cancel(int relationshipId) =>
      repository.cancel(relationshipId);

  Future<void> accept(int relationshipId) =>
      repository.accept(relationshipId);

  Future<void> reject(int relationshipId) =>
      repository.reject(relationshipId);

  Future<void> delete(int relationshipId) =>
      repository.deleteRelationship(relationshipId);

  Future<void> convert(int relationshipId) =>
      repository.convert(relationshipId);

  Future<void> restore(int relationshipId) =>
      repository.restore(relationshipId);

  Future<void> restoreAccept(int relationshipId) =>
      repository.restoreAccept(relationshipId);

  Future<void> restoreReject(int relationshipId) =>
      repository.restoreReject(relationshipId);

  Future<EncounterLocation> getEncounterLocation(int relationshipId) =>
      repository.getEncounterLocation(relationshipId);
}
