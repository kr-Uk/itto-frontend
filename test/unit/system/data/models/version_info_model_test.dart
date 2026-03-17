import 'package:flutter_test/flutter_test.dart';
import 'package:itto/data/system/models/version_info_model.dart';
import 'package:itto/domain/system/entities/version_info.dart';

void main() {
  group('VersionInfoModel', () {
    test('fromJson creates model with all fields', () {
      final json = {
        'minVersion': '1.0.0',
        'latestVersion': '1.2.0',
        'forceUpdate': true,
        'updateUrl': 'https://play.google.com/store/apps/details?id=com.itto',
      };

      final model = VersionInfoModel.fromJson(json);

      expect(model.minVersion, equals('1.0.0'));
      expect(model.latestVersion, equals('1.2.0'));
      expect(model.forceUpdate, isTrue);
      expect(model.updateUrl, isNotNull);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final model = VersionInfoModel.fromJson(json);

      expect(model.minVersion, equals('1.0.0'));
      expect(model.latestVersion, equals('1.0.0'));
      expect(model.forceUpdate, isFalse);
      expect(model.updateUrl, isNull);
    });

    test('toEntity returns correct VersionInfo', () {
      const model = VersionInfoModel(
        minVersion: '1.1.0',
        latestVersion: '1.3.0',
        forceUpdate: false,
        updateUrl: 'https://example.com',
      );

      final entity = model.toEntity();

      expect(entity, isA<VersionInfo>());
      expect(entity.minVersion, equals('1.1.0'));
      expect(entity.latestVersion, equals('1.3.0'));
      expect(entity.forceUpdate, isFalse);
      expect(entity.updateUrl, equals('https://example.com'));
    });
  });
}
