class PhoneNumberNormalizer {
  static String normalize(String phoneNumber) {
    if (phoneNumber.trim().isEmpty) {
      throw ArgumentError('전화번호는 빈 문자열일 수 없습니다');
    }

    String cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-()]'), '');

    if (cleaned.startsWith('+82')) {
      cleaned = '0${cleaned.substring(3)}';
    }

    if (cleaned.startsWith('0')) {
      cleaned = '+82${cleaned.substring(1)}';
    }

    if (!RegExp(r'^\+82\d{9,10}$').hasMatch(cleaned)) {
      throw ArgumentError('잘못된 전화번호 형식입니다: $phoneNumber');
    }

    return cleaned;
  }
}
