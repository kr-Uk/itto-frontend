import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';
import '../storage/token_storage.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  final TokenStorage _tokenStorage;

  ApiClient._({required TokenStorage tokenStorage})
      : _tokenStorage = tokenStorage {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(AuthInterceptor(
      dio: _dio,
      tokenStorage: _tokenStorage,
    ));
  }

  static ApiClient getInstance({required TokenStorage tokenStorage}) {
    _instance ??= ApiClient._(tokenStorage: tokenStorage);
    return _instance!;
  }

  /// 로그인/로그아웃 시 인스턴스 리셋
  static void reset() {
    _instance?._dio.close();
    _instance = null;
  }

  // ─── GET ───────────────────────────────────────────────

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── POST ──────────────────────────────────────────────

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── PUT ───────────────────────────────────────────────

  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── PATCH ─────────────────────────────────────────────

  Future<Map<String, dynamic>> patch(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await _dio.patch(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── DELETE ────────────────────────────────────────────

  Future<Map<String, dynamic>> delete(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await _dio.delete(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── MULTIPART ─────────────────────────────────────────

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required FormData formData,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> putMultipart(
    String path, {
    required FormData formData,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── Internal ──────────────────────────────────────────

  Map<String, dynamic> _handleResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {'status': response.statusCode, 'message': 'OK', 'data': data};
  }

  ApiException _handleDioError(DioException e) {
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
        e.type == DioExceptionType.receiveTimeout) {
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
