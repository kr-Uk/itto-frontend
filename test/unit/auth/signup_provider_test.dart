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

  group('SignupProvider - verification removal', () {
    test('should NOT have verificationFilePath field', () {
      final hasField = _hasPublicField(provider, 'verificationFilePath');
      expect(
        hasField,
        isFalse,
        reason: 'verificationFilePath should be removed from SignupProvider',
      );
    });

    test('should NOT have uploadVerification method', () {
      final dynamic dynamicProvider = provider;
      bool hasMethod = true;
      try {
        dynamicProvider.uploadVerification;
      } on NoSuchMethodError {
        hasMethod = false;
      }
      expect(
        hasMethod,
        isFalse,
        reason: 'uploadVerification should be removed from SignupProvider',
      );
    });
  });

  group('SignupProvider - identity result', () {
    test('setIdentityResult stores birthDate correctly', () {
      provider.setIdentityResult(
        name: '홍길동',
        phone: '01012345678',
        gender: 'MALE',
        birthDate: '1990-01-15',
      );

      expect(provider.identityVerified, isTrue);
      expect(provider.birthDate, equals('1990-01-15'));
      expect(provider.gender, equals('MALE'));
      expect(provider.verifiedName, equals('홍길동'));
      expect(provider.verifiedPhone, equals('01012345678'));
      expect(provider.verifiedGender, equals('MALE'));
      expect(provider.verifiedBirthDate, equals('1990-01-15'));
    });

    test('saveProfile includes birthDate from NICE identity result', () async {
      when(
        () => mockRepository.saveProfile(
          nickname: any(named: 'nickname'),
          gender: any(named: 'gender'),
          birthDate: any(named: 'birthDate'),
          hobbyIds: any(named: 'hobbyIds'),
          introduction: any(named: 'introduction'),
        ),
      ).thenAnswer((_) async {});

      provider.setIdentityResult(
        name: '홍길동',
        phone: '01012345678',
        gender: 'MALE',
        birthDate: '1990-01-15',
      );
      provider.nickname = '테스트유저';
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
      provider.setIdentityResult(
        name: '홍길동',
        phone: '01012345678',
        gender: 'MALE',
        birthDate: '1990-01-15',
      );
      provider.nickname = '테스트';
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
      expect(provider.identityVerified, isFalse);
      expect(provider.verifiedName, isNull);
      expect(provider.verifiedPhone, isNull);
      expect(provider.verifiedGender, isNull);
      expect(provider.verifiedBirthDate, isNull);
    });
  });
}

/// Helper to check if a dynamic object has a public field via noSuchMethod
bool _hasPublicField(dynamic obj, String fieldName) {
  try {
    final dynamic d = obj;
    switch (fieldName) {
      case 'verificationFilePath':
        // ignore: unnecessary_statements
        d.verificationFilePath;
        return true;
      default:
        return false;
    }
  } on NoSuchMethodError {
    return false;
  }
}
