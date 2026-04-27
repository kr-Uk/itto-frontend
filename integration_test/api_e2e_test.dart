// API E2E 테스트 — 백엔드 공개 API 흐름 검증.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const String baseUrl = 'https://itto.hguitto.site/api/v1';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final client = HttpClient();

  Future<Map<String, dynamic>> getJson(String path) async {
    final request = await client.getUrl(Uri.parse('$baseUrl$path'));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<({int statusCode, Map<String, dynamic> body})> postJson(
    String path,
    Map<String, dynamic> data,
  ) async {
    final request = await client.postUrl(Uri.parse('$baseUrl$path'));
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode(data));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    return (
      statusCode: response.statusCode,
      body: jsonDecode(body) as Map<String, dynamic>,
    );
  }

  Future<int> putJsonStatus(String path, Map<String, dynamic> data) async {
    final request = await client.putUrl(Uri.parse('$baseUrl$path'));
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode(data));
    final response = await request.close();
    await response.drain();
    return response.statusCode;
  }

  group('E2E: 공개 API', () {
    testWidgets('GET /hobbies - 취미 목록 조회', (tester) async {
      final json = await getJson('/hobbies');

      expect(json['status'], 200);
      expect(json['data'], isA<List>());
      expect((json['data'] as List).length, greaterThan(0));

      // 각 취미에 id, name, category 필드 존재 확인
      final first = (json['data'] as List).first as Map<String, dynamic>;
      expect(first.containsKey('id'), true);
      expect(first.containsKey('name'), true);
      expect(first.containsKey('category'), true);
    });
  });

  group('E2E: 인증 에러 처리', () {
    testWidgets('POST /auth/login - 잘못된 OAuth 토큰으로 401 반환', (tester) async {
      final result = await postJson('/auth/login', {
        'oauthToken': 'invalid_token_for_testing',
        'provider': 'KAKAO',
      });

      expect(result.statusCode, 401);
      expect(result.body['code'], 'OAUTH_VERIFICATION_FAILED');
      expect(result.body['message'], isNotEmpty);
    });

    testWidgets('PUT /location/toggle - 토큰 없이 403 반환', (tester) async {
      final status = await putJsonStatus('/location/toggle', {'enabled': true});
      expect(status, 403);
    });

    testWidgets('POST /location - 토큰 없이 403 반환', (tester) async {
      final result = await postJson('/location', {
        'latitude': 37.5665,
        'longitude': 126.9780,
        'accuracy': 10.0,
        'timestamp': '2026-02-13T10:00:00',
      });

      expect(result.statusCode, 403);
    });

    testWidgets('PUT /fcm/token - 토큰 없이 403 반환', (tester) async {
      final status = await putJsonStatus('/fcm/token', {
        'fcmToken': 'test_token',
        'deviceId': 'test_device',
      });

      expect(status, 403);
    });
  });

  group('E2E: API 응답 형식 검증', () {
    testWidgets('성공 응답에 status, message, data 필드 존재', (tester) async {
      final json = await getJson('/hobbies');

      expect(json.containsKey('status'), true);
      expect(json.containsKey('message'), true);
      expect(json.containsKey('data'), true);
    });

    testWidgets('에러 응답에 status, message, code 필드 존재', (tester) async {
      final result = await postJson('/auth/login', {
        'oauthToken': 'invalid',
        'provider': 'KAKAO',
      });

      expect(result.body.containsKey('status'), true);
      expect(result.body.containsKey('message'), true);
      expect(result.body.containsKey('code'), true);
    });
  });
}
