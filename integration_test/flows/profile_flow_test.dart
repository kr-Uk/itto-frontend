/// 프로필 설정/수정 화면 Integration Test.
/// 설정 → 프로필 수정, 닉네임/자기소개 표시, 연결 범위 화면을 검증한다.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_app.dart';
import '../helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValues();
  });

  group('Profile Flow: 프로필 수정', () {
    testWidgets('설정 → 프로필 수정 화면 이동', (tester) async {
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

      // 설정 탭 이동
      await tester.tap(find.text('설정'));
      await tester.pumpAndSettle();

      // 설정 화면 확인
      expect(find.text('내 프로필'), findsOneWidget);

      // 회원정보 항목 탭 → 프로필 수정 화면 이동
      await tester.tap(find.text('회원정보'));
      await tester.pumpAndSettle();

      // 프로필 설정 AppBar 타이틀 확인
      expect(find.text('프로필 설정'), findsOneWidget);
    });

    testWidgets('프로필 수정 화면에 닉네임/자기소개 표시', (tester) async {
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

      // 설정 → 프로필 수정
      await tester.tap(find.text('설정'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('회원정보'));
      await tester.pumpAndSettle();

      // 닉네임 표시 확인 (testMyProfile.nickname = '테스트유저')
      expect(find.text('테스트유저'), findsOneWidget);

      // 자기소개 표시 확인 (testMyProfile.introduction)
      expect(find.text('안녕하세요, 테스트 유저입니다.'), findsOneWidget);

      // 섹션 헤더 확인
      expect(find.text('한줄소개'), findsOneWidget);
      expect(find.text('관심사 키워드'), findsOneWidget);
      expect(find.text('본인 인증'), findsOneWidget);

      // 키워드 표시 확인 (testMyProfile.hobbies = [운동, 독서])
      expect(find.text('운동'), findsOneWidget);
      expect(find.text('독서'), findsOneWidget);
    });

    testWidgets('설정 → 인연 범위 설정 화면 이동 및 표시', (tester) async {
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

      // 설정 탭 이동
      await tester.tap(find.text('설정'));
      await tester.pumpAndSettle();

      // 인연 범위 설정 항목 탭
      await tester.tap(find.text('인연 범위 설정'));
      await tester.pumpAndSettle();

      // 인연 범위 설정 화면 확인
      expect(find.text('인연 범위 설정'), findsOneWidget);
      expect(
        find.text('내가 만나고 싶은 인연의 범위를 설정할 수 있어요.'),
        findsOneWidget,
      );

      // 성별 섹션 확인
      expect(find.text('성별'), findsOneWidget);
      expect(find.text('여자'), findsOneWidget);
      expect(find.text('남자'), findsOneWidget);

      // 연령대 섹션 확인
      expect(find.text('연령대'), findsOneWidget);

      // 제외 지역 설정 확인
      expect(find.text('제외 지역 설정'), findsOneWidget);
      expect(find.text('제외할 지역을 설정하세요'), findsOneWidget);

      // 차단 섹션 확인
      expect(find.text('차단하기'), findsOneWidget);
      expect(find.text('차단된 사용자가 없습니다'), findsOneWidget);

      // 저장 버튼 확인
      expect(find.text('저장하기'), findsOneWidget);
    });
  });
}
