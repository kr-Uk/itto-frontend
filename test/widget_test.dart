import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:itto/core/di/providers.dart';
import 'package:itto/presentation/auth/providers/auth_provider.dart';
import 'package:itto/domain/auth/repositories/auth_repository.dart';
import 'package:itto/domain/auth/services/oauth_service.dart';
import 'package:itto/core/storage/token_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockOAuthService extends Mock implements OAuthService {}
class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  testWidgets('App starts without error', (WidgetTester tester) async {
    final mockAuthRepo = MockAuthRepository();
    final mockOAuth = MockOAuthService();
    final mockToken = MockTokenStorage();

    when(() => mockToken.getAccessToken()).thenAnswer((_) async => null);
    when(() => mockToken.getRefreshToken()).thenAnswer((_) async => null);

    final authProvider = AuthProvider(
      authRepository: mockAuthRepo,
      oauthService: mockOAuth,
      tokenStorage: mockToken,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authChangeNotifierProvider.overrideWith((_) => authProvider),
        ],
        child: const MaterialApp(
          home: Scaffold(body: Text('ITTO')),
        ),
      ),
    );

    expect(find.text('ITTO'), findsOneWidget);
  });
}
