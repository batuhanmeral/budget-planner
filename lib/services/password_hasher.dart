import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../utils/string_utils.dart';

class PasswordHasher {
  PasswordHasher._();

  static final Random _rng = Random.secure();

  static String generateSalt({int byteLength = 16}) {
    final bytes = List<int>.generate(byteLength, (_) => _rng.nextInt(256));
    return _toHex(bytes);
  }

  static String hash(String password, String salt) {
    final input = utf8.encode('$salt$password');
    return sha256.convert(input).toString();
  }

  static bool verify({
    required String password,
    required String salt,
    required String expectedHash,
  }) {
    return hash(password, salt) == expectedHash;
  }

  /// Güvenlik cevabı için hash — cevap önce [normalizeIdentifier]'dan geçer.
  static String hashAnswer(String answer, String salt) {
    return hash(normalizeIdentifier(answer), salt);
  }

  static bool verifyAnswer({
    required String answer,
    required String salt,
    required String expectedHash,
  }) {
    return hashAnswer(answer, salt) == expectedHash;
  }

  static String _toHex(List<int> bytes) {
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }
}
