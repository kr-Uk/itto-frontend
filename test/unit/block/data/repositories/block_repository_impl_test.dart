import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:itto/data/block/datasources/block_remote_datasource.dart';
import 'package:itto/data/block/models/block_item_model.dart';
import 'package:itto/data/block/repositories/block_repository_impl.dart';
import 'package:itto/domain/block/entities/report_request.dart';

class MockBlockRemoteDataSource extends Mock implements BlockRemoteDataSource {}

void main() {
  late MockBlockRemoteDataSource mockRemoteDataSource;
  late BlockRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockBlockRemoteDataSource();
    repository = BlockRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('BlockRepositoryImpl', () {
    group('listBlocks', () {
      test('returns list of BlockItem entities from remote data source',
          () async {
        final models = [
          const BlockItemModel(
            id: 1,
            blockedUser: BlockedUserModel(userId: 10, nickname: '유저1'),
            createdAt: '2026-03-17',
          ),
          const BlockItemModel(
            id: 2,
            blockedUser: BlockedUserModel(userId: 20, nickname: '유저2'),
            createdAt: '2026-03-16',
          ),
        ];
        when(() => mockRemoteDataSource.listBlocks())
            .thenAnswer((_) async => models);

        final result = await repository.listBlocks();

        expect(result, hasLength(2));
        expect(result[0].id, equals(1));
        expect(result[0].blockedUser.userId, equals(10));
        expect(result[1].id, equals(2));
        expect(result[1].blockedUser.nickname, equals('유저2'));
        verify(() => mockRemoteDataSource.listBlocks()).called(1);
      });

      test('returns empty list when no blocks', () async {
        when(() => mockRemoteDataSource.listBlocks())
            .thenAnswer((_) async => []);

        final result = await repository.listBlocks();

        expect(result, isEmpty);
      });

      test('propagates exception from remote data source', () async {
        when(() => mockRemoteDataSource.listBlocks())
            .thenThrow(Exception('Network error'));

        expect(
          () => repository.listBlocks(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('blockUser', () {
      test('delegates to remote data source', () async {
        when(() => mockRemoteDataSource.blockUser(any()))
            .thenAnswer((_) async {});

        await repository.blockUser(42);

        verify(() => mockRemoteDataSource.blockUser(42)).called(1);
      });
    });

    group('unblock', () {
      test('delegates to remote data source', () async {
        when(() => mockRemoteDataSource.unblock(any()))
            .thenAnswer((_) async {});

        await repository.unblock(1);

        verify(() => mockRemoteDataSource.unblock(1)).called(1);
      });
    });

    group('report', () {
      test('converts entity to model and calls remote data source', () async {
        when(() => mockRemoteDataSource.report(any()))
            .thenAnswer((_) async {});

        const request = ReportRequest(
          targetUserId: 42,
          category: 'SPAM',
          targetType: 'USER',
          chatRoomId: 'room-1',
          description: '스팸입니다',
        );

        await repository.report(request);

        final captured =
            verify(() => mockRemoteDataSource.report(captureAny())).captured;
        final json = captured.first as Map<String, dynamic>;
        expect(json['targetUserId'], equals(42));
        expect(json['category'], equals('SPAM'));
        expect(json['targetType'], equals('USER'));
        expect(json['chatRoomId'], equals('room-1'));
        expect(json['description'], equals('스팸입니다'));
      });

      test('report without optional fields omits them from json', () async {
        when(() => mockRemoteDataSource.report(any()))
            .thenAnswer((_) async {});

        const request = ReportRequest(
          targetUserId: 10,
          category: 'HARASSMENT',
          targetType: 'PROFILE',
        );

        await repository.report(request);

        final captured =
            verify(() => mockRemoteDataSource.report(captureAny())).captured;
        final json = captured.first as Map<String, dynamic>;
        expect(json.containsKey('chatRoomId'), isFalse);
        expect(json.containsKey('description'), isFalse);
      });
    });
  });
}
