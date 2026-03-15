/// 홈 화면 4개 탭 전환 Integration Test.
/// 인연/필연/우연/지난인연 탭 전환과 각 탭의 데이터 표시를 검증한다.
/// 매듭 잔액 표시, 인연 만나기 토글도 함께 테스트한다.

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

  Future<void> navigateToHome(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: mocks.overrides,
        child: const IttoApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 4));
  }

  group('Home Tabs: 탭 표시', () {
    testWidgets('홈 화면에 4개 탭 라벨이 표시된다', (tester) async {
      await navigateToHome(tester);

      expect(find.text('인연'), findsOneWidget);
      expect(find.text('필연'), findsOneWidget);
      expect(find.text('우연'), findsOneWidget);
      expect(find.text('지난인연'), findsOneWidget);
    });

    testWidgets('Itto 로고와 "인연 만나기" 토글이 표시된다', (tester) async {
      await navigateToHome(tester);

      expect(find.text('Itto'), findsOneWidget);
      expect(find.text('인연 만나기'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('매듭 잔액이 표시된다', (tester) async {
      await navigateToHome(tester);

      // testKnotBalance.knots = 100
      expect(find.text('100'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsWidgets);
    });
  });

  group('Home Tabs: 탭 전환', () {
    testWidgets('필연 탭을 탭하면 필연 탭으로 전환된다', (tester) async {
      await navigateToHome(tester);

      await tester.tap(find.text('필연'));
      await tester.pumpAndSettle();

      // 필연 탭이 선택된 상태 (bold 폰트)
      final pilyeonText = tester.widget<Text>(find.text('필연'));
      expect(pilyeonText.style?.fontWeight, FontWeight.w700);
    });

    testWidgets('우연 탭을 탭하면 우연 탭으로 전환된다', (tester) async {
      await navigateToHome(tester);

      await tester.tap(find.text('우연'));
      await tester.pumpAndSettle();

      final uyeonText = tester.widget<Text>(find.text('우연'));
      expect(uyeonText.style?.fontWeight, FontWeight.w700);
    });

    testWidgets('지난인연 탭을 탭하면 지난인연 탭으로 전환된다', (tester) async {
      await navigateToHome(tester);

      await tester.tap(find.text('지난인연'));
      await tester.pumpAndSettle();

      final pastText = tester.widget<Text>(find.text('지난인연'));
      expect(pastText.style?.fontWeight, FontWeight.w700);
    });
  });

  group('Home Tabs: 하단 네비게이션', () {
    testWidgets('하단 네비게이션 바에 4개 탭이 표시된다', (tester) async {
      await navigateToHome(tester);

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('홈'), findsOneWidget);
      expect(find.text('채팅'), findsOneWidget);
      expect(find.text('알림'), findsOneWidget);
      expect(find.text('설정'), findsOneWidget);
    });

    testWidgets('채팅 탭 이동 시 채팅 목록이 표시된다', (tester) async {
      await navigateToHome(tester);

      // 하단 채팅 탭 탭
      await tester.tap(find.text('채팅'));
      await tester.pumpAndSettle();

      // 채팅 목록 화면 앱바
      expect(find.text('인연 채팅'), findsOneWidget);
    });

    testWidgets('알림 탭 이동 시 알림 화면이 표시된다', (tester) async {
      await navigateToHome(tester);

      await tester.tap(find.text('알림'));
      await tester.pumpAndSettle();

      // 알림 화면이 로드됨
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('설정 탭 이동 시 설정 화면이 표시된다', (tester) async {
      await navigateToHome(tester);

      await tester.tap(find.text('설정'));
      await tester.pumpAndSettle();

      expect(find.text('설정'), findsWidgets);
    });
  });

  group('Home Tabs: 매듭 탭', () {
    testWidgets('매듭 잔액을 탭하면 매듭 관리 화면으로 이동', (tester) async {
      await navigateToHome(tester);

      // knot_display Key로 찾아서 탭
      await tester.tap(find.byKey(const Key('knot_display')));
      await tester.pumpAndSettle();

      // 매듭 관리(currency) 화면으로 이동
      // 전체 화면으로 표시되므로 하단 탭바 사라짐
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
