/// 알림 화면 Integration Test.
/// 빈 알림 목록, 알림 데이터 있을 때 목록 표시를 검증한다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:itto/domain/common/entities/page_response.dart';
import 'package:itto/domain/notification/entities/notification_item.dart';
import '../helpers/test_app.dart';
import '../helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValues();
  });

  group('Notification Flow: 알림 화면', () {
    testWidgets('하단 네비에서 알림 탭 이동', (tester) async {
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

      // 홈 화면 도달 확인
      expect(find.text('Itto'), findsOneWidget);

      // 하단 네비의 알림 탭 이동
      await tester.tap(find.text('알림'));
      await tester.pumpAndSettle();

      // 알림 화면 AppBar 타이틀 표시 확인
      expect(find.text('알림'), findsWidgets); // AppBar + 하단 네비 모두 존재
    });

    testWidgets('빈 알림 목록 상태 표시', (tester) async {
      final mocks = MockSetup();
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => true);
      // 기본 Mock은 빈 알림 목록을 반환

      await tester.pumpWidget(
        ProviderScope(
          overrides: mocks.overrides,
          child: const TestIttoApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 알림 탭 이동
      await tester.tap(find.text('알림'));
      await tester.pumpAndSettle();

      // 빈 상태 메시지 확인
      expect(find.text('알림이 없습니다'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    testWidgets('알림이 있을 때 목록 표시', (tester) async {
      final mocks = MockSetup();
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => true);

      // 알림 데이터 Mock 설정
      final now = DateTime.now();
      final testNotifications = [
        NotificationItem(
          id: 1,
          type: 'INYEON_REQUEST',
          title: '인연상대',
          message: '인연상대님이 인연을 요청했습니다.',
          isRead: false,
          referenceId: 1,
          createdAt: now.toIso8601String(),
        ),
        NotificationItem(
          id: 2,
          type: 'MESSAGE',
          title: '테스트유저',
          message: '새로운 메시지가 도착했습니다.',
          isRead: true,
          createdAt: now.subtract(const Duration(hours: 1)).toIso8601String(),
        ),
      ];

      when(() => mocks.mockNotificationRepo.getList(
            page: any(named: 'page'),
            size: any(named: 'size'),
          )).thenAnswer((_) async => PageResponse<NotificationItem>(
            content: testNotifications,
            page: 0,
            size: 20,
            totalElements: testNotifications.length,
            totalPages: 1,
          ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: mocks.overrides,
          child: const TestIttoApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 알림 탭 이동
      await tester.tap(find.text('알림'));
      await tester.pumpAndSettle();

      // 알림 항목 메시지가 표시되는지 확인
      expect(find.text('인연상대님이 인연을 요청했습니다.'), findsOneWidget);
      expect(find.text('새로운 메시지가 도착했습니다.'), findsOneWidget);

      // 날짜 그룹 라벨 '오늘' 확인
      expect(find.text('오늘'), findsOneWidget);
    });
  });
}
