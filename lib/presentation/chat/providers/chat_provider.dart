import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:itto/domain/chat/entities/chat_message.dart';
import 'package:itto/domain/chat/entities/chat_room.dart';
import 'package:itto/domain/chat/repositories/chat_repository.dart';

/// Spring WS/REST 기반 채팅 상태 관리자.
///
/// 화면 흐름:
///   ChatListScreen: loadChatRooms() 호출 → REST 조회
///   ChatRoomScreen: openRoom(id, currentUserId) 호출 → REST 초기 페이지 + WS 구독
///                  화면 떠날 때 closeRoom() 호출
///
/// 앱 background ↔ foreground 전환 시 WidgetsBindingObserver 로 connect()/disconnect() 호출.
class ChatProvider extends ChangeNotifier with WidgetsBindingObserver {
  final ChatRepository _repository;

  List<ChatRoom> _chatRooms = [];
  List<ChatMessage> _currentMessages = [];
  bool _isLoading = false;
  String? _error;

  int? _activeRoomId;
  int? _currentUserId;
  StreamSubscription<ChatMessage>? _messageSubscription;

  ChatProvider({required ChatRepository repository}) : _repository = repository {
    WidgetsBinding.instance.addObserver(this);
  }

  List<ChatRoom> get chatRooms => _chatRooms;
  List<ChatMessage> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ─── 채팅방 목록 ─────────────────────────────────────────

  /// REST 로 내 채팅방 목록 1회 로드.
  Future<void> loadChatRooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _chatRooms = await _repository.listRooms();
    } catch (e) {
      _error = '채팅 목록을 불러오는데 실패했습니다';
      if (kDebugMode) debugPrint('[ChatProvider] loadChatRooms error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 채팅방 unread 카운트만 갱신 (메시지 수신/읽음 시).
  void _refreshRoomsInBackground() {
    _repository.listRooms().then((rooms) {
      _chatRooms = rooms;
      notifyListeners();
    }).catchError((_) {});
  }

  // ─── 채팅방 진입/이탈 ────────────────────────────────────

  /// 채팅방 화면 진입.
  ///   1) WS 연결 보장
  ///   2) REST 로 최신 페이지 로드 (오름차순으로 정렬)
  ///   3) WS 구독 시작
  ///   4) 읽음 처리
  Future<void> openRoom(int chatRoomId, int currentUserId) async {
    _activeRoomId = chatRoomId;
    _currentUserId = currentUserId;
    _currentMessages = [];
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.connect();
      final messages = await _repository.getMessages(chatRoomId);
      // 백엔드는 createdAt DESC 로 반환 → 화면은 오름차순(과거→현재) 사용
      _currentMessages = messages.reversed.toList();
      _isLoading = false;
      notifyListeners();

      await _messageSubscription?.cancel();
      _messageSubscription = _repository
          .subscribeToRoom(chatRoomId)
          .listen(_onMessageReceived, onError: (e) {
        if (kDebugMode) debugPrint('[ChatProvider] WS stream error: $e');
      });

      // 읽음 처리 (실패해도 화면에는 영향 없음)
      _repository.markAsRead(chatRoomId).then((_) {
        _refreshRoomsInBackground();
      }).catchError((_) {});
    } catch (e) {
      _error = '메시지를 불러오는데 실패했습니다';
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) debugPrint('[ChatProvider] openRoom error: $e');
    }
  }

  void _onMessageReceived(ChatMessage message) {
    _currentMessages = [..._currentMessages, message];
    notifyListeners();

    // 내가 받은 메시지면 즉시 읽음 처리
    final activeRoomId = _activeRoomId;
    final myId = _currentUserId;
    if (activeRoomId != null && myId != null && message.senderId != myId) {
      _repository.markAsRead(activeRoomId).then((_) {
        _refreshRoomsInBackground();
      }).catchError((_) {});
    } else {
      _refreshRoomsInBackground();
    }
  }

  /// 채팅방 화면 이탈.
  Future<void> closeRoom() async {
    final roomId = _activeRoomId;
    await _messageSubscription?.cancel();
    _messageSubscription = null;
    if (roomId != null) {
      await _repository.unsubscribeFromRoom(roomId);
    }
    _activeRoomId = null;
    _currentUserId = null;
    _currentMessages = [];
    // notifyListeners 는 다음 화면 build 직전 호출되므로 생략
  }

  // ─── 메시지 전송 ─────────────────────────────────────────

  Future<bool> sendMessage({
    required int chatRoomId,
    required String text,
  }) async {
    try {
      await _repository.sendMessage(chatRoomId: chatRoomId, content: text);
      return true;
    } catch (e) {
      _error = '메시지 전송에 실패했습니다';
      notifyListeners();
      if (kDebugMode) debugPrint('[ChatProvider] sendMessage error: $e');
      return false;
    }
  }

  Future<bool> sendImageMessage({
    required int chatRoomId,
    required String filePath,
  }) async {
    try {
      final imageUrl = await _repository.uploadImage(
        chatRoomId: chatRoomId,
        filePath: filePath,
      );
      await _repository.sendMessage(chatRoomId: chatRoomId, imageUrl: imageUrl);
      return true;
    } catch (e) {
      _error = '사진 전송에 실패했습니다';
      notifyListeners();
      if (kDebugMode) debugPrint('[ChatProvider] sendImageMessage error: $e');
      return false;
    }
  }

  // ─── 잡다 ────────────────────────────────────────────────

  void clearMessages() {
    _currentMessages = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ─── 앱 라이프사이클 (background/foreground) ──────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _repository.disconnect();
    } else if (state == AppLifecycleState.resumed) {
      // 채팅 화면이 열려있으면 재연결 후 누락 메시지 다시 가져오기
      final roomId = _activeRoomId;
      final userId = _currentUserId;
      if (roomId != null && userId != null) {
        openRoom(roomId, userId);
      } else if (_chatRooms.isNotEmpty) {
        // 채팅 리스트 화면일 때는 목록만 새로고침
        loadChatRooms();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageSubscription?.cancel();
    _repository.disconnect();
    super.dispose();
  }
}
