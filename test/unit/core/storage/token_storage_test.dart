import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itto/core/storage/token_storage.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockSecureStorage;
  late TokenStorage tokenStorage;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    tokenStorage = TokenStorage(secureStorage: mockSecureStorage);
  });

  group('TokenStorage', () {
    group('saveTokens', () {
      test('saves both access and refresh tokens', () async {
        when(() => mockSecureStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            )).thenAnswer((_) async {});

        await tokenStorage.saveTokens(
          accessToken: 'access_123',
          refreshToken: 'refresh_456',
        );

        verify(() => mockSecureStorage.write(
              key: 'access_token',
              value: 'access_123',
            )).called(1);
        verify(() => mockSecureStorage.write(
              key: 'refresh_token',
              value: 'refresh_456',
            )).called(1);
      });
    });

    group('getAccessToken', () {
      test('returns stored access token', () async {
        when(() => mockSecureStorage.read(key: 'access_token'))
            .thenAnswer((_) async => 'my_access_token');

        final result = await tokenStorage.getAccessToken();

        expect(result, equals('my_access_token'));
      });

      test('returns null when no token stored', () async {
        when(() => mockSecureStorage.read(key: 'access_token'))
            .thenAnswer((_) async => null);

        final result = await tokenStorage.getAccessToken();

        expect(result, isNull);
      });
    });

    group('getRefreshToken', () {
      test('returns stored refresh token', () async {
        when(() => mockSecureStorage.read(key: 'refresh_token'))
            .thenAnswer((_) async => 'my_refresh_token');

        final result = await tokenStorage.getRefreshToken();

        expect(result, equals('my_refresh_token'));
      });

      test('returns null when no token stored', () async {
        when(() => mockSecureStorage.read(key: 'refresh_token'))
            .thenAnswer((_) async => null);

        final result = await tokenStorage.getRefreshToken();

        expect(result, isNull);
      });
    });

    group('clearTokens', () {
      test('deletes both access and refresh tokens', () async {
        when(() => mockSecureStorage.delete(key: any(named: 'key')))
            .thenAnswer((_) async {});

        await tokenStorage.clearTokens();

        verify(() => mockSecureStorage.delete(key: 'access_token')).called(1);
        verify(() => mockSecureStorage.delete(key: 'refresh_token')).called(1);
      });
    });

    group('hasTokens', () {
      test('returns true when access token exists and is non-empty', () async {
        when(() => mockSecureStorage.read(key: 'access_token'))
            .thenAnswer((_) async => 'valid_token');

        final result = await tokenStorage.hasTokens();

        expect(result, isTrue);
      });

      test('returns false when access token is null', () async {
        when(() => mockSecureStorage.read(key: 'access_token'))
            .thenAnswer((_) async => null);

        final result = await tokenStorage.hasTokens();

        expect(result, isFalse);
      });

      test('returns false when access token is empty string', () async {
        when(() => mockSecureStorage.read(key: 'access_token'))
            .thenAnswer((_) async => '');

        final result = await tokenStorage.hasTokens();

        expect(result, isFalse);
      });
    });
  });
}
