import 'package:flutter_test/flutter_test.dart';
import 'package:itto/data/location/models/excluded_area_model.dart';
import 'package:itto/domain/location/entities/excluded_area.dart';

void main() {
  group('ExcludedAreaModel', () {
    test('fromJson creates model with all fields', () {
      final json = {
        'id': 1,
        'name': '우리집',
        'latitude': 37.5665,
        'longitude': 126.9780,
        'radius': 200,
        'h3Indexes': ['882ad5a5edfffff', '882ad5a5e1fffff'],
      };

      final model = ExcludedAreaModel.fromJson(json);

      expect(model.id, equals(1));
      expect(model.name, equals('우리집'));
      expect(model.latitude, equals(37.5665));
      expect(model.longitude, equals(126.9780));
      expect(model.radius, equals(200));
      expect(model.h3Indexes, hasLength(2));
    });

    test('fromJson handles missing radius with default 100', () {
      final json = {
        'id': 2,
        'name': '회사',
        'latitude': 37.5,
        'longitude': 127.0,
      };

      final model = ExcludedAreaModel.fromJson(json);

      expect(model.radius, equals(100));
    });

    test('fromJson handles missing h3Indexes with empty list', () {
      final json = {
        'id': 3,
        'name': '학교',
        'latitude': 37.0,
        'longitude': 127.0,
        'radius': 150,
      };

      final model = ExcludedAreaModel.fromJson(json);

      expect(model.h3Indexes, isEmpty);
    });

    test('fromJson handles integer coordinates via num.toDouble()', () {
      final json = {
        'id': 4,
        'name': '정수좌표',
        'latitude': 37,
        'longitude': 127,
        'radius': 100,
      };

      final model = ExcludedAreaModel.fromJson(json);

      expect(model.latitude, equals(37.0));
      expect(model.longitude, equals(127.0));
    });

    test('toEntity returns correct ExcludedArea', () {
      const model = ExcludedAreaModel(
        id: 1,
        name: '집',
        latitude: 37.5665,
        longitude: 126.978,
        radius: 200,
        h3Indexes: ['abc123'],
      );

      final entity = model.toEntity();

      expect(entity, isA<ExcludedArea>());
      expect(entity.id, equals(1));
      expect(entity.name, equals('집'));
      expect(entity.latitude, equals(37.5665));
      expect(entity.longitude, equals(126.978));
      expect(entity.radius, equals(200));
      expect(entity.h3Indexes, equals(['abc123']));
    });
  });
}
