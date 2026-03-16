// E2E 통합 테스트 — 앱 전체 흐름 검증 (디바이스/에뮬레이터).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/test_app.dart';
import 'helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockSetup mocks;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mocks = MockSetup();
    // 비로그인 상태
    when(() => mocks.mockTokenStorage.hasTokens()).thenAnswer((_) async => false);
  });

  group('E2E: 앱 기본 흐름', () {
    testWidgets('앱이 크래시 없이 시작된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: mocks.overrides,
          child: const TestIttoApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('스플래시 화면이 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: mocks.overrides,
          child: const TestIttoApp(),
        ),
      );
      await tester.pump();

      expect(find.text('Itto'), findsOneWidget);
    });

    testWidgets('비로그인 상태에서 로그인 화면으로 이동한다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: mocks.overrides,
          child: const TestIttoApp(),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 4));

      expect(find.text('스친 인연을, 이토로 잇다'), findsOneWidget);
    });

    testWidgets('로그인 화면에 소셜 로그인 버튼들이 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: mocks.overrides,
          child: const TestIttoApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));

      expect(find.text('TALK'), findsOneWidget);
      expect(find.byIcon(Icons.apple), findsOneWidget);
      expect(find.text('G'), findsOneWidget);
    });
  });
}
