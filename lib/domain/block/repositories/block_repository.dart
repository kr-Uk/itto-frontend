import 'package:itto/domain/block/entities/block_item.dart';
import 'package:itto/domain/block/entities/report_request.dart';

abstract class BlockRepository {
  Future<List<BlockItem>> listBlocks();
  Future<void> blockUser(int targetUserId);
  Future<void> unblock(int blockId);
  Future<void> report(ReportRequest request);
}
