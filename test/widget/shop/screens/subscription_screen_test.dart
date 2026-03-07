import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:itto/core/di/providers.dart';
import 'package:itto/presentation/shop/providers/shop_provider.dart';
import 'package:itto/domain/shop/entities/knot_balance.dart';
import 'package:itto/domain/shop/entities/subscription.dart';
import 'package:itto/domain/shop/repositories/shop_repository.dart';
import 'package:itto/presentation/settings/screens/subscription_screen.dart';

class MockShopRepository extends Mock implements ShopRepository {}

void main() {
  late MockShopRepository mockRepository;

  final notSubscribed = const SubscriptionInfo(
    isPremium: false,
    isPromotion: true,
  );

  final subscribed = const SubscriptionInfo(
    isPremium: true,
    plan: 'ITTO 프리미엄',
    price: 6900,
    expiresAt: '2026-04-05',
    isPromotion: true,
    benefits: SubscriptionBenefits(
      convertPerMonth: 6,
      unlimitedRequests: true,
      freeRestorePerMonth: 3,
      adFree: true,
    ),
  );

  setUp(() {
    mockRepository = MockShopRepository();
    when(
      () => mockRepository.getSubscription(),
    ).thenAnswer((_) async => notSubscribed);
    when(() => mockRepository.getKnots()).thenAnswer(
      (_) async => const KnotBalance(
        knots: 0,
        freeConvertRemaining: 0,
        freeRequestRemaining: 0,
        freeRestoreRemaining: 0,
      ),
    );
    when(() => mockRepository.getPackages()).thenAnswer((_) async => []);
    when(
      () => mockRepository.subscribe(
        receiptToken: any(named: 'receiptToken'),
        store: any(named: 'store'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockRepository.cancelSubscription()).thenAnswer((_) async {});
  });

  Widget buildWidget({SubscriptionInfo? initialSub}) {
    final provider = ShopProvider(repository: mockRepository);
    if (initialSub != null) {
      when(
        () => mockRepository.getSubscription(),
      ).thenAnswer((_) async => initialSub);
    }
    return ProviderScope(
      overrides: [
        shopChangeNotifierProvider.overrideWith((_) => provider),
      ],
      child: const MaterialApp(
        home: SubscriptionScreen(),
      ),
    );
  }

  group('SubscriptionScreen - Not subscribed state', () {
    testWidgets('shows premium header', (tester) async {
      await tester.pumpWidget(buildWidget(initialSub: notSubscribed));
      await tester.pumpAndSettle();

      expect(find.text('프리미엄 구독하기'), findsWidgets);
    });

    testWidgets('shows promo pricing with strikethrough', (tester) async {
      await tester.pumpWidget(buildWidget(initialSub: notSubscribed));
      await tester.pumpAndSettle();

      expect(find.textContaining('6,900'), findsWidgets);
      expect(find.textContaining('9,900'), findsWidgets);
    });

    testWidgets('shows benefit list', (tester) async {
      await tester.pumpWidget(buildWidget(initialSub: notSubscribed));
      await tester.pumpAndSettle();

      expect(find.textContaining('월6회'), findsOneWidget);
      expect(find.textContaining('무제한'), findsOneWidget);
      expect(find.textContaining('월3회'), findsOneWidget);
      expect(find.textContaining('광고 제거'), findsOneWidget);
    });

    testWidgets('shows subscribe button', (tester) async {
      await tester.pumpWidget(buildWidget(initialSub: notSubscribed));
      await tester.pumpAndSettle();

      expect(find.text('프리미엄 구독하기'), findsWidgets);
    });
  });

  group('SubscriptionScreen - Subscribed state', () {
    testWidgets('shows plan name', (tester) async {
      await tester.pumpWidget(buildWidget(initialSub: subscribed));
      await tester.pumpAndSettle();

      expect(find.text('ITTO 프리미엄'), findsOneWidget);
    });

    testWidgets('shows expiry date', (tester) async {
      await tester.pumpWidget(buildWidget(initialSub: subscribed));
      await tester.pumpAndSettle();

      expect(find.textContaining('2026-04-05'), findsOneWidget);
    });

    testWidgets('shows cancel link', (tester) async {
      await tester.pumpWidget(buildWidget(initialSub: subscribed));
      await tester.pumpAndSettle();

      expect(find.text('구독 취소'), findsOneWidget);
    });

    testWidgets('tapping cancel shows confirmation dialog', (tester) async {
      await tester.pumpWidget(buildWidget(initialSub: subscribed));
      await tester.pumpAndSettle();

      await tester.tap(find.text('구독 취소'));
      await tester.pumpAndSettle();

      expect(find.text('구독을 해지하시겠습니까?'), findsOneWidget);
    });
  });

  group('SubscriptionScreen - Loading state', () {
    testWidgets('shows loading indicator while fetching', (tester) async {
      final completer = Completer<SubscriptionInfo>();
      when(
        () => mockRepository.getSubscription(),
      ).thenAnswer((_) => completer.future);

      final provider = ShopProvider(repository: mockRepository);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            shopChangeNotifierProvider.overrideWith((_) => provider),
          ],
          child: const MaterialApp(
            home: SubscriptionScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      completer.complete(notSubscribed);
      await tester.pumpAndSettle();
    });
  });
}
