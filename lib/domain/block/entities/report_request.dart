class ReportRequest {
  final int targetUserId;
  final String category;
  final String targetType;
  final String? chatRoomId;
  final String? description;

  const ReportRequest({
    required this.targetUserId,
    required this.category,
    required this.targetType,
    this.chatRoomId,
    this.description,
  });
}
