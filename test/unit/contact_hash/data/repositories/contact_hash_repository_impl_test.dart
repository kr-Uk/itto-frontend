import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:itto/features/contact_hash/data/datasources/contact_hash_remote_datasource.dart';
import 'package:itto/features/contact_hash/data/models/contact_hash_model.dart';
import 'package:itto/features/contact_hash/data/repositories/contact_hash_repository_impl.dart';

class MockContactHashRemoteDataSource extends Mock
    implements ContactHashRemoteDataSource {}

void main() {
  late MockContactHashRemoteDataSource mockRemoteDataSource;
  late ContactHashRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockContactHashRemoteDataSource();
    repository = ContactHashRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );
  });

  group('ContactHashRepositoryImpl', () {
    test('uploadHashes calls remote data source with hashes', () async {
      final hashes = ['a' * 64, 'b' * 64];
      when(
        () => mockRemoteDataSource.uploadHashes(hashes),
      ).thenAnswer((_) async => 2);

      await repository.uploadHashes(hashes);

      verify(() => mockRemoteDataSource.uploadHashes(hashes)).called(1);
    });

    test('getHashes returns entities from remote data source', () async {
      final models = [
        ContactHashModel(
          id: 1,
          phoneHash: 'a' * 64,
          createdAt: DateTime(2026, 3, 5),
        ),
      ];
      when(
        () => mockRemoteDataSource.getHashes(),
      ).thenAnswer((_) async => models);

      final result = await repository.getHashes();

      expect(result, hasLength(1));
      expect(result.first.id, equals(1));
      expect(result.first.phoneHash, equals('a' * 64));
    });

    test('addManualBlock calls remote data source', () async {
      when(
        () => mockRemoteDataSource.addManualBlock(any()),
      ).thenAnswer((_) async {});

      await repository.addManualBlock('010-1234-5678');

      verify(
        () => mockRemoteDataSource.addManualBlock('010-1234-5678'),
      ).called(1);
    });

    test('removeHash calls remote data source', () async {
      when(
        () => mockRemoteDataSource.removeHash(any()),
      ).thenAnswer((_) async {});

      await repository.removeHash(10);

      verify(() => mockRemoteDataSource.removeHash(10)).called(1);
    });

    test('API error propagates', () async {
      when(
        () => mockRemoteDataSource.uploadHashes(any()),
      ).thenThrow(Exception('API error'));

      expect(
        () => repository.uploadHashes(['a' * 64]),
        throwsA(isA<Exception>()),
      );
    });
  });
}
