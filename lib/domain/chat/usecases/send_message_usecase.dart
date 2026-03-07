import 'package:itto/domain/chat/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase({required this.repository});

  Future<void> execute({
    required String chatRoomId,
    required int senderId,
    required String text,
    String type = 'text',
  }) =>
      repository.sendMessage(
        chatRoomId: chatRoomId,
        senderId: senderId,
        text: text,
        type: type,
      );
}
