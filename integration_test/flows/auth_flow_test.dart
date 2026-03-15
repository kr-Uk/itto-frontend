/// 로그인/로그아웃 플로우 Integration Test.
/// 소셜 로그인(카카오/애플/구글), 로그아웃, 신규 사용자 분기를 검증한다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:itto/app.dart';
import 'package:itto/domain/auth/entities/login_result.dart';
import '../helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValues();
  });

  group('Auth Flow: 로그인', () {
    testWidgets('비로그인 상태에서 스플래시 → 로그인 화면으로 이동', (tester) async {
      final mocks = MockSetup();
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: mocks.overrides,
          child: const IttoApp(),
        ),
      );

      // 스플래시 화면 표시
      await tester.pump();
      expect(find.text('Itto'), findsOneWidget);

      // 로그인 화면으로 전환 대기
      await tester.pumpAndSettle(const Duration(seconds: 4));
      expect(find.text('스친 인연을, 이토로 잇다'), findsOneWidget);
    });

    testWidgets('로그인 화면에 3개 소셜 로그인 버튼 표시', (tester) async {
      final mocks = MockSetup();
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: mocks.overrides,
          child: const IttoApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 카카오 (TALK), 애플, 구글 (G) 버튼
      expect(find.text('TALK'), findsOneWidget);
      expect(find.byIcon(Icons.apple), findsOneWidget);
      expect(find.text('G'), findsOneWidget);
    });

    testWidgets('기존 사용자 카카오 로그인 → 홈 화면 이동', (tester) async {
      final mocks = MockSetup();
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: mocks.overrides,
          child: const IttoApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 카카오 로그인 버튼 탭
      await tester.tap(find.text('TALK'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 홈 화면의 "Itto" 로고와 탭 확인
      expect(find.text('Itto'), findsOneWidget);
      expect(find.text('인연'), findsOneWidget);
    });

    testWidgets('신규 사용자 로그인 → 회원가입 화면 이동', (tester) async {
      final mocks = MockSetup();
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => false);
      // 신규 사용자 응답
      when(() => mocks.mockAuthRepo.login(
            oauthToken: any(named: 'oauthToken'),
            provider: any(named: 'provider'),
            fcmToken: any(named: 'fcmToken'),
          )).thenAnswer((_) async => testNewUserLoginResult);

      await tester.pumpWidget(
        ProviderScope(
          overrides: mocks.overrides,
          child: const IttoApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 구글 로그인 버튼 탭
      await tester.tap(find.text('G'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 회원가입 화면 진입 확인 (뒤로가기 버튼 존재)
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });
  });

  group('Auth Flow: 로그인 상태 복원', () {
    testWidgets('토큰 있는 상태에서 스플래시 → 홈 화면 직행', (tester) async {
      final mocks = MockSetup();
      // 토큰 있음 + 프로필 완성
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: mocks.overrides,
          child: const IttoApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 홈 화면 도달 확인
      expect(find.text('Itto'), findsOneWidget);
      expect(find.text('인연'), findsOneWidget);
      expect(find.text('필연'), findsOneWidget);
    });
  });

  group('Auth Flow: 로그아웃', () {
    testWidgets('설정 → 로그아웃 → 로그인 화면 이동', (tester) async {
      final mocks = MockSetup();
      when(() => mocks.mockTokenStorage.hasTokens())
          .thenAnswer((_) async => true);

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

      // 로그아웃 항목 찾아서 탭
      final logoutFinder = find.text('로그아웃');
      await tester.ensureVisible(logoutFinder);
      await tester.tap(logoutFinder);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 로그인 화면으로 돌아감
      expect(find.text('스친 인연을, 이토로 잇다'), findsOneWidget);
    });
  });
}
