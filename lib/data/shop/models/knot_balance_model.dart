import 'package:itto/domain/shop/entities/knot_balance.dart';

class KnotBalanceModel {
  final int knots;
  final int freeConvertRemaining;
  final int freeRequestRemaining;
  final int freeRestoreRemaining;

  const KnotBalanceModel({
    required this.knots,
    required this.freeConvertRemaining,
    required this.freeRequestRemaining,
    required this.freeRestoreRemaining,
  });

  factory KnotBalanceModel.fromJson(Map<String, dynamic> json) =>
      KnotBalanceModel(
        knots: json['knots'] as int? ?? 0,
        freeConvertRemaining: json['freeConvertRemaining'] as int? ?? 0,
        freeRequestRemaining: json['freeRequestRemaining'] as int? ?? 0,
        freeRestoreRemaining: json['freeRestoreRemaining'] as int? ?? 0,
      );

  KnotBalance toEntity() => KnotBalance(
        knots: knots,
        freeConvertRemaining: freeConvertRemaining,
        freeRequestRemaining: freeRequestRemaining,
        freeRestoreRemaining: freeRestoreRemaining,
      );
}
