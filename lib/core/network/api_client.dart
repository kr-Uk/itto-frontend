// HTTP 클라이언트 — 앱 전체에서 서버 통신을 담당하는 싱글톤 클래스.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:itto/core/config/app_config.dart';
import 'package:itto/core/network/api_exception.dart';
import 'package:itto/core/network/auth_interceptor.dart';
import 'package:itto/core/storage/token_storage.dart';

class ApiClient {
  static ApiClient? _instance; // 싱글톤: 앱 전체에서 이 변수에 딱 하나의 인스턴스만 저장됩니다
  late final Dio _dio; // 실제 HTTP 통신을 담당하는 Dio 객체
  final TokenStorage _tokenStorage; // 로그인 토큰(출입증)을 관리하는 저장소

  /// private 생성자 - 외부에서 직접 new ApiClient()로 만들 수 없고,
  /// 반드시 getInstance()를 통해서만 생성/접근합니다 (싱글톤 패턴)
  ApiClient._({required TokenStorage tokenStorage})
    : _tokenStorage = tokenStorage {
    /// Dio 객체 생성 및 기본 설정
    /// - baseUrl: 모든 요청의 기본 서버 주소 (예: https://api.hguitto.site/api/v1)
    /// - connectTimeout: 서버 연결 최대 대기 시간
    /// - headers: 모든 요청에 기본으로 붙는 정보 (JSON 형식으로 통신하겠다는 약속)
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    /// 인터셉터 등록 - 모든 요청/응답을 중간에서 가로채는 역할
    /// AuthInterceptor: 요청마다 자동으로 로그인 토큰을 붙여주고, 만료되면 갱신합니다
    _dio.interceptors.add(
      AuthInterceptor(dio: _dio, tokenStorage: _tokenStorage),
    );

    /// 디버그 모드(개발 중)일 때만 통신 내역을 콘솔에 출력합니다
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: true,
          logPrint: (o) => debugPrint('[API] $o'),
        ),
      );
    }
  }

  /// 싱글톤 인스턴스를 가져오는 메서드
  /// 처음 호출하면 새로 만들고, 이후에는 이미 만들어진 것을 재사용합니다
  /// (??= 연산자: 값이 null이면 새로 만들고, 아니면 기존 값 사용)
  static ApiClient getInstance({required TokenStorage tokenStorage}) {
    _instance ??= ApiClient._(tokenStorage: tokenStorage);
    return _instance!;
  }

  /// 로그인/로그아웃 시 인스턴스 리셋
  /// 기존 Dio 인스턴스를 close()하여 리소스 누수를 방지한 후 null로 초기화.
  /// 다음 getInstance() 호출 시 새 Dio 인스턴스가 생성됩니다.
  static void reset() {
    _instance?._dio.close();
    _instance = null;
  }

  // ─── GET: 서버에서 데이터를 가져오는 요청 (예: 내 프로필 조회, 알림 목록 가져오기) ───

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── POST: 서버에 새 데이터를 보내는 요청 (예: 회원가입, 로그인, 메시지 전송) ───

  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── PUT: 서버의 기존 데이터를 통째로 수정하는 요청 (예: 프로필 전체 수정) ───

  Future<Map<String, dynamic>> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── PATCH: 서버의 기존 데이터 중 일부만 수정하는 요청 (예: 닉네임만 변경) ───

  Future<Map<String, dynamic>> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── DELETE: 서버의 데이터를 삭제하는 요청 (예: 계정 탈퇴, 채팅방 나가기) ───

  Future<Map<String, dynamic>> delete(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── MULTIPART: 파일(사진, 동영상 등)을 서버에 업로드하는 특수 요청 ───

  /// 파일을 포함한 POST 요청 (예: 프로필 사진 업로드)
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required FormData formData,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: AppConfig.uploadTimeout,
          receiveTimeout: AppConfig.uploadTimeout,
        ),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 파일을 포함한 PUT 요청 (예: 프로필 사진 교체)
  Future<Map<String, dynamic>> putMultipart(
    String path, {
    required FormData formData,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: AppConfig.uploadTimeout,
          receiveTimeout: AppConfig.uploadTimeout,
        ),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── Internal: 내부에서만 사용하는 도우미 메서드들 ──────────────────

  /// 서버 응답을 정리하여 Map(키-값 쌍) 형태로 변환합니다
  Map<String, dynamic> _handleResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {'status': response.statusCode, 'message': 'OK', 'data': data};
  }

  /// 서버 통신 중 오류가 발생했을 때 사용자에게 보여줄 에러 메시지를 만듭니다
  /// (타임아웃, 서버 다운, 네트워크 끊김 등 상황별로 다른 메시지를 반환)
  ApiException _handleDioError(DioException e) {
    debugPrint(
      '[API ERROR] type=${e.type} url=${e.requestOptions.uri} message=${e.message}',
    );
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        return ApiException(
          statusCode: data['status'] as int? ?? e.response!.statusCode ?? 500,
          message: data['message'] as String? ?? '알 수 없는 오류',
          code: data['code'] as String?,
        );
      }
      final statusCode = e.response!.statusCode ?? 500;
      if (statusCode >= 520 && statusCode <= 530) {
        return ApiException(
          statusCode: statusCode,
          message: '서버에 연결할 수 없습니다 (서버 점검 중)',
          code: 'SERVER_DOWN',
        );
      }
      return ApiException(
        statusCode: statusCode,
        message: e.response!.statusMessage?.isNotEmpty == true
            ? e.response!.statusMessage!
            : '서버 오류가 발생했습니다',
      );
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ApiException(
        statusCode: 408,
        message: '서버 응답 시간이 초과되었습니다',
        code: 'TIMEOUT',
      );
    }

    return ApiException(
      statusCode: 0,
      message: '네트워크 연결을 확인해주세요',
      code: 'NETWORK_ERROR',
    );
  }
}
