import 'package:flutter_test/flutter_test.dart';
import 'package:itto/data/common/models/hobby_model.dart';
import 'package:itto/domain/common/entities/hobby.dart';

void main() {
  group('HobbyModel', () {
    test('fromJson creates model with all fields', () {
      final json = {
        'id': 1,
        'name': '독서',
        'category': '문화',
      };

      final model = HobbyModel.fromJson(json);

      expect(model.id, equals(1));
      expect(model.name, equals('독서'));
      expect(model.category, equals('문화'));
    });

    test('fromJson handles null category', () {
      final json = {
        'id': 2,
        'name': '요리',
      };

      final model = HobbyModel.fromJson(json);

      expect(model.category, isNull);
    });

    test('toJson includes all fields', () {
      const model = HobbyModel(id: 1, name: '독서', category: '문화');

      final json = model.toJson();

      expect(json['id'], equals(1));
      expect(json['name'], equals('독서'));
      expect(json['category'], equals('문화'));
    });

    test('toJson excludes null category', () {
      const model = HobbyModel(id: 2, name: '요리');

      final json = model.toJson();

      expect(json.containsKey('category'), isFalse);
    });

    test('toEntity returns correct Hobby', () {
      const model = HobbyModel(id: 1, name: '축구', category: '스포츠');

      final entity = model.toEntity();

      expect(entity, isA<Hobby>());
      expect(entity.id, equals(1));
      expect(entity.name, equals('축구'));
      expect(entity.category, equals('스포츠'));
    });
  });
}
