import 'package:flutter_test/flutter_test.dart';
import 'package:itto/domain/contact_hash/usecases/phone_number_normalizer.dart';

void main() {
  group('PhoneNumberNormalizer', () {
    test('010-1234-5678 -> +821012345678', () {
      expect(
        PhoneNumberNormalizer.normalize('010-1234-5678'),
        equals('+821012345678'),
      );
    });

    test('01012345678 -> +821012345678', () {
      expect(
        PhoneNumberNormalizer.normalize('01012345678'),
        equals('+821012345678'),
      );
    });

    test('+82-10-1234-5678 -> +821012345678', () {
      expect(
        PhoneNumberNormalizer.normalize('+82-10-1234-5678'),
        equals('+821012345678'),
      );
    });

    test('+82 10 1234 5678 -> +821012345678', () {
      expect(
        PhoneNumberNormalizer.normalize('+82 10 1234 5678'),
        equals('+821012345678'),
      );
    });

    test('empty string throws ArgumentError', () {
      expect(
        () => PhoneNumberNormalizer.normalize(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('whitespace only throws ArgumentError', () {
      expect(
        () => PhoneNumberNormalizer.normalize('   '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('invalid format throws ArgumentError', () {
      expect(
        () => PhoneNumberNormalizer.normalize('abc'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
