import 'package:itto/domain/contact_hash/repositories/contact_hash_repository.dart';
import 'package:itto/domain/contact_hash/usecases/hash_contacts_usecase.dart';

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
