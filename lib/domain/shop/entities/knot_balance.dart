class KnotBalance {
  final int knots;
  final int freeConvertRemaining;
  final int freeRequestRemaining;
  final int freeRestoreRemaining;

  const KnotBalance({
    required this.knots,
    required this.freeConvertRemaining,
    required this.freeRequestRemaining,
    required this.freeRestoreRemaining,
  });
}
