import 'package:itto/domain/system/entities/nickname_validation.dart';

class NicknameValidationModel {
  final bool valid;
  final String message;
  final String? code;

  const NicknameValidationModel({
    required this.valid,
    required this.message,
    this.code,
  });

  factory NicknameValidationModel.fromJson(Map<String, dynamic> json) =>
      NicknameValidationModel(
        valid: json['valid'] as bool? ?? false,
        message: json['message'] as String? ?? '',
        code: json['code'] as String?,
      );

  NicknameValidation toEntity() => NicknameValidation(
        valid: valid,
        message: message,
        code: code,
      );
}
