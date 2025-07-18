import 'dart:convert';
import 'package:crypto/crypto.dart';

class PinHasher {
  const PinHasher();

  /// Возвращает SHA-256 хеш в виде строки
  String hashPin(String pinCode) {
    final bytes = utf8.encode(pinCode);
    return sha256.convert(bytes).toString();
  }

  /// Проверяет, что PIN совпадает с хешем
  bool verify(String pinCode, String hashed) => hashPin(pinCode) == hashed;
}
