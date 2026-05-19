import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:itto/core/config/app_config.dart';
import 'package:itto/core/storage/token_storage.dart';
import 'package:itto/data/chat/models/chat_message_model.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

/// 백엔드 STOMP-over-WebSocket 채팅 datasource.
///
/// 엔드포인트: `${WS_BASE_URL}/ws`  (예: wss://itto.hguitto.site/ws)
/// CONNECT 헤더: `Authorization: Bearer <accessToken>`
/// 구독: `/topic/chat-rooms/{chatRoomId}` → ChatMessageResponse JSON
/// 발행: `/app/chat.send` with body `{ chatRoomId, content?, imageUrl? }`
class ChatWebSocketDataSource {
  final TokenStorage _tokenStorage;
  StompClient? _client;

  /// 채팅방별 broadcast stream — 한 채팅방에 여러 리스너가 붙어도 안전.
  final Map<int, StreamController<ChatMessageModel>> _roomControllers = {};

  /// 채팅방별 STOMP unsubscribe 콜백.
  /// stomp_dart_client 2.x 의 subscribe() 반환 타입은
  ///   `void Function({Map<String, String>? unsubscribeHeaders})`
  /// 이지만, 함수 시그니처 매칭 이슈를 피해 Function 으로 저장한다.
  final Map<int, Function> _subscriptions = {};

  bool _isConnected = false;
  Completer<void>? _connectCompleter;

  ChatWebSocketDataSource({required TokenStorage tokenStorage})
      : _tokenStorage = tokenStorage;

  bool get isConnected => _isConnected;

  /// API base URL 에서 WS URL 을 유도한다.
  ///   https://itto.hguitto.site/api/v1  →  wss://itto.hguitto.site/ws
  ///   http://localhost:8080/api/v1     →  ws://localhost:8080/ws
  String _deriveWsUrl(String apiBaseUrl) {
    final uri = Uri.parse(apiBaseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final host = uri.host;
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '$scheme://$host$port/ws';
  }

  /// WS 연결. 이미 연결 중이면 동일 Future 를 반환한다.
  Future<void> connect() async {
    if (_isConnected) return;
    if (_connectCompleter != null) return _connectCompleter!.future;

    _connectCompleter = Completer<void>();

    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      _connectCompleter!.completeError(
        StateError('access token 이 없습니다. 로그인 후 다시 시도해주세요.'),
      );
      final f = _connectCompleter!.future;
      _connectCompleter = null;
      return f;
    }

    final wsUrl = _deriveWsUrl(AppConfig.baseUrl);

    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        stompConnectHeaders: {'Authorization': 'Bearer $accessToken'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $accessToken'},
        onConnect: (frame) {
          _isConnected = true;
          _connectCompleter?.complete();
          _connectCompleter = null;
          if (kDebugMode) {
            debugPrint('[ChatWS] connected to $wsUrl');
          }
          // 재연결 시 기존 구독 복원
          for (final roomId in _roomControllers.keys.toList()) {
            _subscribeInternal(roomId);
          }
        },
        onWebSocketError: (error) {
          if (kDebugMode) {
            debugPrint('[ChatWS] error: $error');
          }
          if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
            _connectCompleter!.completeError(error);
            _connectCompleter = null;
          }
        },
        onStompError: (frame) {
          if (kDebugMode) {
            debugPrint('[ChatWS] stomp error: ${frame.headers} / ${frame.body}');
          }
        },
        onDisconnect: (_) {
          _isConnected = false;
          if (kDebugMode) {
            debugPrint('[ChatWS] disconnected');
          }
        },
        reconnectDelay: const Duration(seconds: 3),
      ),
    );

    _client!.activate();
    return _connectCompleter!.future;
  }

  /// 모든 구독 정리 후 WS 종료.
  Future<void> disconnect() async {
    for (final entry in _subscriptions.entries) {
      try {
        Function.apply(entry.value, [], {const Symbol('unsubscribeHeaders'): null});
      } catch (_) {}
    }
    _subscriptions.clear();
    for (final c in _roomControllers.values) {
      await c.close();
    }
    _roomControllers.clear();
    _client?.deactivate();
    _client = null;
    _isConnected = false;
  }

  /// 특정 채팅방 메시지 stream 구독.
  /// 같은 채팅방을 여러 번 호출해도 동일 broadcast stream 을 반환한다.
  Stream<ChatMessageModel> subscribeToRoom(int chatRoomId) {
    final controller = _roomControllers.putIfAbsent(
      chatRoomId,
      () => StreamController<ChatMessageModel>.broadcast(
        onCancel: () {
          // 리스너 0 명이 되어도 구독은 유지 (Provider 가 channel 단위 재사용)
        },
      ),
    );

    if (_isConnected && !_subscriptions.containsKey(chatRoomId)) {
      _subscribeInternal(chatRoomId);
    }

    return controller.stream;
  }

  void _subscribeInternal(int chatRoomId) {
    final client = _client;
    if (client == null) return;

    final unsubscribe = client.subscribe(
      destination: '/topic/chat-rooms/$chatRoomId',
      callback: (frame) {
        final body = frame.body;
        if (body == null) return;
        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          final model = ChatMessageModel.fromJson(json);
          _roomControllers[chatRoomId]?.add(model);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[ChatWS] parse error: $e / body=$body');
          }
        }
      },
    );
    _subscriptions[chatRoomId] = unsubscribe;
  }

  /// 특정 채팅방 구독 해제.
  Future<void> unsubscribeFromRoom(int chatRoomId) async {
    final unsubscribe = _subscriptions.remove(chatRoomId);
    if (unsubscribe != null) {
      try {
        Function.apply(unsubscribe, [], {const Symbol('unsubscribeHeaders'): null});
      } catch (_) {}
    }
    final controller = _roomControllers.remove(chatRoomId);
    await controller?.close();
  }

  /// /app/chat.send 로 메시지 발행. content 또는 imageUrl 중 하나 필수.
  Future<void> sendMessage({
    required int chatRoomId,
    String? content,
    String? imageUrl,
  }) async {
    if (!_isConnected || _client == null) {
      throw StateError('WebSocket 이 연결되어 있지 않습니다');
    }
    final payload = <String, dynamic>{'chatRoomId': chatRoomId};
    if (content != null) payload['content'] = content;
    if (imageUrl != null) payload['imageUrl'] = imageUrl;

    _client!.send(
      destination: '/app/chat.send',
      body: jsonEncode(payload),
    );
  }
}
