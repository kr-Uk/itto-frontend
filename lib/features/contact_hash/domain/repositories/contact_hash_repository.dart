import '../entities/contact_hash.dart';

abstract class ContactHashRepository {
  Future<void> uploadHashes(List<String> hashes);
  Future<List<ContactHash>> getHashes();
  Future<void> addManualBlock(String phoneNumber);
  Future<void> removeHash(int hashId);
}
