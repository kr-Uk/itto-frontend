/// ==========================================================================
/// [인증 인터셉터 - auth_interceptor.dart]
///
/// 서버와 통신할 때 "로그인 토큰(출입증)"을 자동으로 관리해주는 파일입니다.
///
/// [인터셉터(Interceptor)란?]
/// "중간에 가로채는 것"이라는 뜻입니다.
/// 앱이 서버에 요청을 보낼 때, 그리고 서버에서 응답이 올 때
/// 중간에서 가로채서 추가 작업을 합니다.
///
/// 비유하자면, 건물 출입구의 "경비원" 같은 역할입니다:
/// - 나갈 때(요청): "출입증(토큰)을 붙여서 보내드릴게요"
/// - 들어올 때(응답): "출입증이 만료됐다고요? 새 출입증을 받아올게요"
///
/// [토큰 자동 갱신 흐름]
/// 1. 서버에 요청 보냄 → 401 에러(인증 실패) 응답 받음
/// 2. "혹시 토큰이 만료된 건 아닌가?" → refresh token으로 새 토큰 발급 요청
/// 3. 새 토큰 받으면 기기에 저장하고, 실패했던 원래 요청을 새 토큰으로 다시 시도
/// 4. 만약 refresh token도 만료되었으면 → 토큰 삭제 → 재로그인 필요
/// ==========================================================================

import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio; // HTTP 통신 객체
  final TokenStorage tokenStorage; // 토큰(출입증)을 저장/조회하는 저장소
  bool _isRefreshing = false; // 현재 토큰 갱신 중인지 (중복 갱신 방지용 플래그)
  final List<_RetryRequest> _pendingRequests = []; // 토큰 갱신 중 대기하는 요청들의 목록

  /// 인증(토큰)이 필요 없는 공개 API 경로 목록
  /// 이 경로들은 로그인 없이도 사용 가능하므로 토큰을 붙이지 않습니다
  static const _publicPaths = [
    '/auth/login', // 로그인
    '/auth/refresh', // 토큰 갱신
    '/system/version', // 앱 버전 확인
    '/hobbies', // 취미 목록 조회
    '/nickname/validate', // 닉네임 중복 확인
  ];

  AuthInterceptor({required this.dio, required this.tokenStorage});

  /// [요청 가로채기] - 서버로 요청을 보내기 직전에 실행됩니다
  /// 공개 API가 아닌 경우, 저장된 토큰(출입증)을 요청 헤더에 자동으로 붙여줍니다
  /// ('Bearer 토큰값' 형태로 Authorization 헤더에 추가)
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 공개 API(로그인, 토큰 갱신 등)는 토큰 부착 생략
    final isPublic = _publicPaths.any((p) => options.path.contains(p));
    if (!isPublic) {
      final token = await tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  /// [에러 가로채기] - 서버에서 에러 응답이 왔을 때 실행됩니다
  /// 특히 401(인증 실패) 에러가 오면 토큰을 자동으로 갱신하고 다시 시도합니다
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    /// 401(인증 실패)이 아닌 다른 에러는 그냥 통과시킵니다
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    /// 토큰 갱신 요청 자체가 401이면 = refresh token도 만료됨 → 재로그인 필요
    if (err.requestOptions.path.contains('/auth/refresh')) {
      await tokenStorage.clearTokens();
      return handler.next(err);
    }

    /// 이미 다른 요청에서 토큰 갱신 중이면, 이 요청은 대기열에 넣고 기다립니다
    /// (동시에 여러 요청이 401을 받으면, 한 번만 갱신하고 나머지는 대기)
    if (_isRefreshing) {
      _pendingRequests.add(
        _RetryRequest(options: err.requestOptions, handler: handler),
      );
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        await tokenStorage.clearTokens();
        return handler.next(err);
      }

      /// 새로운 Dio 객체로 토큰 갱신 요청을 보냅니다
      /// (기존 Dio를 쓰면 이 인터셉터가 또 작동해서 무한 루프에 빠지므로, 별도 객체 사용)
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

/// 토큰 갱신 중 대기하는 요청을 저장하는 클래스
/// (어떤 요청이었는지, 그리고 그 요청의 결과를 어디로 돌려줘야 하는지를 기억)
class _RetryRequest {
  final RequestOptions options; // 원래 보내려던 요청 정보
  final ErrorInterceptorHandler handler; // 요청 결과를 돌려줄 핸들러

  _RetryRequest({required this.options, required this.handler});
}
