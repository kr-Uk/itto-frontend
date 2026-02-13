import '../../../core/network/api_client.dart';
import '../models/block_models.dart';

class BlockService {
  final ApiClient _client;

  BlockService(this._client);

  Future<List<BlockItem>> listBlocks() async {
    final json = await _client.get('/blocks');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return (data['blocks'] as List<dynamic>?)
            ?.map((e) => BlockItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  Future<void> blockUser(int targetUserId) async {
    await _client.post('/blocks', data: {'targetUserId': targetUserId});
  }

  Future<void> unblock(int blockId) async {
    await _client.delete('/blocks/$blockId');
  }

  Future<void> report(ReportRequest request) async {
    await _client.post('/reports', data: request.toJson());
  }
}
