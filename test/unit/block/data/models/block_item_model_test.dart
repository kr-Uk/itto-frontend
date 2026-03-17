import 'package:flutter_test/flutter_test.dart';
import 'package:itto/data/block/models/block_item_model.dart';
import 'package:itto/domain/block/entities/block_item.dart';

void main() {
  group('BlockItemModel', () {
    test('fromJson creates model with all fields', () {
      final json = {
        'id': 1,
        'blockedUser': {'userId': 42, 'nickname': '테스트유저'},
        'createdAt': '2026-03-17T10:00:00',
      };

      final model = BlockItemModel.fromJson(json);

      expect(model.id, equals(1));
      expect(model.blockedUser.userId, equals(42));
      expect(model.blockedUser.nickname, equals('테스트유저'));
      expect(model.createdAt, equals('2026-03-17T10:00:00'));
    });

    test('fromJson handles missing createdAt with empty string', () {
      final json = {
        'id': 2,
        'blockedUser': {'userId': 10, 'nickname': 'user'},
      };

      final model = BlockItemModel.fromJson(json);

      expect(model.createdAt, equals(''));
    });

    test('toEntity returns correct BlockItem', () {
      const model = BlockItemModel(
        id: 1,
        blockedUser: BlockedUserModel(userId: 42, nickname: '테스트'),
        createdAt: '2026-03-17',
      );

      final entity = model.toEntity();

      expect(entity, isA<BlockItem>());
      expect(entity.id, equals(1));
      expect(entity.blockedUser.userId, equals(42));
      expect(entity.blockedUser.nickname, equals('테스트'));
      expect(entity.createdAt, equals('2026-03-17'));
    });
  });

  group('BlockedUserModel', () {
    test('fromJson creates model correctly', () {
      final json = {'userId': 99, 'nickname': '닉네임'};

      final model = BlockedUserModel.fromJson(json);

      expect(model.userId, equals(99));
      expect(model.nickname, equals('닉네임'));
    });

    test('toEntity returns correct BlockedUser', () {
      const model = BlockedUserModel(userId: 5, nickname: '유저');

      final entity = model.toEntity();

      expect(entity, isA<BlockedUser>());
      expect(entity.userId, equals(5));
      expect(entity.nickname, equals('유저'));
    });
  });
}
