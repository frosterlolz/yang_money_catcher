import 'dart:convert';
import 'package:crypto/crypto.dart';

class PinHasher {
  const PinHasher();

  /// Возвращает SHA-256 хеш в виде строки
  String hashPin(int pinCode) {
    final bytes = utf8.encode(pinCode.toString());
    return sha256.convert(bytes).toString();
  }

  /// Проверяет, что PIN совпадает с хешем
  bool verify(int pinCode, String hashed) => hashPin(pinCode) == hashed;
}
