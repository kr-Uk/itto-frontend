import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService;

  List<ChatRoom> _chatRooms = [];
  List<ChatMessage> _currentMessages = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<ChatRoom>>? _chatRoomsSubscription;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  ChatProvider({required ChatService chatService}) : _chatService = chatService;

  List<ChatRoom> get chatRooms => _chatRooms;
  List<ChatMessage> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void subscribeToChatRooms(int userId, Map<String, String> chatRoomIdToName) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _chatRoomsSubscription?.cancel();
    _chatRoomsSubscription = _chatService
        .getChatRoomsStream(userId, chatRoomIdToName)
        .listen(
          (chatRooms) {
            _chatRooms = chatRooms;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _error = '채팅 목록을 불러오는데 실패했습니다';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  void subscribeToChatMessages(String chatRoomId, int currentUserId) {
    _currentMessages = [];
    _isLoading = true;
    _error = null;
    notifyListeners();

    _messagesSubscription?.cancel();
    _messagesSubscription = _chatService
        .getMessagesStream(chatRoomId)
        .listen(
          (messages) {
            _currentMessages = messages;
            _isLoading = false;
            notifyListeners();

            _chatService.markAsRead(chatRoomId, currentUserId);
          },
          onError: (error) {
            _error = '메시지를 불러오는데 실패했습니다';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<bool> sendMessage({
    required String chatRoomId,
    required int senderId,
    required String text,
    String type = 'text',
  }) async {
    try {
      await _chatService.sendMessage(
        chatRoomId: chatRoomId,
        senderId: senderId,
        text: text,
        type: type,
      );
      return true;
    } catch (e) {
      _error = '메시지 전송에 실패했습니다';
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendImageMessage({
    required String chatRoomId,
    required int senderId,
    required String filePath,
  }) async {
    try {
      final imageUrl = await _chatService.uploadImage(
        chatRoomId: chatRoomId,
        filePath: filePath,
      );
      await _chatService.sendMessage(
        chatRoomId: chatRoomId,
        senderId: senderId,
        text: imageUrl,
        type: 'image',
      );
      return true;
    } catch (e) {
      _error = '사진 전송에 실패했습니다';
      notifyListeners();
      return false;
    }
  }

  Future<void> ensureChatRoomExists({
    required String chatRoomId,
    required List<int> participantIds,
  }) async {
    try {
      await _chatService.ensureChatRoomExists(
        chatRoomId: chatRoomId,
        participantIds: participantIds,
      );
    } catch (e) {
      _error = '채팅방 생성에 실패했습니다';
      notifyListeners();
    }
  }

  void clearMessages() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _currentMessages = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _chatRoomsSubscription?.cancel();
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
