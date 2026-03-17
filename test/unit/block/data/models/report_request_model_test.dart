import 'package:flutter_test/flutter_test.dart';
import 'package:itto/data/block/models/report_request_model.dart';
import 'package:itto/domain/block/entities/report_request.dart';

void main() {
  group('ReportRequestModel', () {
    test('fromEntity creates model with all fields', () {
      const entity = ReportRequest(
        targetUserId: 42,
        category: 'SPAM',
        targetType: 'USER',
        chatRoomId: 'room-123',
        description: '스팸 메시지 발송',
      );

      final model = ReportRequestModel.fromEntity(entity);

      expect(model.targetUserId, equals(42));
      expect(model.category, equals('SPAM'));
      expect(model.targetType, equals('USER'));
      expect(model.chatRoomId, equals('room-123'));
      expect(model.description, equals('스팸 메시지 발송'));
    });

    test('fromEntity handles null optional fields', () {
      const entity = ReportRequest(
        targetUserId: 10,
        category: 'HARASSMENT',
        targetType: 'PROFILE',
      );

      final model = ReportRequestModel.fromEntity(entity);

      expect(model.chatRoomId, isNull);
      expect(model.description, isNull);
    });

    test('toJson includes all required fields', () {
      const model = ReportRequestModel(
        targetUserId: 42,
        category: 'SPAM',
        targetType: 'USER',
        chatRoomId: 'room-123',
        description: '설명',
      );

      final json = model.toJson();

      expect(json['targetUserId'], equals(42));
      expect(json['category'], equals('SPAM'));
      expect(json['targetType'], equals('USER'));
      expect(json['chatRoomId'], equals('room-123'));
      expect(json['description'], equals('설명'));
    });

    test('toJson excludes null optional fields', () {
      const model = ReportRequestModel(
        targetUserId: 10,
        category: 'HARASSMENT',
        targetType: 'PROFILE',
      );

      final json = model.toJson();

      expect(json.containsKey('chatRoomId'), isFalse);
      expect(json.containsKey('description'), isFalse);
    });
  });
}
