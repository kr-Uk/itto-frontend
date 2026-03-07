import 'package:itto/domain/block/entities/block_item.dart';
import 'package:itto/domain/block/entities/report_request.dart';
import 'package:itto/domain/block/repositories/block_repository.dart';
import 'package:itto/data/block/datasources/block_remote_datasource.dart';
import 'package:itto/data/block/models/report_request_model.dart';

class BlockRepositoryImpl implements BlockRepository {
  final BlockRemoteDataSource remoteDataSource;

  BlockRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BlockItem>> listBlocks() async {
    final models = await remoteDataSource.listBlocks();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> blockUser(int targetUserId) =>
      remoteDataSource.blockUser(targetUserId);

  @override
  Future<void> unblock(int blockId) => remoteDataSource.unblock(blockId);

  @override
  Future<void> report(ReportRequest request) {
    final model = ReportRequestModel.fromEntity(request);
    return remoteDataSource.report(model.toJson());
  }
}
