import 'package:flutter_test/flutter_test.dart';
import 'package:itto/data/common/models/api_response.dart';

void main() {
  group('ApiResponse', () {
    test('fromJson creates response with data using fromData converter',
        () {
      final json = {
        'status': 200,
        'message': 'OK',
        'data': {'name': '테스트'},
      };

      final response = ApiResponse<Map<String, dynamic>>.fromJson(
        json,
        (data) => data as Map<String, dynamic>,
      );

      expect(response.status, equals(200));
      expect(response.message, equals('OK'));
      expect(response.isSuccess, isTrue);
      expect(response.data, isNotNull);
      expect(response.data!['name'], equals('테스트'));
    });

    test('fromJson without fromData returns raw data', () {
      final json = {
        'status': 200,
        'message': 'OK',
        'data': 'raw string',
      };

      final response = ApiResponse<String>.fromJson(json, null);

      expect(response.data, equals('raw string'));
    });

    test('fromJson handles null data', () {
      final json = {
        'status': 200,
        'message': 'OK',
        'data': null,
      };

      final response = ApiResponse<String>.fromJson(json, null);

      expect(response.data, isNull);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final response = ApiResponse<dynamic>.fromJson(json, null);

      expect(response.status, equals(200));
      expect(response.message, equals(''));
      expect(response.data, isNull);
      expect(response.code, isNull);
    });

    test('fromJson includes error code', () {
      final json = {
        'status': 409,
        'message': '이미 차단됨',
        'code': 'ALREADY_BLOCKED',
      };

      final response = ApiResponse<dynamic>.fromJson(json, null);

      expect(response.status, equals(409));
      expect(response.code, equals('ALREADY_BLOCKED'));
      expect(response.isSuccess, isFalse);
    });

    test('isSuccess returns true for 2xx status codes', () {
      expect(
        const ApiResponse(status: 200, message: 'OK').isSuccess,
        isTrue,
      );
      expect(
        const ApiResponse(status: 201, message: 'Created').isSuccess,
        isTrue,
      );
      expect(
        const ApiResponse(status: 299, message: 'OK').isSuccess,
        isTrue,
      );
    });

    test('isSuccess returns false for non-2xx status codes', () {
      expect(
        const ApiResponse(status: 400, message: 'Bad Request').isSuccess,
        isFalse,
      );
      expect(
        const ApiResponse(status: 500, message: 'Error').isSuccess,
        isFalse,
      );
      expect(
        const ApiResponse(status: 199, message: 'Info').isSuccess,
        isFalse,
      );
    });
  });
}
