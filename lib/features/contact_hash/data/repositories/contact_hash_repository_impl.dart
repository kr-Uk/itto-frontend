import '../../domain/entities/contact_hash.dart';
import '../../domain/repositories/contact_hash_repository.dart';
import '../datasources/contact_hash_remote_datasource.dart';

class ContactHashRepositoryImpl implements ContactHashRepository {
  final ContactHashRemoteDataSource remoteDataSource;

  ContactHashRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> uploadHashes(List<String> hashes) async {
    await remoteDataSource.uploadHashes(hashes);
  }

  @override
  Future<List<ContactHash>> getHashes() async {
    final models = await remoteDataSource.getHashes();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addManualBlock(String phoneNumber) async {
    await remoteDataSource.addManualBlock(phoneNumber);
  }

  @override
  Future<void> removeHash(int hashId) async {
    await remoteDataSource.removeHash(hashId);
  }
}
