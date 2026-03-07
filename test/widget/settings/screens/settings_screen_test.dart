import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:itto/core/di/providers.dart';
import 'package:itto/presentation/settings/screens/settings_screen.dart';
import 'package:itto/presentation/profile/providers/profile_provider.dart';
import 'package:itto/domain/profile/entities/my_profile.dart';
import 'package:itto/domain/profile/repositories/profile_repository.dart';
import 'package:itto/presentation/auth/providers/auth_provider.dart';
import 'package:itto/domain/auth/repositories/auth_repository.dart';
import 'package:itto/domain/auth/services/oauth_service.dart';
import 'package:itto/core/storage/token_storage.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockOAuthService extends Mock implements OAuthService {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockProfileRepository mockProfileRepository;
  late ProfileProvider profileProvider;
  late AuthProvider authProvider;

  final dummyProfile = const MyProfile(
    userId: 1,
    nickname: 'Test',
    gender: 'M',
    birthDate: '1990-01-01',
    age: 36,
    hobbies: [],
    introduction: 'Hello',
    photos: [],
    verificationStatus: 'APPROVED',
    knots: 100,
    isPremium: false,
    createdAt: '2026-01-01',
  );

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    profileProvider = ProfileProvider(repository: mockProfileRepository);

    final mockAuthRepository = MockAuthRepository();
    final mockOAuthService = MockOAuthService();
    final mockTokenStorage = MockTokenStorage();
    authProvider = AuthProvider(
      authRepository: mockAuthRepository,
      oauthService: mockOAuthService,
      tokenStorage: mockTokenStorage,
    );

    when(
      () => mockProfileRepository.getMyProfile(),
    ).thenAnswer((_) async => dummyProfile);
  });

  List<GoRoute> testRoutes() => [
    GoRoute(
      path: '/settings/currency',
      builder: (context, state) =>
          const Scaffold(body: Text('Currency Screen')),
    ),
    GoRoute(
      path: '/settings/subscription',
      builder: (context, state) =>
          const Scaffold(body: Text('Subscription Screen')),
    ),
    GoRoute(
      path: '/tutorial',
      builder: (context, state) =>
          const Scaffold(body: Text('Tutorial Screen')),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const Scaffold(body: Text('Edit')),
    ),
    GoRoute(
      path: '/settings/range',
      builder: (context, state) => const Scaffold(body: Text('Range')),
    ),
    GoRoute(
      path: '/settings/notifications',
      builder: (context, state) => const Scaffold(body: Text('Notifications')),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const Scaffold(body: Text('Login')),
    ),
  ];

  Widget buildWidget() {
    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        ...testRoutes(),
      ],
    );

    return ProviderScope(
      overrides: [
        profileChangeNotifierProvider.overrideWith((_) => profileProvider),
        authChangeNotifierProvider.overrideWith((_) => authProvider),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('SettingsScreen - Menu items', () {
    testWidgets('has "매듭 관리" menu item', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('매듭 관리'), findsOneWidget);
    });

    testWidgets('has "구독하기" menu item', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('구독하기'), findsOneWidget);
    });

    testWidgets('has "튜토리얼" menu item', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('튜토리얼'), findsOneWidget);
    });

    testWidgets('"매듭 관리" navigates to /settings/currency', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('매듭 관리'));
      await tester.pumpAndSettle();

      expect(find.text('Currency Screen'), findsOneWidget);
    });

    testWidgets('"구독하기" navigates to /settings/subscription', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('구독하기'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('구독하기'));
      await tester.pumpAndSettle();

      expect(find.text('Subscription Screen'), findsOneWidget);
    });

    testWidgets('"튜토리얼" navigates to /tutorial', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('튜토리얼'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('튜토리얼'));
      await tester.pumpAndSettle();

      expect(find.text('Tutorial Screen'), findsOneWidget);
    });
  });
}
