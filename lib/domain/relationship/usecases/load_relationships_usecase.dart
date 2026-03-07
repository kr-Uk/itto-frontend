import 'package:itto/data/common/models/page_response.dart';
import 'package:itto/domain/relationship/entities/relationship.dart';
import 'package:itto/domain/relationship/repositories/relationship_repository.dart';

class LoadRelationshipsUseCase {
  final RelationshipRepository repository;

  LoadRelationshipsUseCase({required this.repository});

  Future<PageResponse<Relationship>> execute({
    required String status,
    int page = 0,
    int size = 20,
  }) =>
      repository.getList(status: status, page: page, size: size);
}
