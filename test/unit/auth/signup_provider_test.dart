import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:itto/features/auth/providers/signup_provider.dart';
import 'package:itto/features/auth/services/signup_service.dart';
import 'package:itto/features/auth/models/signup_models.dart';

class MockSignupService extends Mock implements SignupService {}

class FakeSignupTermsRequest extends Fake implements SignupTermsRequest {}

class FakeSignupProfileRequest extends Fake implements SignupProfileRequest {}

void main() {
  late MockSignupService mockService;
  late SignupProvider provider;

  setUpAll(() {
    registerFallbackValue(FakeSignupTermsRequest());
    registerFallbackValue(FakeSignupProfileRequest());
  });

  setUp(() {
    mockService = MockSignupService();
    provider = SignupProvider(signupService: mockService);
  });

  group('SignupProvider - verification removal', () {
    test('should NOT have verificationFilePath field', () {
      // The provider should not expose verificationFilePath.
      // After removal, accessing provider.verificationFilePath will cause
      // a compile error. We verify the field does not exist by checking
      // the provider's public API does not include it.
      //
      // If verificationFilePath still exists, this test file will compile
      // but the assertion below ensures it is not part of the intended API.
      // We check via reflection-like approach: the resetForm should NOT
      // reset verificationFilePath (it should not exist).
      final hasField = _hasPublicField(provider, 'verificationFilePath');
      expect(
        hasField,
        isFalse,
        reason: 'verificationFilePath should be removed from SignupProvider',
      );
    });

    test('should NOT have uploadVerification method', () {
      // After removal, calling provider.uploadVerification() will cause
      // a compile error. We use a dynamic check here.
      final dynamic dynamicProvider = provider;
      bool hasMethod = true;
      try {
        // This will throw NoSuchMethodError if the method doesn't exist
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
      when(() => mockService.saveProfile(any())).thenAnswer((_) async {});

      provider.setIdentityResult(
        name: '홍길동',
        phone: '01012345678',
        gender: 'MALE',
        birthDate: '1990-01-15',
      );
      provider.nickname = '테스트유저';
      provider.hobbyIds = [1, 2];

      await provider.saveProfile();

      final captured = verify(
        () => mockService.saveProfile(captureAny()),
      ).captured;
      final request = captured.first as SignupProfileRequest;
      expect(request.birthDate, equals('1990-01-15'));
      expect(request.gender, equals('MALE'));
      expect(request.nickname, equals('테스트유저'));
    });
  });

  group('SignupProvider - photo limit', () {
    test('photoFilePaths should not exceed maxPhotos (1)', () {
      // The provider should enforce max 1 photo
      expect(
        SignupProvider.maxPhotos,
        equals(1),
        reason: 'maxPhotos should be 1 for profile photo limit',
      );
    });

    test('addPhoto should reject when at max capacity', () {
      provider.addPhoto('/path/photo1.jpg');
      expect(provider.photoFilePaths.length, equals(1));

      // Adding a second photo should be rejected
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
    // Use dynamic invocation to check field existence
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
