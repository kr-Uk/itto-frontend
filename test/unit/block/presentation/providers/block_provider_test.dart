import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:itto/core/network/api_exception.dart';
import 'package:itto/domain/block/entities/block_item.dart';
import 'package:itto/domain/block/entities/report_request.dart';
import 'package:itto/domain/block/repositories/block_repository.dart';
import 'package:itto/presentation/block/providers/block_provider.dart';

class MockBlockRepository extends Mock implements BlockRepository {}

class FakeReportRequest extends Fake implements ReportRequest {}

void main() {
  late MockBlockRepository mockRepository;
  late BlockProvider provider;

  setUpAll(() {
    registerFallbackValue(FakeReportRequest());
  });

  setUp(() {
    mockRepository = MockBlockRepository();
    provider = BlockProvider(repository: mockRepository);
  });

  group('BlockProvider', () {
    test('initial state', () {
      expect(provider.blocks, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    group('loadBlocks', () {
      test('success loads blocks and clears error', () async {
        final blocks = [
          const BlockItem(
            id: 1,
            blockedUser: BlockedUser(userId: 10, nickname: '유저1'),
            createdAt: '2026-03-17',
          ),
        ];
        when(() => mockRepository.listBlocks())
            .thenAnswer((_) async => blocks);

        await provider.loadBlocks();

        expect(provider.blocks, hasLength(1));
        expect(provider.blocks.first.id, equals(1));
        expect(provider.isLoading, isFalse);
        expect(provider.error, isNull);
      });

      test('ApiException sets error message', () async {
        when(() => mockRepository.listBlocks()).thenThrow(
          const ApiException(
            statusCode: 500,
            message: '서버 오류',
            code: 'INTERNAL_ERROR',
          ),
        );

        await provider.loadBlocks();

        expect(provider.error, isNotNull);
        expect(provider.isLoading, isFalse);
        expect(provider.blocks, isEmpty);
      });
    });

    group('blockUser', () {
      test('success returns true and reloads blocks', () async {
        when(() => mockRepository.blockUser(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.listBlocks()).thenAnswer(
          (_) async => [
            const BlockItem(
              id: 1,
              blockedUser: BlockedUser(userId: 42, nickname: '차단됨'),
              createdAt: '2026-03-17',
            ),
          ],
        );

        final result = await provider.blockUser(42);

        expect(result, isTrue);
        verify(() => mockRepository.blockUser(42)).called(1);
        verify(() => mockRepository.listBlocks()).called(1);
      });

      test('ApiException returns false and sets error', () async {
        when(() => mockRepository.blockUser(any())).thenThrow(
          const ApiException(
            statusCode: 409,
            message: '이미 차단됨',
            code: 'ALREADY_BLOCKED',
          ),
        );

        final result = await provider.blockUser(42);

        expect(result, isFalse);
        expect(provider.error, equals('이미 차단한 사용자입니다.'));
      });
    });

    group('unblock', () {
      test('success returns true and removes block from list', () async {
        // Pre-populate blocks
        when(() => mockRepository.listBlocks()).thenAnswer(
          (_) async => [
            const BlockItem(
              id: 1,
              blockedUser: BlockedUser(userId: 10, nickname: '유저1'),
              createdAt: '2026-03-17',
            ),
            const BlockItem(
              id: 2,
              blockedUser: BlockedUser(userId: 20, nickname: '유저2'),
              createdAt: '2026-03-16',
            ),
          ],
        );
        await provider.loadBlocks();
        expect(provider.blocks, hasLength(2));

        when(() => mockRepository.unblock(any()))
            .thenAnswer((_) async {});

        final result = await provider.unblock(1);

        expect(result, isTrue);
        expect(provider.blocks, hasLength(1));
        expect(provider.blocks.first.id, equals(2));
      });

      test('ApiException returns false and sets error', () async {
        when(() => mockRepository.unblock(any())).thenThrow(
          const ApiException(
            statusCode: 404,
            message: '차단 정보 없음',
            code: 'BLOCK_NOT_FOUND',
          ),
        );

        final result = await provider.unblock(999);

        expect(result, isFalse);
        expect(provider.error, equals('차단 정보를 찾을 수 없습니다.'));
      });
    });

    group('report', () {
      test('success returns true', () async {
        when(() => mockRepository.report(any()))
            .thenAnswer((_) async {});

        const request = ReportRequest(
          targetUserId: 42,
          category: 'SPAM',
          targetType: 'USER',
        );

        final result = await provider.report(request);

        expect(result, isTrue);
        verify(() => mockRepository.report(request)).called(1);
      });

      test('ApiException returns false and sets error', () async {
        when(() => mockRepository.report(any())).thenThrow(
          const ApiException(
            statusCode: 500,
            message: '신고 실패',
          ),
        );

        const request = ReportRequest(
          targetUserId: 42,
          category: 'SPAM',
          targetType: 'USER',
        );

        final result = await provider.report(request);

        expect(result, isFalse);
        expect(provider.error, equals('신고 실패'));
      });
    });

    group('clearError', () {
      test('clears error state', () async {
        when(() => mockRepository.listBlocks()).thenThrow(
          const ApiException(statusCode: 500, message: '에러'),
        );
        await provider.loadBlocks();
        expect(provider.error, isNotNull);

        provider.clearError();

        expect(provider.error, isNull);
      });
    });
  });
}
