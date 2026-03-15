/// 채팅 플로우 Integration Test.
/// 채팅 목록 → 채팅방 진입 → 메시지 표시 → 메시지 입력 영역을 검증한다.

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

  Future<void> navigateToChat(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: mocks.overrides,
        child: const IttoApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // 하단 채팅 탭 이동
    await tester.tap(find.text('채팅'));
    await tester.pumpAndSettle();
  }

  group('Chat Flow: 채팅 목록', () {
    testWidgets('채팅 목록 화면에 앱바 "인연 채팅" 표시', (tester) async {
      await navigateToChat(tester);

      expect(find.text('인연 채팅'), findsOneWidget);
    });

    testWidgets('채팅방이 있으면 상대방 닉네임과 마지막 메시지 표시', (tester) async {
      await navigateToChat(tester);

      // testChatRooms에서 상대방 = '인연상대', 마지막 메시지 = '안녕하세요!'
      expect(find.text('인연상대'), findsOneWidget);
      expect(find.text('안녕하세요!'), findsOneWidget);
    });

    testWidgets('읽지 않은 메시지 수 배지가 표시된다', (tester) async {
      await navigateToChat(tester);

      // testChatRooms[0].unreadCount = 2
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('채팅방이 없으면 빈 상태 메시지 표시', (tester) async {
      // 빈 채팅방 목록
      when(() => mocks.mockChatRepo.getChatRoomsStream(any(), any()))
          .thenAnswer((_) => Stream.value([]));

      await navigateToChat(tester);

      expect(find.text('아직 채팅이 없습니다'), findsOneWidget);
    });
  });

  group('Chat Flow: 채팅방', () {
    testWidgets('채팅방 진입 시 상대방 이름이 앱바에 표시', (tester) async {
      await navigateToChat(tester);

      // 채팅 목록에서 첫 번째 항목 탭
      await tester.tap(find.text('인연상대'));
      await tester.pumpAndSettle();

      // 채팅방 앱바에 상대방 이름
      // ChatRoomScreen에서 userName을 query param으로 전달
      expect(find.text('인연상대'), findsWidgets);
    });

    testWidgets('채팅방에 메시지 입력 필드와 전송 버튼 표시', (tester) async {
      await navigateToChat(tester);

      await tester.tap(find.text('인연상대'));
      await tester.pumpAndSettle();

      // 메시지 입력 힌트 텍스트
      expect(find.text('메시지를 입력하세요'), findsOneWidget);

      // 전송 버튼 (arrow_upward 아이콘)
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('채팅방에 "+" 버튼(첨부)이 표시된다', (tester) async {
      await navigateToChat(tester);

      await tester.tap(find.text('인연상대'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('채팅방 앱바에 위치 아이콘과 메뉴가 표시된다', (tester) async {
      await navigateToChat(tester);

      await tester.tap(find.text('인연상대'));
      await tester.pumpAndSettle();

      // 위치 버튼, 더보기 메뉴
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('채팅방 뒤로가기 → 채팅 목록 복귀', (tester) async {
      await navigateToChat(tester);

      await tester.tap(find.text('인연상대'));
      await tester.pumpAndSettle();

      // 뒤로가기
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // 채팅 목록으로 돌아옴
      expect(find.text('인연 채팅'), findsOneWidget);
    });

    testWidgets('메시지가 없으면 빈 상태 안내 표시', (tester) async {
      when(() => mocks.mockChatRepo.getMessagesStream(any()))
          .thenAnswer((_) => Stream.value([]));

      await navigateToChat(tester);

      await tester.tap(find.text('인연상대'));
      await tester.pumpAndSettle();

      expect(find.text('메시지가 없습니다\n첫 메시지를 보내보세요!'), findsOneWidget);
    });
  });
}
