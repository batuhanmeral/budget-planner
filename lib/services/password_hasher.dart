import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../utils/string_utils.dart';

/// Parola ve güvenlik cevabı hash'leme servisi.
///
/// Şema: **SHA-256(salt + parola)** — hex string olarak saklanır.
/// Her kullanıcının kendi salt'ı vardır; bu sayede aynı parolayı seçen
/// iki kullanıcının hash'leri farklı olur (rainbow table saldırılarına
/// dayanıklılık).
///
/// **Not:** Üretim uygulamasında SHA-256 yerine bcrypt/argon2 gibi
/// yavaş, brute-force'a dirençli algoritmalar tercih edilir. Ders projesi
/// kapsamında müfredat dahilindeki `crypto` paketi yeterli görülmüştür.
class PasswordHasher {
  PasswordHasher._();

  /// Kriptografik güvenli rastgele sayı üreteci. `Random.secure()`
  /// platformun OS-level RNG'sini kullanır.
  static final Random _rng = Random.secure();

  /// Yeni bir tuz üretir. Varsayılan 16 byte = 32 hex karakter.
  ///
  /// Salt her register/changePassword/resetPassword'da yeniden üretilir.
  /// Eski salt'ı tekrar kullanmak güvenlik açısından sakıncalıdır.
  static String generateSalt({int byteLength = 16}) {
    final bytes = List<int>.generate(byteLength, (_) => _rng.nextInt(256));
    return _toHex(bytes);
  }

  /// Verilen parola + salt için SHA-256 hash hex string'ini döner.
  ///
  /// Salt önce eklenir (`salt + parola`); sıralama önemli — hem hash
  /// hem verify aynı sırayı kullanmak zorunda.
  static String hash(String password, String salt) {
    final input = utf8.encode('$salt$password');
    return sha256.convert(input).toString();
  }

  /// Kullanıcının girdiği parolanın kayıtlı hash ile eşleşip eşleşmediğini
  /// kontrol eder.
  static bool verify({
    required String password,
    required String salt,
    required String expectedHash,
  }) {
    return hash(password, salt) == expectedHash;
  }

  /// Güvenlik sorusu cevabını hash'ler.
  ///
  /// Cevap önce [normalizeIdentifier] ile normalize edilir; bu sayede
  /// kayıtta "İSTANBUL" yazan kullanıcı, sıfırlamada "istanbul" yazsa
  /// bile eşleşme yakalanır.
  static String hashAnswer(String answer, String salt) {
    return hash(normalizeIdentifier(answer), salt);
  }

  /// Cevap doğrulaması — [hashAnswer] sonucunu beklenen hash ile karşılaştırır.
  static bool verifyAnswer({
    required String answer,
    required String salt,
    required String expectedHash,
  }) {
    return hashAnswer(answer, salt) == expectedHash;
  }

  /// Byte listesini hex string'e çevirir (örn. `[15, 255]` → `'0fff'`).
  /// Her byte tek hane gelirse başına 0 eklenir.
  static String _toHex(List<int> bytes) {
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }
}
