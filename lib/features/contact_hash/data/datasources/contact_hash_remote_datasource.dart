import '../../../../core/network/api_client.dart';
import '../models/contact_hash_model.dart';

class ContactHashRemoteDataSource {
  final ApiClient apiClient;

  ContactHashRemoteDataSource({required this.apiClient});

  Future<int> uploadHashes(List<String> hashes) async {
    final response = await apiClient.post(
      '/contacts/hashes',
      data: {'hashes': hashes},
    );
    final data = response['data'] as Map<String, dynamic>;
    return data['uploadedCount'] as int;
  }

  Future<List<ContactHashModel>> getHashes() async {
    final response = await apiClient.get('/contacts/hashes');
    final data = response['data'] as Map<String, dynamic>;
    final hashList = data['hashes'] as List<dynamic>;
    return hashList
        .map((json) => ContactHashModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addManualBlock(String phoneNumber) async {
    await apiClient.post(
      '/contacts/block-by-phone',
      data: {'phoneNumber': phoneNumber},
    );
  }

  Future<void> removeHash(int hashId) async {
    await apiClient.delete('/contacts/hashes/$hashId');
  }
}
