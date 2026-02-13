import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenStorage tokenStorage;
  bool _isRefreshing = false;
  final List<_RetryRequest> _pendingRequests = [];

  /// 인증 불필요 경로
  static const _publicPaths = [
    '/auth/login',
    '/auth/refresh',
    '/system/version',
    '/hobbies',
    '/nickname/validate',
  ];

  AuthInterceptor({required this.dio, required this.tokenStorage});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 공개 API는 토큰 부착 생략
    final isPublic = _publicPaths.any((p) => options.path.contains(p));
    if (!isPublic) {
      final token = await tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // 토큰 갱신 요청 자체가 401이면 재로그인 필요
    if (err.requestOptions.path.contains('/auth/refresh')) {
      await tokenStorage.clearTokens();
      return handler.next(err);
    }

    // 이미 갱신 중이면 대기열에 추가
    if (_isRefreshing) {
      _pendingRequests.add(_RetryRequest(
        options: err.requestOptions,
        handler: handler,
      ));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        await tokenStorage.clearTokens();
        return handler.next(err);
      }

      // 새 Dio 인스턴스로 refresh 호출 (인터셉터 무한 루프 방지)
      final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      final responseData = data['data'] as Map<String, dynamic>? ?? data;
      final newAccess = responseData['accessToken'] as String;
      final newRefresh = responseData['refreshToken'] as String;

      await tokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      // 원래 요청 재시도
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
      final retryResponse = await dio.fetch(err.requestOptions);
      handler.resolve(retryResponse);

      // 대기 중이던 요청들도 재시도
      for (final pending in _pendingRequests) {
        pending.options.headers['Authorization'] = 'Bearer $newAccess';
        try {
          final r = await dio.fetch(pending.options);
          pending.handler.resolve(r);
        } on DioException catch (e) {
          pending.handler.reject(e);
        }
      }
    } catch (_) {
      await tokenStorage.clearTokens();
      handler.next(err);
      for (final pending in _pendingRequests) {
        pending.handler.reject(err);
      }
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }
}

class _RetryRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;

  _RetryRequest({required this.options, required this.handler});
}
