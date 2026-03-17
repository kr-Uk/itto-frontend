import 'package:flutter_test/flutter_test.dart';
import 'package:itto/data/location/models/h3_grid_model.dart';
import 'package:itto/domain/location/entities/h3_grid.dart';

void main() {
  group('H3CellInfoModel', () {
    test('fromJson creates model correctly', () {
      final json = {
        'h3Index': '882ad5a5edfffff',
        'center': {'latitude': 37.5665, 'longitude': 126.978},
        'boundary': [
          [37.567, 126.977],
          [37.566, 126.979],
          [37.565, 126.978],
        ],
      };

      final model = H3CellInfoModel.fromJson(json);

      expect(model.h3Index, equals('882ad5a5edfffff'));
      expect(model.centerLat, equals(37.5665));
      expect(model.centerLng, equals(126.978));
      expect(model.boundary, hasLength(3));
      expect(model.boundary[0], equals([37.567, 126.977]));
    });

    test('fromJson handles integer coordinates', () {
      final json = {
        'h3Index': 'abc',
        'center': {'latitude': 37, 'longitude': 127},
        'boundary': [
          [37, 127],
        ],
      };

      final model = H3CellInfoModel.fromJson(json);

      expect(model.centerLat, equals(37.0));
      expect(model.centerLng, equals(127.0));
      expect(model.boundary[0], equals([37.0, 127.0]));
    });

    test('toEntity returns correct H3CellInfo', () {
      const model = H3CellInfoModel(
        h3Index: 'abc',
        centerLat: 37.5,
        centerLng: 127.0,
        boundary: [
          [37.5, 127.0],
        ],
      );

      final entity = model.toEntity();

      expect(entity, isA<H3CellInfo>());
      expect(entity.h3Index, equals('abc'));
      expect(entity.centerLat, equals(37.5));
    });
  });

  group('H3GridModel', () {
    test('fromJson creates model with cells and selectedIndexes', () {
      final json = {
        'cells': [
          {
            'h3Index': 'cell1',
            'center': {'latitude': 37.5, 'longitude': 127.0},
            'boundary': <List<num>>[],
          },
          {
            'h3Index': 'cell2',
            'center': {'latitude': 37.6, 'longitude': 127.1},
            'boundary': <List<num>>[],
          },
        ],
        'selectedIndexes': ['cell1'],
      };

      final model = H3GridModel.fromJson(json);

      expect(model.cells, hasLength(2));
      expect(model.cells[0].h3Index, equals('cell1'));
      expect(model.selectedIndexes, equals(['cell1']));
    });

    test('fromJson handles missing selectedIndexes', () {
      final json = {
        'cells': <Map<String, dynamic>>[],
      };

      final model = H3GridModel.fromJson(json);

      expect(model.selectedIndexes, isEmpty);
    });

    test('toEntity returns correct H3Grid', () {
      const model = H3GridModel(
        cells: [
          H3CellInfoModel(
            h3Index: 'a',
            centerLat: 37.0,
            centerLng: 127.0,
            boundary: [],
          ),
        ],
        selectedIndexes: ['a'],
      );

      final entity = model.toEntity();

      expect(entity, isA<H3Grid>());
      expect(entity.cells, hasLength(1));
      expect(entity.selectedIndexes, equals(['a']));
    });
  });
}
