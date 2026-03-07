class NicknameValidation {
  final bool valid;
  final String message;
  final String? code;

  const NicknameValidation({
    required this.valid,
    required this.message,
    this.code,
  });
}
