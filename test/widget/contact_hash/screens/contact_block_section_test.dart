import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:itto/core/di/providers.dart';
import 'package:itto/domain/contact_hash/entities/contact_hash.dart';
import 'package:itto/domain/contact_hash/repositories/contact_hash_repository.dart';
import 'package:itto/domain/contact_hash/usecases/sync_contact_hashes_usecase.dart';
import 'package:itto/presentation/contact_hash/providers/contact_hash_provider.dart';
import 'package:itto/presentation/contact_hash/widgets/contact_block_section.dart';

class MockContactHashRepository extends Mock implements ContactHashRepository {}

class MockSyncContactHashesUseCase extends Mock
    implements SyncContactHashesUseCase {}

void main() {
  late MockContactHashRepository mockRepository;
  late MockSyncContactHashesUseCase mockSyncUseCase;

  setUp(() {
    mockRepository = MockContactHashRepository();
    mockSyncUseCase = MockSyncContactHashesUseCase();
  });

  Widget createWidget({ContactHashProvider? provider}) {
    final p =
        provider ??
        ContactHashProvider(
          repository: mockRepository,
          syncContactHashesUseCase: mockSyncUseCase,
        );
    return ProviderScope(
      overrides: [
        contactHashChangeNotifierProvider.overrideWith((_) => p),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ContactBlockSection()),
        ),
      ),
    );
  }

  group('ContactBlockSection', () {
    testWidgets('shows sync button when permission granted', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('연락처 동기화'), findsOneWidget);
    });

    testWidgets('shows permission message when denied', (tester) async {
      final provider = ContactHashProvider(
        repository: mockRepository,
        syncContactHashesUseCase: mockSyncUseCase,
      );
      await provider.syncContacts([], hasPermission: false);

      await tester.pumpWidget(createWidget(provider: provider));
      await tester.pump();

      expect(find.text('연락처 권한이 필요합니다'), findsOneWidget);
    });

    testWidgets('shows phone number input field', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('차단'), findsOneWidget);
    });

    testWidgets('tapping block button calls addManualBlock', (tester) async {
      when(() => mockRepository.addManualBlock(any())).thenAnswer((_) async {});
      when(() => mockRepository.getHashes()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidget());

      await tester.enterText(find.byType(TextField), '010-1234-5678');
      await tester.tap(find.text('차단'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.addManualBlock('010-1234-5678')).called(1);
    });

    testWidgets('shows hash list with remove button', (tester) async {
      when(() => mockRepository.getHashes()).thenAnswer(
        (_) async => [
          ContactHash(id: 1, phoneHash: 'a' * 64, createdAt: DateTime.now()),
        ],
      );

      final provider = ContactHashProvider(
        repository: mockRepository,
        syncContactHashesUseCase: mockSyncUseCase,
      );
      await provider.loadHashes();

      await tester.pumpWidget(createWidget(provider: provider));
      await tester.pump();

      expect(find.text('해제'), findsOneWidget);
    });

    testWidgets('tapping remove calls removeHash', (tester) async {
      when(() => mockRepository.removeHash(any())).thenAnswer((_) async {});
      when(() => mockRepository.getHashes()).thenAnswer(
        (_) async => [
          ContactHash(id: 1, phoneHash: 'a' * 64, createdAt: DateTime.now()),
        ],
      );

      final provider = ContactHashProvider(
        repository: mockRepository,
        syncContactHashesUseCase: mockSyncUseCase,
      );
      await provider.loadHashes();

      await tester.pumpWidget(createWidget(provider: provider));
      await tester.pump();

      await tester.tap(find.text('해제'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.removeHash(1)).called(1);
    });
  });
}
