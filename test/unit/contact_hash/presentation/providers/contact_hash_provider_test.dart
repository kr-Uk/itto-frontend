import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:itto/domain/contact_hash/entities/contact_hash.dart';
import 'package:itto/domain/contact_hash/repositories/contact_hash_repository.dart';
import 'package:itto/domain/contact_hash/usecases/sync_contact_hashes_usecase.dart';
import 'package:itto/presentation/contact_hash/providers/contact_hash_provider.dart';

class MockContactHashRepository extends Mock implements ContactHashRepository {}

class MockSyncContactHashesUseCase extends Mock
    implements SyncContactHashesUseCase {}

void main() {
  late MockContactHashRepository mockRepository;
  late MockSyncContactHashesUseCase mockSyncUseCase;
  late ContactHashProvider provider;

  setUp(() {
    mockRepository = MockContactHashRepository();
    mockSyncUseCase = MockSyncContactHashesUseCase();
    provider = ContactHashProvider(
      repository: mockRepository,
      syncContactHashesUseCase: mockSyncUseCase,
    );
  });

  group('ContactHashProvider', () {
    test('initial state', () {
      expect(provider.hashes, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.contactPermissionDenied, isFalse);
      expect(provider.isSynced, isFalse);
    });

    group('syncContacts', () {
      test('permission denied sets contactPermissionDenied', () async {
        await provider.syncContacts([], hasPermission: false);

        expect(provider.contactPermissionDenied, isTrue);
      });

      test('success sets isSynced and loads hashes', () async {
        when(() => mockSyncUseCase.execute(any())).thenAnswer((_) async {});
        when(() => mockRepository.getHashes()).thenAnswer(
          (_) async => [
            ContactHash(id: 1, phoneHash: 'a' * 64, createdAt: DateTime.now()),
          ],
        );

        await provider.syncContacts(['01012345678']);

        expect(provider.isSynced, isTrue);
        expect(provider.hashes, hasLength(1));
        expect(provider.isLoading, isFalse);
      });

      test('error sets error state', () async {
        when(
          () => mockSyncUseCase.execute(any()),
        ).thenThrow(Exception('Sync failed'));

        await provider.syncContacts(['01012345678']);

        expect(provider.error, isNotNull);
        expect(provider.isLoading, isFalse);
      });
    });

    group('addManualBlock', () {
      test('success refreshes hash list', () async {
        when(
          () => mockRepository.addManualBlock(any()),
        ).thenAnswer((_) async {});
        when(() => mockRepository.getHashes()).thenAnswer(
          (_) async => [
            ContactHash(id: 1, phoneHash: 'a' * 64, createdAt: DateTime.now()),
          ],
        );

        await provider.addManualBlock('010-1234-5678');

        verify(() => mockRepository.addManualBlock('010-1234-5678')).called(1);
        expect(provider.hashes, hasLength(1));
        expect(provider.isLoading, isFalse);
      });
    });

    group('removeHash', () {
      test('success removes from list', () async {
        when(() => mockRepository.removeHash(any())).thenAnswer((_) async {});
        when(() => mockRepository.getHashes()).thenAnswer(
          (_) async => [
            ContactHash(id: 1, phoneHash: 'a' * 64, createdAt: DateTime.now()),
            ContactHash(id: 2, phoneHash: 'b' * 64, createdAt: DateTime.now()),
          ],
        );

        // First load hashes
        await provider.loadHashes();
        expect(provider.hashes, hasLength(2));

        // Then remove one
        await provider.removeHash(1);

        verify(() => mockRepository.removeHash(1)).called(1);
        expect(provider.hashes, hasLength(1));
        expect(provider.hashes.first.id, equals(2));
        expect(provider.isLoading, isFalse);
      });
    });

    group('error handling', () {
      test('addManualBlock error sets error state', () async {
        when(
          () => mockRepository.addManualBlock(any()),
        ).thenThrow(Exception('Block failed'));

        await provider.addManualBlock('010-1234-5678');

        expect(provider.error, isNotNull);
        expect(provider.isLoading, isFalse);
      });

      test('removeHash error sets error state', () async {
        when(
          () => mockRepository.removeHash(any()),
        ).thenThrow(Exception('Remove failed'));

        await provider.removeHash(1);

        expect(provider.error, isNotNull);
        expect(provider.isLoading, isFalse);
      });
    });
  });
}
