/// 에러/빈 상태 Integration Test.
/// 프로필 로드 실패, 빈 채팅 목록, 빈 관계 목록 상태를 검증한다.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

import 'package:itto/core/network/api_exception.dart';
import 'package:itto/domain/chat/entities/chat_room.dart';
import 'package:itto/domain/common/entities/page_response.dart';
import 'package:itto/domain/relationship/entities/relationship.dart';
import '../helpers/test_app.dart';
import '../helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValues();
    initializeDateFormatting('ko_KR', null);
  });

  group('Error States: 프로필 로드 실패', () {
    testWidgets('프로필 로드 실패 시 앱이 크래시 없이 동작한다', (tester) async {
      final mocks = MockSetup();
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => true);

      // 프로필 로드 실패 설정
      when(() => mocks.mockProfileRepo.getMyProfile())
          .thenThrow(const ApiException(
        statusCode: 500,
        message: '서버 오류가 발생했습니다.',
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: mocks.overrides,
          child: const TestIttoApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 6));

      // 프로필 로드 실패해도 앱이 크래시 없이 어떤 화면이든 표시됨
      expect(tester.takeException(), isNull);
    });
  });

  group('Error States: 빈 채팅 목록', () {
    testWidgets('채팅 목록이 비어있을 때 빈 상태 표시', (tester) async {
      final mocks = MockSetup();
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => true);

      // 채팅방 스트림을 빈 목록으로 오버라이드
      when(() => mocks.mockChatRepo.getChatRoomsStream(any(), any()))
          .thenAnswer((_) => Stream.value(<ChatRoom>[]));

      // 인연 데이터도 빈 목록으로 (채팅방 ID 매핑용)
      when(() => mocks.mockRelationshipRepo.getList(
            status: 'INYEON',
            page: any(named: 'page'),
          )).thenAnswer((_) async => const PageResponse<Relationship>(
            content: [],
            page: 0,
            size: 20,
            totalElements: 0,
            totalPages: 0,
          ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: mocks.overrides,
          child: const TestIttoApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 채팅 탭 이동
      await tester.tap(find.text('채팅'));
      await tester.pumpAndSettle();

      // 빈 채팅 상태 메시지 확인
      expect(find.text('아직 채팅이 없습니다'), findsOneWidget);
    });
  });

  group('Error States: 빈 관계 목록', () {
    testWidgets('모든 관계 탭이 비어있을 때 빈 상태 표시', (tester) async {
      final mocks = MockSetup();
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => true);

      // 모든 관계 데이터를 빈 목록으로 오버라이드
      for (final status in ['INYEON', 'PILYEON', 'UYEON', 'PAST', 'PENDING']) {
        when(() => mocks.mockRelationshipRepo.getList(
              status: status,
              page: any(named: 'page'),
            )).thenAnswer((_) async => const PageResponse<Relationship>(
              content: [],
              page: 0,
              size: 20,
              totalElements: 0,
              totalPages: 0,
            ));
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: mocks.overrides,
          child: const TestIttoApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 인연 탭 빈 상태
      expect(find.text('아직 인연이 없어요.'), findsOneWidget);

      // 필연 탭 이동
      await tester.tap(find.text('필연'));
      await tester.pumpAndSettle();
      expect(find.text('아직 필연이 없어요.'), findsOneWidget);

      // 우연 탭 이동
      await tester.tap(find.text('우연'));
      await tester.pumpAndSettle();
      expect(find.text('아직 우연이 없어요.'), findsOneWidget);

      // 지난인연 탭 이동
      await tester.tap(find.text('지난인연'));
      await tester.pumpAndSettle();
      expect(find.text('아직 지난 인연이 없어요.'), findsOneWidget);
    });
  });
}
