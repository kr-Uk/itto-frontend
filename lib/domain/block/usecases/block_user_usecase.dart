import 'package:itto/domain/block/repositories/block_repository.dart';

class BlockUserUseCase {
  final BlockRepository repository;

  BlockUserUseCase({required this.repository});

  Future<void> execute(int targetUserId) =>
      repository.blockUser(targetUserId);
}
