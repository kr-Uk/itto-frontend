/// ==========================================================================
/// [E2E 통합 테스트]
///
/// 앱의 전체 흐름을 실제 디바이스/에뮬레이터에서 테스트합니다.
/// 실행 방법:
///   flutter test integration_test/e2e_test.dart
///
/// 주의: Firebase/카카오 로그인은 실제 OAuth 토큰이 필요하므로
///       자동화 테스트에서는 UI 렌더링 + 네비게이션만 검증합니다.
/// ==========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:itto/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E: 앱 기본 흐름', () {
    testWidgets('앱이 크래시 없이 시작된다', (tester) async {
      await tester.pumpWidget(const IttoApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // 앱이 정상적으로 렌더링됨
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('스플래시 화면이 표시된다', (tester) async {
      await tester.pumpWidget(const IttoApp());
      await tester.pump();

      // "Itto" 로고 텍스트 확인
      expect(find.text('Itto'), findsOneWidget);
    });

    testWidgets('비로그인 상태에서 로그인 화면으로 이동한다', (tester) async {
      await tester.pumpWidget(const IttoApp());

      // 스플래시 → 로그인 전환 대기 (2초 딜레이 + 애니메이션)
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 로그인 화면의 "스친 인연을, 이토로 잇다" 슬로건 확인
      expect(find.text('스친 인연을, 이토로 잇다'), findsOneWidget);
    });

    testWidgets('로그인 화면에 소셜 로그인 버튼들이 표시된다', (tester) async {
      await tester.pumpWidget(const IttoApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 카카오 로그인 버튼 (TALK 텍스트)
      expect(find.text('TALK'), findsOneWidget);

      // Apple 로그인 버튼 (apple 아이콘)
      expect(find.byIcon(Icons.apple), findsOneWidget);

      // Google 로그인 버튼 (G 텍스트)
      expect(find.text('G'), findsOneWidget);
    });
  });
}
