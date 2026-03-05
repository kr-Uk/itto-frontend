import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:itto/features/shop/providers/shop_provider.dart';
import 'package:itto/features/shop/models/shop_models.dart';
import 'package:itto/features/shop/services/shop_service.dart';
import 'package:itto/features/settings/screens/subscription_screen.dart';

class MockShopService extends Mock implements ShopService {}

void main() {
  late MockShopService mockService;

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
    mockService = MockShopService();
    when(
      () => mockService.getSubscription(),
    ).thenAnswer((_) async => notSubscribed);
    when(() => mockService.getKnots()).thenAnswer(
      (_) async => const KnotBalance(
        knots: 0,
        freeConvertRemaining: 0,
        freeRequestRemaining: 0,
        freeRestoreRemaining: 0,
      ),
    );
    when(() => mockService.getPackages()).thenAnswer((_) async => []);
    when(
      () => mockService.subscribe(
        receiptToken: any(named: 'receiptToken'),
        store: any(named: 'store'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockService.cancelSubscription()).thenAnswer((_) async {});
  });

  Widget buildWidget({SubscriptionInfo? initialSub}) {
    final provider = ShopProvider(service: mockService);
    if (initialSub != null) {
      // Pre-load subscription data
      when(
        () => mockService.getSubscription(),
      ).thenAnswer((_) async => initialSub);
    }
    return MaterialApp(
      home: ChangeNotifierProvider<ShopProvider>.value(
        value: provider,
        child: const SubscriptionScreen(),
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
        () => mockService.getSubscription(),
      ).thenAnswer((_) => completer.future);

      final provider = ShopProvider(service: mockService);
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ShopProvider>.value(
            value: provider,
            child: const SubscriptionScreen(),
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
