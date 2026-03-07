import 'package:itto/domain/relationship/repositories/relationship_repository.dart';

class RequestInyeonUseCase {
  final RelationshipRepository repository;

  RequestInyeonUseCase({required this.repository});

  Future<void> execute(int relationshipId) =>
      repository.request(relationshipId);
}
