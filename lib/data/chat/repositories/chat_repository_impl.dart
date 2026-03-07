import 'package:itto/domain/chat/entities/chat_message.dart';
import 'package:itto/domain/chat/entities/chat_room.dart';
import 'package:itto/domain/chat/repositories/chat_repository.dart';
import 'package:itto/data/chat/datasources/chat_firestore_datasource.dart';
import 'package:itto/data/chat/models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatFirestoreDataSource dataSource;

  ChatRepositoryImpl({required this.dataSource});

  @override
  Stream<List<ChatRoom>> getChatRoomsStream(
    int userId,
    Map<String, String> chatRoomIdToName,
  ) {
    return dataSource
        .getChatRoomsStream(userId, chatRoomIdToName)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<ChatMessage>> getMessagesStream(String chatRoomId) {
    return dataSource
        .getMessagesStream(chatRoomId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<void> sendMessage({
    required String chatRoomId,
    required int senderId,
    required String text,
    String type = 'text',
  }) {
    final message = ChatMessageModel(
      id: '',
      senderId: senderId,
      text: text,
      type: type,
      createdAt: DateTime.now(),
      readBy: [senderId],
    );
    return dataSource.sendMessage(message, chatRoomId);
  }

  @override
  Future<void> markAsRead(String chatRoomId, int userId) =>
      dataSource.markAsRead(chatRoomId, userId);

  @override
  Future<String> uploadImage({
    required String chatRoomId,
    required String filePath,
  }) =>
      dataSource.uploadImage(chatRoomId: chatRoomId, filePath: filePath);

  @override
  Future<void> ensureChatRoomExists({
    required String chatRoomId,
    required List<int> participantIds,
  }) =>
      dataSource.ensureChatRoomExists(
        chatRoomId: chatRoomId,
        participantIds: participantIds,
      );
}
