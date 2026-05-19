import 'package:itto/data/chat/datasources/chat_remote_datasource.dart';
import 'package:itto/data/chat/datasources/chat_websocket_datasource.dart';
import 'package:itto/domain/chat/entities/chat_message.dart';
import 'package:itto/domain/chat/entities/chat_room.dart';
import 'package:itto/domain/chat/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remote;
  final ChatWebSocketDataSource _webSocket;

  ChatRepositoryImpl({
    required ChatRemoteDataSource remoteDataSource,
    required ChatWebSocketDataSource webSocketDataSource,
  })  : _remote = remoteDataSource,
        _webSocket = webSocketDataSource;

  @override
  Future<List<ChatRoom>> listRooms() async {
    final models = await _remote.listRooms();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ChatMessage>> getMessages(
    int chatRoomId, {
    int page = 0,
    int size = 30,
  }) async {
    final models = await _remote.getMessages(
      chatRoomId,
      page: page,
      size: size,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> connect() => _webSocket.connect();

  @override
  Future<void> disconnect() => _webSocket.disconnect();

  @override
  Stream<ChatMessage> subscribeToRoom(int chatRoomId) {
    return _webSocket
        .subscribeToRoom(chatRoomId)
        .map((model) => model.toEntity());
  }

  @override
  Future<void> unsubscribeFromRoom(int chatRoomId) {
    return _webSocket.unsubscribeFromRoom(chatRoomId);
  }

  @override
  Future<void> sendMessage({
    required int chatRoomId,
    String? content,
    String? imageUrl,
  }) {
    return _webSocket.sendMessage(
      chatRoomId: chatRoomId,
      content: content,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<int> markAsRead(int chatRoomId) => _remote.markAsRead(chatRoomId);

  @override
  Future<String> uploadImage({
    required int chatRoomId,
    required String filePath,
  }) =>
      _remote.uploadImage(chatRoomId: chatRoomId, filePath: filePath);
}
