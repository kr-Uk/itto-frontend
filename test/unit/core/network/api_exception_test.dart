import 'package:flutter_test/flutter_test.dart';
import 'package:itto/core/network/api_exception.dart';

void main() {
  group('ApiException', () {
    group('status code helpers', () {
      test('isUnauthorized returns true for 401', () {
        const exception = ApiException(statusCode: 401, message: 'Unauthorized');
        expect(exception.isUnauthorized, isTrue);
        expect(exception.isForbidden, isFalse);
      });

      test('isForbidden returns true for 403', () {
        const exception = ApiException(statusCode: 403, message: 'Forbidden');
        expect(exception.isForbidden, isTrue);
      });

      test('isNotFound returns true for 404', () {
        const exception = ApiException(statusCode: 404, message: 'Not Found');
        expect(exception.isNotFound, isTrue);
      });

      test('isConflict returns true for 409', () {
        const exception = ApiException(statusCode: 409, message: 'Conflict');
        expect(exception.isConflict, isTrue);
      });
    });

    group('userMessage', () {
      test('returns mapped message when code is known', () {
        const exception = ApiException(
          statusCode: 409,
          message: 'already blocked',
          code: 'ALREADY_BLOCKED',
        );
        expect(exception.userMessage, equals('이미 차단한 사용자입니다.'));
      });

      test('returns server message when code is unknown', () {
        const exception = ApiException(
          statusCode: 500,
          message: '알 수 없는 서버 오류',
          code: 'UNKNOWN_CODE',
        );
        expect(exception.userMessage, equals('알 수 없는 서버 오류'));
      });

      test('returns server message when code is null', () {
        const exception = ApiException(
          statusCode: 400,
          message: '잘못된 요청입니다',
        );
        expect(exception.userMessage, equals('잘못된 요청입니다'));
      });

      test('maps NICKNAME_DUPLICATE correctly', () {
        const exception = ApiException(
          statusCode: 409,
          message: 'duplicate',
          code: 'NICKNAME_DUPLICATE',
        );
        expect(exception.userMessage,
            equals('이미 사용 중인 닉네임이에요.'));
      });

      test('maps INSUFFICIENT_KNOTS correctly', () {
        const exception = ApiException(
          statusCode: 400,
          message: 'not enough',
          code: 'INSUFFICIENT_KNOTS',
        );
        expect(exception.userMessage,
            equals('매듭이 부족합니다. 상점에서 충전해주세요.'));
      });

      test('maps EXCLUDED_AREA_LIMIT correctly', () {
        const exception = ApiException(
          statusCode: 400,
          message: 'limit',
          code: 'EXCLUDED_AREA_LIMIT',
        );
        expect(exception.userMessage,
            equals('제외 지역은 최대 3개까지 등록할 수 있어요.'));
      });

      test('maps TIMEOUT correctly', () {
        const exception = ApiException(
          statusCode: 408,
          message: 'timeout',
          code: 'TIMEOUT',
        );
        expect(exception.userMessage,
            equals('서버 응답이 느립니다. 잠시 후 다시 시도해주세요.'));
      });

      test('maps NETWORK_ERROR correctly', () {
        const exception = ApiException(
          statusCode: 0,
          message: 'no connection',
          code: 'NETWORK_ERROR',
        );
        expect(exception.userMessage,
            equals('네트워크 연결을 확인해주세요.'));
      });
    });

    group('toString', () {
      test('formats correctly with code', () {
        const exception = ApiException(
          statusCode: 400,
          message: 'Bad Request',
          code: 'BAD_REQUEST',
        );
        expect(exception.toString(),
            equals('ApiException(400, Bad Request, BAD_REQUEST)'));
      });

      test('formats correctly without code', () {
        const exception = ApiException(
          statusCode: 500,
          message: 'Server Error',
        );
        expect(exception.toString(),
            equals('ApiException(500, Server Error, null)'));
      });
    });
  });
}
