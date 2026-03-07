import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:itto/domain/contact_hash/usecases/phone_number_normalizer.dart';

class HashContactsUseCase {
  List<String> execute(List<String> phoneNumbers) {
    return phoneNumbers.map((number) {
      final normalized = PhoneNumberNormalizer.normalize(number);
      final bytes = utf8.encode(normalized);
      final digest = sha256.convert(bytes);
      return digest.toString();
    }).toList();
  }
}
