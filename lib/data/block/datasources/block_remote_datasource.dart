import 'package:itto/core/network/api_client.dart';
import 'package:itto/data/block/models/block_item_model.dart';

class BlockRemoteDataSource {
  final ApiClient _client;

  BlockRemoteDataSource(this._client);

  Future<List<BlockItemModel>> listBlocks() async {
    final json = await _client.get('/blocks');
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return (data['blocks'] as List<dynamic>?)
            ?.map((e) => BlockItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  Future<void> blockUser(int targetUserId) async {
    await _client.post('/blocks', data: {'targetUserId': targetUserId});
  }

  Future<void> unblock(int blockId) async {
    await _client.delete('/blocks/$blockId');
  }

  Future<void> report(Map<String, dynamic> data) async {
    await _client.post('/reports', data: data);
  }
}
