import 'package:flutter_test/flutter_test.dart';
import 'package:itto/data/location/models/location_toggle_model.dart';
import 'package:itto/domain/location/entities/location_toggle_result.dart';

void main() {
  group('LocationToggleModel', () {
    test('fromJson creates model with all fields', () {
      final json = {
        'enabled': true,
        'message': '위치 서비스가 활성화되었습니다',
      };

      final model = LocationToggleModel.fromJson(json);

      expect(model.enabled, isTrue);
      expect(model.message, equals('위치 서비스가 활성화되었습니다'));
    });

    test('fromJson handles missing message with empty string', () {
      final json = {'enabled': false};

      final model = LocationToggleModel.fromJson(json);

      expect(model.enabled, isFalse);
      expect(model.message, equals(''));
    });

    test('toEntity returns correct LocationToggleResult', () {
      const model = LocationToggleModel(
        enabled: true,
        message: '활성화',
      );

      final entity = model.toEntity();

      expect(entity, isA<LocationToggleResult>());
      expect(entity.enabled, isTrue);
      expect(entity.message, equals('활성화'));
    });
  });
}
