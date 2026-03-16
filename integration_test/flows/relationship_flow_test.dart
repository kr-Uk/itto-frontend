/// 인연/필연/우연/지난인연 탭 Integration Test.
/// 각 탭의 데이터 표시 및 빈 상태를 검증한다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:itto/domain/common/entities/page_response.dart';
import 'package:itto/domain/relationship/entities/relationship.dart';
import '../helpers/test_app.dart';
import '../helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValues();
  });

  group('Relationship Flow: 인연 탭', () {
    testWidgets('인연 탭에 인연 상대 표시', (tester) async {
      final mocks = MockSetup();
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: mocks.overrides,
          child: const TestIttoApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 홈 화면 도달 — 기본 인연 탭
      expect(find.text('인연'), findsOneWidget);

      // 인연 상대 닉네임 표시 확인 (testRelationships['INYEON'] = [인연상대])
      expect(find.text('인연상대'), findsOneWidget);

      // 인연 카운트 표시 확인
      expect(find.text('나의 인연 1'), findsOneWidget);

      // 운명 배지 표시 확인 (destinyBadge: true)
      expect(find.text('운명'), findsOneWidget);

      // 채팅하기 버튼 확인
      expect(find.text('채팅하기'), findsOneWidget);
    });

    testWidgets('인연 탭 빈 상태', (tester) async {
      final mocks = MockSetup();
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => true);

      // 인연 데이터를 빈 목록으로 오버라이드
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

      // 빈 상태 메시지 확인
      expect(find.text('아직 인연이 없어요.'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });
  });

  group('Relationship Flow: 필연 탭', () {
    testWidgets('필연 탭에 필연 상대 표시', (tester) async {
      final mocks = MockSetup();
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: mocks.overrides,
          child: const TestIttoApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 필연 탭 이동
      await tester.tap(find.text('필연'));
      await tester.pumpAndSettle();

      // 필연 상대 닉네임 표시 확인
      expect(find.text('필연상대'), findsOneWidget);

      // 필연 카운트 확인 (PILYEON 1 + PENDING 0 = 1)
      expect(find.text('필연 1'), findsOneWidget);

      // 인연 요청 버튼 확인
      expect(find.text('인연 요청'), findsOneWidget);

      // 프로필 보기 버튼 확인
      expect(find.text('프로필 보기'), findsOneWidget);
    });

    testWidgets('필연 탭 빈 상태', (tester) async {
      final mocks = MockSetup();
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => true);

      // 필연, PENDING 모두 빈 목록으로 오버라이드
      for (final status in ['PILYEON', 'PENDING']) {
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

      // 필연 탭 이동
      await tester.tap(find.text('필연'));
      await tester.pumpAndSettle();

      // 빈 상태 메시지 확인
      expect(find.text('아직 필연이 없어요.'), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });
  });

  group('Relationship Flow: 우연 탭', () {
    testWidgets('우연 탭에 우연 상대 표시', (tester) async {
      final mocks = MockSetup();
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: mocks.overrides,
          child: const TestIttoApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 우연 탭 이동
      await tester.tap(find.text('우연'));
      await tester.pumpAndSettle();

      // 우연 상대 닉네임 표시 확인
      expect(find.text('우연상대'), findsOneWidget);

      // 우연 카운트 확인
      expect(find.text('오늘 마주친 우연 1'), findsOneWidget);
    });

    testWidgets('우연 탭 빈 상태', (tester) async {
      final mocks = MockSetup();
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => true);

      // 우연 데이터를 빈 목록으로 오버라이드
      when(() => mocks.mockRelationshipRepo.getList(
            status: 'UYEON',
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

      // 우연 탭 이동
      await tester.tap(find.text('우연'));
      await tester.pumpAndSettle();

      // 빈 상태 메시지 확인
      expect(find.text('아직 우연이 없어요.'), findsOneWidget);
      expect(find.byIcon(Icons.explore_outlined), findsOneWidget);
    });
  });

  group('Relationship Flow: 지난인연 탭', () {
    testWidgets('지난인연 탭에 지난 인연 상대 표시', (tester) async {
      final mocks = MockSetup();
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: mocks.overrides,
          child: const TestIttoApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 지난인연 탭 이동
      await tester.tap(find.text('지난인연'));
      await tester.pumpAndSettle();

      // 지난 인연 상대 닉네임 표시 확인
      expect(find.text('지난인연'), findsWidgets); // 탭 라벨 + 배지 라벨 + 닉네임
      expect(find.text('지난 인연 1'), findsOneWidget);

      // 다시 만나기 버튼 확인
      expect(find.text('다시 만나기'), findsOneWidget);
    });

    testWidgets('지난인연 탭 빈 상태', (tester) async {
      final mocks = MockSetup();
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => true);

      // 지난인연 데이터를 빈 목록으로 오버라이드
      when(() => mocks.mockRelationshipRepo.getList(
            status: 'PAST',
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

      // 지난인연 탭 이동
      await tester.tap(find.text('지난인연'));
      await tester.pumpAndSettle();

      // 빈 상태 메시지 확인
      expect(find.text('아직 지난 인연이 없어요.'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });
  });
}
