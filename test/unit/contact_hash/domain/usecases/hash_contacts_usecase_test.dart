import 'package:flutter_test/flutter_test.dart';
import 'package:itto/domain/contact_hash/usecases/hash_contacts_usecase.dart';

void main() {
  late HashContactsUseCase useCase;

  setUp(() {
    useCase = HashContactsUseCase();
  });

  group('HashContactsUseCase', () {
    test('converts phone number list to SHA-256 hash list', () {
      final result = useCase.execute(['01012345678']);
      expect(result, hasLength(1));
      expect(result.first, hasLength(64));
    });

    test('same number produces same hash (deterministic)', () {
      final hash1 = useCase.execute(['01012345678']);
      final hash2 = useCase.execute(['01012345678']);
      expect(hash1.first, equals(hash2.first));
    });

    test('different numbers produce different hashes', () {
      final result = useCase.execute(['01012345678', '01098765432']);
      expect(result[0], isNot(equals(result[1])));
    });

    test('hash length is 64 hex characters', () {
      final result = useCase.execute(['01012345678']);
      expect(result.first, matches(RegExp(r'^[0-9a-f]{64}$')));
    });

    test('normalized numbers with different formats produce same hash', () {
      final result = useCase.execute([
        '010-1234-5678',
        '01012345678',
        '+82-10-1234-5678',
      ]);
      expect(result[0], equals(result[1]));
      expect(result[1], equals(result[2]));
    });

    test('return value contains only hashes, no raw phone numbers', () {
      final result = useCase.execute(['010-1234-5678']);
      expect(result.first, isNot(contains('010')));
      expect(result.first, isNot(contains('82')));
      expect(result.first, matches(RegExp(r'^[0-9a-f]{64}$')));
    });

    test('empty list returns empty list', () {
      final result = useCase.execute([]);
      expect(result, isEmpty);
    });
  });
}
