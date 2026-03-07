import 'package:itto/domain/chat/entities/chat_message.dart';
import 'package:itto/domain/chat/entities/chat_room.dart';

abstract class ChatRepository {
  Stream<List<ChatRoom>> getChatRoomsStream(
    int userId,
    Map<String, String> chatRoomIdToName,
  );
  Stream<List<ChatMessage>> getMessagesStream(String chatRoomId);
  Future<void> sendMessage({
    required String chatRoomId,
    required int senderId,
    required String text,
    String type = 'text',
  });
  Future<void> markAsRead(String chatRoomId, int userId);
  Future<String> uploadImage({
    required String chatRoomId,
    required String filePath,
  });
  Future<void> ensureChatRoomExists({
    required String chatRoomId,
    required List<int> participantIds,
  });
}
