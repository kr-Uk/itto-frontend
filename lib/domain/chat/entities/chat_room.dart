class ChatRoom {
  final String id;
  final List<int> participantIds;
  final Map<int, String> participantNames;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ChatRoom({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  String getOtherUserName(int currentUserId) {
    final otherId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );
    return participantNames[otherId] ?? '';
  }

  int getOtherUserId(int currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );
  }
}
