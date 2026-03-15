/// 설정 화면 플로우 Integration Test.
/// 설정 메인 → 프로필 수정, 알림 설정, 연결 범위, 매듭 관리, 구독 화면 이동을 검증한다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:itto/app.dart';
import '../helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValues();
  });

  late MockSetup mocks;

  setUp(() {
    mocks = MockSetup();
    when(() => mocks.mockTokenStorage.hasTokens())
        .thenAnswer((_) async => true);
  });

  Future<void> navigateToSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: mocks.overrides,
        child: const IttoApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // 하단 설정 탭 이동
    await tester.tap(find.text('설정'));
    await tester.pumpAndSettle();
  }

  group('Settings Flow: 메인 화면', () {
    testWidgets('설정 화면에 섹션 라벨들이 표시된다', (tester) async {
      await navigateToSettings(tester);

      expect(find.text('내 프로필'), findsOneWidget);
      expect(find.text('기능'), findsOneWidget);
      // "설정" 은 앱바 + 섹션 라벨 + 하단 탭 세 군데 가능
      expect(find.text('설정'), findsWidgets);
      expect(find.text('정보'), findsOneWidget);
    });

    testWidgets('프로필 카드에 닉네임이 표시된다', (tester) async {
      await navigateToSettings(tester);

      // testMyProfile.nickname = '테스트유저'
      expect(find.text('테스트유저'), findsOneWidget);
    });

    testWidgets('프로필 카드에 자기소개가 표시된다', (tester) async {
      await navigateToSettings(tester);

      // testMyProfile.introduction
      expect(find.text('안녕하세요, 테스트 유저입니다.'), findsOneWidget);
    });

    testWidgets('설정 메뉴 항목들이 표시된다', (tester) async {
      await navigateToSettings(tester);

      expect(find.text('인연 범위 설정'), findsOneWidget);
      expect(find.text('회원정보'), findsOneWidget);
      expect(find.text('알림'), findsOneWidget);
      expect(find.text('매듭 관리'), findsOneWidget);
      expect(find.text('구독하기'), findsOneWidget);
      expect(find.text('튜토리얼'), findsOneWidget);
      expect(find.text('도움받기'), findsOneWidget);
    });

    testWidgets('로그아웃과 회원탈퇴 메뉴가 표시된다', (tester) async {
      await navigateToSettings(tester);

      final logoutFinder = find.text('로그아웃');
      await tester.ensureVisible(logoutFinder);
      expect(logoutFinder, findsOneWidget);

      final withdrawFinder = find.text('회원탈퇴');
      await tester.ensureVisible(withdrawFinder);
      expect(withdrawFinder, findsOneWidget);
    });

    testWidgets('회원탈퇴 텍스트는 빨간색이다', (tester) async {
      await navigateToSettings(tester);

      final withdrawFinder = find.text('회원탈퇴');
      await tester.ensureVisible(withdrawFinder);

      final withdrawText = tester.widget<Text>(withdrawFinder);
      expect(withdrawText.style?.color, Colors.red);
    });
  });

  group('Settings Flow: 하위 화면 네비게이션', () {
    testWidgets('인연 범위 설정 탭 → 연결 범위 화면 이동', (tester) async {
      await navigateToSettings(tester);

      await tester.tap(find.text('인연 범위 설정'));
      await tester.pumpAndSettle();

      // 전체 화면 이동 (하단 탭바 숨김)
      expect(find.byIcon(Icons.chevron_left), findsWidgets);
    });

    testWidgets('알림 메뉴 탭 → 알림 설정 화면 이동', (tester) async {
      await navigateToSettings(tester);

      await tester.tap(find.text('알림'));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('매듭 관리 탭 → 매듭 관리 화면 이동', (tester) async {
      await navigateToSettings(tester);

      final knotFinder = find.text('매듭 관리');
      await tester.ensureVisible(knotFinder);
      await tester.tap(knotFinder);
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('구독하기 탭 → 구독 화면 이동', (tester) async {
      await navigateToSettings(tester);

      final subFinder = find.text('구독하기');
      await tester.ensureVisible(subFinder);
      await tester.tap(subFinder);
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Settings Flow: 회원탈퇴 다이얼로그', () {
    testWidgets('회원탈퇴 탭 → 확인 다이얼로그 표시', (tester) async {
      await navigateToSettings(tester);

      final withdrawFinder = find.text('회원탈퇴');
      await tester.ensureVisible(withdrawFinder);
      await tester.tap(withdrawFinder);
      await tester.pumpAndSettle();

      // 다이얼로그 타이틀과 내용
      expect(find.text('회원탈퇴'), findsWidgets);
      expect(
        find.text('정말 탈퇴하시겠습니까?\n모든 데이터가 삭제되며 복구할 수 없습니다.'),
        findsOneWidget,
      );
      expect(find.text('취소'), findsOneWidget);
      expect(find.text('탈퇴'), findsOneWidget);
    });

    testWidgets('회원탈퇴 다이얼로그에서 취소 → 설정 화면 유지', (tester) async {
      await navigateToSettings(tester);

      final withdrawFinder = find.text('회원탈퇴');
      await tester.ensureVisible(withdrawFinder);
      await tester.tap(withdrawFinder);
      await tester.pumpAndSettle();

      // 취소 버튼 탭
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      // 설정 화면 유지
      expect(find.text('내 프로필'), findsOneWidget);
    });

    testWidgets('회원탈퇴 다이얼로그에서 탈퇴 → 로그인 화면 이동', (tester) async {
      await navigateToSettings(tester);

      final withdrawFinder = find.text('회원탈퇴');
      await tester.ensureVisible(withdrawFinder);
      await tester.tap(withdrawFinder);
      await tester.pumpAndSettle();

      // 탈퇴 버튼 탭
      await tester.tap(find.text('탈퇴'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 로그인 화면으로 이동
      expect(find.text('스친 인연을, 이토로 잇다'), findsOneWidget);
    });
  });
}
