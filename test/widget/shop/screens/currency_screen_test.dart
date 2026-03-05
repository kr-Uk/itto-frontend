import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:itto/features/shop/providers/shop_provider.dart';
import 'package:itto/features/shop/models/shop_models.dart';
import 'package:itto/features/shop/services/shop_service.dart';
import 'package:itto/features/settings/screens/currency_screen.dart';

class MockShopService extends Mock implements ShopService {}

void main() {
  late MockShopService mockService;
  late ShopProvider shopProvider;

  final testPackages = [
    const KnotPackage(
      id: 1,
      name: '실마리',
      price: 7900,
      knots: 80,
      firstPurchaseKnots: 160,
      isFirstPurchaseUsed: false,
    ),
    const KnotPackage(
      id: 2,
      name: '매듭뭉치',
      price: 19900,
      knots: 250,
      firstPurchaseKnots: 500,
      isFirstPurchaseUsed: false,
    ),
    const KnotPackage(
      id: 3,
      name: '실타래',
      price: 49900,
      knots: 800,
      firstPurchaseKnots: 1600,
      isFirstPurchaseUsed: false,
    ),
  ];

  final testBalance = const KnotBalance(
    knots: 100,
    freeConvertRemaining: 1,
    freeRequestRemaining: 1,
    freeRestoreRemaining: 0,
  );

  final testSubscription = const SubscriptionInfo(isPremium: false);

  setUp(() {
    mockService = MockShopService();
    shopProvider = ShopProvider(service: mockService);

    when(() => mockService.getKnots()).thenAnswer((_) async => testBalance);
    when(() => mockService.getPackages()).thenAnswer((_) async => testPackages);
    when(
      () => mockService.getSubscription(),
    ).thenAnswer((_) async => testSubscription);
  });

  Widget buildWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<ShopProvider>.value(
        value: shopProvider,
        child: const CurrencyScreen(),
      ),
    );
  }

  group('CurrencyScreen - Balance display', () {
    testWidgets('displays heart icon and "나의 매듭" header', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('나의 매듭'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsWidgets);
    });

    testWidgets('displays knot balance from provider', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('100 매듭'), findsOneWidget);
    });
  });

  group('CurrencyScreen - Package display', () {
    testWidgets('shows 3 packages with correct names', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('실마리'), findsOneWidget);
      expect(find.text('매듭뭉치'), findsOneWidget);
      expect(find.text('실타래'), findsOneWidget);
    });

    testWidgets('shows package prices', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('7,900'), findsOneWidget);
      expect(find.textContaining('19,900'), findsOneWidget);
      expect(find.textContaining('49,900'), findsOneWidget);
    });

    testWidgets('shows package knot counts', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('80'), findsWidgets);
      expect(find.textContaining('250'), findsWidgets);
      expect(find.textContaining('800'), findsWidgets);
    });
  });

  group('CurrencyScreen - First purchase badge', () {
    testWidgets(
      'shows first-purchase 2x badge when isFirstPurchaseUsed is false',
      (tester) async {
        await tester.pumpWidget(buildWidget());
        await tester.pumpAndSettle();

        expect(find.text('첫 구매 2배'), findsWidgets);
      },
    );

    testWidgets('hides first-purchase badge when isFirstPurchaseUsed is true', (
      tester,
    ) async {
      final usedPackages = testPackages
          .map(
            (p) => KnotPackage(
              id: p.id,
              name: p.name,
              price: p.price,
              knots: p.knots,
              firstPurchaseKnots: p.firstPurchaseKnots,
              isFirstPurchaseUsed: true,
            ),
          )
          .toList();

      when(
        () => mockService.getPackages(),
      ).thenAnswer((_) async => usedPackages);

      final usedProvider = ShopProvider(service: mockService);
      await usedProvider.loadPackages();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ShopProvider>.value(
            value: usedProvider,
            child: const CurrencyScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('첫 구매 2배'), findsNothing);
    });
  });

  group('CurrencyScreen - Usage guide', () {
    testWidgets('shows usage guide section', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('매듭 사용 안내'), findsOneWidget);
      expect(find.text('우연을 인연으로 풀기'), findsOneWidget);
      expect(find.text('지난 인연 다시 만나기'), findsOneWidget);
      expect(find.text('한달 동안 광고 제거'), findsOneWidget);
    });
  });

  group('CurrencyScreen - Purchase dialog', () {
    testWidgets('tapping package shows purchase dialog', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Tap first package card
      await tester.tap(find.text('실마리').first);
      await tester.pumpAndSettle();

      expect(find.text('80매듭을 구매할까요?'), findsOneWidget);
    });
  });

  group('CurrencyScreen - Loading state', () {
    testWidgets('shows loading indicator while fetching', (tester) async {
      final balanceCompleter = Completer<KnotBalance>();
      final packagesCompleter = Completer<List<KnotPackage>>();

      when(
        () => mockService.getKnots(),
      ).thenAnswer((_) => balanceCompleter.future);
      when(
        () => mockService.getPackages(),
      ).thenAnswer((_) => packagesCompleter.future);

      await tester.pumpWidget(buildWidget());
      await tester.pump(); // post frame callback
      await tester.pump(); // rebuild after notifyListeners

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Complete the futures to clean up
      balanceCompleter.complete(testBalance);
      packagesCompleter.complete(testPackages);
      await tester.pumpAndSettle();
    });
  });

  group('CurrencyScreen - No subscription section', () {
    testWidgets('does NOT show subscription section', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('구독 정보'), findsNothing);
      expect(find.text('프리미엄을 구독하고 더 많은 혜택을 받아보세요'), findsNothing);
    });
  });
}
