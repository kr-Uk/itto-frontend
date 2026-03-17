import 'package:flutter_test/flutter_test.dart';
import 'package:itto/data/system/models/nickname_validation_model.dart';
import 'package:itto/domain/system/entities/nickname_validation.dart';

void main() {
  group('NicknameValidationModel', () {
    test('fromJson creates model with all fields', () {
      final json = {
        'valid': true,
        'message': '사용 가능한 닉네임입니다',
        'code': null,
      };

      final model = NicknameValidationModel.fromJson(json);

      expect(model.valid, isTrue);
      expect(model.message, equals('사용 가능한 닉네임입니다'));
      expect(model.code, isNull);
    });

    test('fromJson with validation error', () {
      final json = {
        'valid': false,
        'message': '이미 사용 중인 닉네임입니다',
        'code': 'NICKNAME_DUPLICATE',
      };

      final model = NicknameValidationModel.fromJson(json);

      expect(model.valid, isFalse);
      expect(model.code, equals('NICKNAME_DUPLICATE'));
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final model = NicknameValidationModel.fromJson(json);

      expect(model.valid, isFalse);
      expect(model.message, equals(''));
      expect(model.code, isNull);
    });

    test('toEntity returns correct NicknameValidation', () {
      const model = NicknameValidationModel(
        valid: true,
        message: '사용 가능',
        code: null,
      );

      final entity = model.toEntity();

      expect(entity, isA<NicknameValidation>());
      expect(entity.valid, isTrue);
      expect(entity.message, equals('사용 가능'));
    });
  });
}
