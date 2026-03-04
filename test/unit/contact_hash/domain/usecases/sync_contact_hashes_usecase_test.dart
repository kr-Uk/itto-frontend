import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:itto/features/contact_hash/domain/entities/contact_hash.dart';
import 'package:itto/features/contact_hash/domain/repositories/contact_hash_repository.dart';
import 'package:itto/features/contact_hash/domain/usecases/hash_contacts_usecase.dart';
import 'package:itto/features/contact_hash/domain/usecases/sync_contact_hashes_usecase.dart';

class MockContactHashRepository extends Mock implements ContactHashRepository {}

void main() {
  late MockContactHashRepository mockRepository;
  late HashContactsUseCase hashContactsUseCase;
  late SyncContactHashesUseCase useCase;

  setUp(() {
    mockRepository = MockContactHashRepository();
    hashContactsUseCase = HashContactsUseCase();
    useCase = SyncContactHashesUseCase(
      repository: mockRepository,
      hashContactsUseCase: hashContactsUseCase,
    );
  });

  group('SyncContactHashesUseCase', () {
    test('reads contacts, hashes, and uploads', () async {
      when(() => mockRepository.uploadHashes(any())).thenAnswer((_) async {});

      await useCase.execute(['01012345678', '01098765432']);

      final captured = verify(
        () => mockRepository.uploadHashes(captureAny()),
      ).captured;
      final hashes = captured.first as List<String>;
      expect(hashes, hasLength(2));
      expect(hashes.every((h) => h.length == 64), isTrue);
    });

    test('empty contact list uploads empty hash list', () async {
      when(() => mockRepository.uploadHashes(any())).thenAnswer((_) async {});

      await useCase.execute([]);

      verify(() => mockRepository.uploadHashes([])).called(1);
    });

    test('repository error propagates', () async {
      when(
        () => mockRepository.uploadHashes(any()),
      ).thenThrow(Exception('Upload failed'));

      expect(() => useCase.execute(['01012345678']), throwsA(isA<Exception>()));
    });
  });
}
