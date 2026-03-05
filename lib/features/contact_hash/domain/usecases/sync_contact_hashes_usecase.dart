import '../repositories/contact_hash_repository.dart';
import 'hash_contacts_usecase.dart';

class SyncContactHashesUseCase {
  final ContactHashRepository repository;
  final HashContactsUseCase hashContactsUseCase;

  SyncContactHashesUseCase({
    required this.repository,
    required this.hashContactsUseCase,
  });

  Future<void> execute(List<String> phoneNumbers) async {
    final hashes = hashContactsUseCase.execute(phoneNumbers);
    await repository.uploadHashes(hashes);
  }
}
