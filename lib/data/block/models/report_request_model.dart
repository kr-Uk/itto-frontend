import 'package:itto/domain/block/entities/report_request.dart';

class ReportRequestModel {
  final int targetUserId;
  final String category;
  final String targetType;
  final String? chatRoomId;
  final String? description;

  const ReportRequestModel({
    required this.targetUserId,
    required this.category,
    required this.targetType,
    this.chatRoomId,
    this.description,
  });

  factory ReportRequestModel.fromEntity(ReportRequest entity) =>
      ReportRequestModel(
        targetUserId: entity.targetUserId,
        category: entity.category,
        targetType: entity.targetType,
        chatRoomId: entity.chatRoomId,
        description: entity.description,
      );

  Map<String, dynamic> toJson() => {
        'targetUserId': targetUserId,
        'category': category,
        'targetType': targetType,
        if (chatRoomId != null) 'chatRoomId': chatRoomId,
        if (description != null) 'description': description,
      };
}
