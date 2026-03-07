class BlockItem {
  final int id;
  final BlockedUser blockedUser;
  final String createdAt;

  const BlockItem({
    required this.id,
    required this.blockedUser,
    required this.createdAt,
  });
}

class BlockedUser {
  final int userId;
  final String nickname;

  const BlockedUser({required this.userId, required this.nickname});
}
