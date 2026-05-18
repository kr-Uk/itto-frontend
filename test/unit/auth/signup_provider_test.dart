import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:itto/presentation/auth/providers/signup_provider.dart';
import 'package:itto/domain/auth/repositories/signup_repository.dart';

class MockSignupRepository extends Mock implements SignupRepository {}

void main() {
  late MockSignupRepository mockRepository;
  late SignupProvider provider;

  setUp(() {
    mockRepository = MockSignupRepository();
    provider = SignupProvider(repository: mockRepository);
  });

  group('SignupProvider - profile fields', () {
    test('saveProfile passes birthDate set directly', () async {
      when(
        () => mockRepository.saveProfile(
          nickname: any(named: 'nickname'),
          gender: any(named: 'gender'),
          birthDate: any(named: 'birthDate'),
          hobbyIds: any(named: 'hobbyIds'),
          introduction: any(named: 'introduction'),
        ),
      ).thenAnswer((_) async {});

      provider.nickname = '테스트유저';
      provider.gender = 'MALE';
      provider.birthDate = '1990-01-15';
      provider.hobbyIds = [1, 2];

      await provider.saveProfile();

      verify(
        () => mockRepository.saveProfile(
          nickname: '테스트유저',
          gender: 'MALE',
          birthDate: '1990-01-15',
          hobbyIds: [1, 2],
          introduction: null,
        ),
      ).called(1);
    });
  });

  group('SignupProvider - photo limit', () {
    test('photoFilePaths should not exceed maxPhotos (1)', () {
      expect(
        SignupProvider.maxPhotos,
        equals(1),
        reason: 'maxPhotos should be 1 for profile photo limit',
      );
    });

    test('addPhoto should reject when at max capacity', () {
      provider.addPhoto('/path/photo1.jpg');
      expect(provider.photoFilePaths.length, equals(1));

      provider.addPhoto('/path/photo2.jpg');
      expect(
        provider.photoFilePaths.length,
        equals(1),
        reason: 'Should not exceed maxPhotos limit',
      );
    });
  });

  group('SignupProvider - resetForm', () {
    test('resetForm clears all fields properly', () {
      provider.nickname = '테스트';
      provider.gender = 'MALE';
      provider.birthDate = '1990-01-15';
      provider.hobbyIds = [1];
      provider.introduction = '안녕하세요';
      provider.photoFilePaths = ['/path/to/photo.jpg'];
      provider.marketingConsent = true;

      provider.resetForm();

      expect(provider.nickname, isEmpty);
      expect(provider.gender, isEmpty);
      expect(provider.birthDate, isEmpty);
      expect(provider.hobbyIds, isEmpty);
      expect(provider.introduction, isEmpty);
      expect(provider.photoFilePaths, isEmpty);
      expect(provider.representativePhotoIndex, equals(0));
      expect(provider.marketingConsent, isFalse);
    });
  });
}
