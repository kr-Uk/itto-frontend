import 'package:itto/domain/chat/entities/chat_room.dart';
import 'package:itto/domain/chat/repositories/chat_repository.dart';

class GetChatRoomsUseCase {
  final ChatRepository repository;

  GetChatRoomsUseCase({required this.repository});

  Stream<List<ChatRoom>> execute(
    int userId,
    Map<String, String> chatRoomIdToName,
  ) =>
      repository.getChatRoomsStream(userId, chatRoomIdToName);
}
