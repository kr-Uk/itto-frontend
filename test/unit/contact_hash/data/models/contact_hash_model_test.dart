import 'package:flutter_test/flutter_test.dart';
import 'package:itto/features/contact_hash/data/models/contact_hash_model.dart';

void main() {
  group('ContactHashModel', () {
    test('fromJson correctly parses', () {
      final json = {
        'id': 1,
        'phoneHash': 'a' * 64,
        'createdAt': '2026-03-05T12:00:00',
      };

      final model = ContactHashModel.fromJson(json);

      expect(model.id, equals(1));
      expect(model.phoneHash, equals('a' * 64));
      expect(model.createdAt, equals(DateTime(2026, 3, 5, 12, 0, 0)));
    });

    test('toJson correctly serializes', () {
      final model = ContactHashModel(
        id: 1,
        phoneHash: 'b' * 64,
        createdAt: DateTime(2026, 3, 5, 12, 0, 0),
      );

      final json = model.toJson();

      expect(json['id'], equals(1));
      expect(json['phoneHash'], equals('b' * 64));
      expect(json['createdAt'], contains('2026-03-05'));
    });

    test('toEntity converts correctly', () {
      final model = ContactHashModel(
        id: 1,
        phoneHash: 'c' * 64,
        createdAt: DateTime(2026, 3, 5, 12, 0, 0),
      );

      final entity = model.toEntity();

      expect(entity.id, equals(1));
      expect(entity.phoneHash, equals('c' * 64));
      expect(entity.createdAt, equals(DateTime(2026, 3, 5, 12, 0, 0)));
    });
  });
}
