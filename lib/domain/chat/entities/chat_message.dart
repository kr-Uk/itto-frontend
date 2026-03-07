class ChatMessage {
  final String id;
  final int senderId;
  final String text;
  final String type;
  final DateTime createdAt;
  final List<int> readBy;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.type = 'text',
    required this.createdAt,
    this.readBy = const [],
  });

  bool isReadBy(int userId) => readBy.contains(userId);
}
