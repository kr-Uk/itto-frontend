import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:itto/data/common/models/hobby_model.dart';
import 'package:itto/data/system/datasources/system_remote_datasource.dart';
import 'package:itto/data/system/models/nickname_validation_model.dart';
import 'package:itto/data/system/models/version_info_model.dart';
import 'package:itto/data/system/repositories/system_repository_impl.dart';

class MockSystemRemoteDataSource extends Mock
    implements SystemRemoteDataSource {}

void main() {
  late MockSystemRemoteDataSource mockRemoteDataSource;
  late SystemRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockSystemRemoteDataSource();
    repository = SystemRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('SystemRepositoryImpl', () {
    group('checkVersion', () {
      test('returns VersionInfo entity from remote data source', () async {
        when(() => mockRemoteDataSource.checkVersion()).thenAnswer(
          (_) async => const VersionInfoModel(
            minVersion: '1.0.0',
            latestVersion: '1.2.0',
            forceUpdate: true,
            updateUrl: 'https://example.com',
          ),
        );

        final result = await repository.checkVersion();

        expect(result.minVersion, equals('1.0.0'));
        expect(result.latestVersion, equals('1.2.0'));
        expect(result.forceUpdate, isTrue);
        expect(result.updateUrl, equals('https://example.com'));
        verify(() => mockRemoteDataSource.checkVersion()).called(1);
      });

      test('propagates exception', () async {
        when(() => mockRemoteDataSource.checkVersion())
            .thenThrow(Exception('Network error'));

        expect(
          () => repository.checkVersion(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getHobbies', () {
      test('returns list of Hobby entities', () async {
        final models = [
          const HobbyModel(id: 1, name: '독서', category: '문화'),
          const HobbyModel(id: 2, name: '축구', category: '스포츠'),
          const HobbyModel(id: 3, name: '요리'),
        ];
        when(() => mockRemoteDataSource.getHobbies())
            .thenAnswer((_) async => models);

        final result = await repository.getHobbies();

        expect(result, hasLength(3));
        expect(result[0].id, equals(1));
        expect(result[0].name, equals('독서'));
        expect(result[0].category, equals('문화'));
        expect(result[2].category, isNull);
      });

      test('returns empty list when no hobbies', () async {
        when(() => mockRemoteDataSource.getHobbies())
            .thenAnswer((_) async => []);

        final result = await repository.getHobbies();

        expect(result, isEmpty);
      });
    });

    group('validateNickname', () {
      test('returns valid NicknameValidation', () async {
        when(() => mockRemoteDataSource.validateNickname(any())).thenAnswer(
          (_) async => const NicknameValidationModel(
            valid: true,
            message: '사용 가능한 닉네임입니다',
          ),
        );

        final result = await repository.validateNickname('좋은닉네임');

        expect(result.valid, isTrue);
        expect(result.message, equals('사용 가능한 닉네임입니다'));
        verify(() => mockRemoteDataSource.validateNickname('좋은닉네임'))
            .called(1);
      });

      test('returns invalid NicknameValidation with code', () async {
        when(() => mockRemoteDataSource.validateNickname(any())).thenAnswer(
          (_) async => const NicknameValidationModel(
            valid: false,
            message: '이미 사용 중',
            code: 'NICKNAME_DUPLICATE',
          ),
        );

        final result = await repository.validateNickname('중복닉');

        expect(result.valid, isFalse);
        expect(result.code, equals('NICKNAME_DUPLICATE'));
      });
    });
  });
}
