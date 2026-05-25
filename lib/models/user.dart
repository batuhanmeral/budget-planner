import '../utils/date_utils.dart';

/// Uygulamanın kullanıcı kaydını temsil eden immutable veri sınıfı.
///
/// SQLite'taki `users` tablosuyla birebir eşleşir. Parolanın kendisi
/// hiçbir zaman saklanmaz; yalnızca [salt] ve [passwordHash] tutulur.
/// Aynı şekilde güvenlik cevabı da [securityAnswerHash] olarak hashlenir.
///
/// `id` insert öncesi null, insert sonrası DB tarafından atanır.
/// `createdAt` ve `lockoutUntil` null olabilir; bu yüzden nullable.
class User {
  /// Birincil anahtar. Yeni kullanıcılarda null, DB'den geldiğinde dolu.
  final int? id;

  /// Kullanıcı adı — case-insensitive. Insert öncesi
  /// `normalizeIdentifier` ile küçük harfe + ASCII'ye çevrilir.
  final String username;

  /// SHA-256(salt + parola) — hex string olarak saklanır.
  final String passwordHash;

  /// Kullanıcıya özel 16 byte (32 hex karakter) rastgele tuz. Aynı
  /// parolayı kullanan iki kullanıcının hash'leri farklı olur.
  final String salt;

  /// Parola kurtarma için seçilen soru ([SecurityQuestions.list]'ten).
  final String securityQuestion;

  /// SHA-256(salt + normalize(cevap)) — cevap da hashlenerek saklanır.
  final String securityAnswerHash;

  /// Ardışık başarısız giriş sayısı. Başarılı girişte sıfırlanır;
  /// 5'i bulduğunda [lockoutUntil] doldurulur.
  final int failedAttempts;

  /// Brute-force koruma kilidinin biteceği UTC zaman.
  /// Null = kilit yok.
  final DateTime? lockoutUntil;

  /// Hesabın oluşturulma zamanı (UTC). Profile ekranında "Üye:" altında
  /// gösterilir.
  final DateTime? createdAt;

  const User({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.salt,
    required this.securityQuestion,
    required this.securityAnswerHash,
    this.failedAttempts = 0,
    this.lockoutUntil,
    this.createdAt,
  });

  /// SQLite insert/update için Map'e dönüştürür.
  ///
  /// `id` null ise haritaya eklenmez — AUTOINCREMENT atansın diye.
  /// Zaman damgaları her zaman UTC ISO-8601 olarak yazılır.
  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'username': username,
    'password_hash': passwordHash,
    'salt': salt,
    'security_question': securityQuestion,
    'security_answer_hash': securityAnswerHash,
    'failed_attempts': failedAttempts,
    'lockout_until': lockoutUntil?.toUtc().toIso8601String(),
    if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
  };

  /// SQLite'tan dönen satırı [User] nesnesine parse eder.
  factory User.fromMap(Map<String, Object?> map) => User(
    id: map['id'] as int?,
    username: map['username'] as String,
    passwordHash: map['password_hash'] as String,
    salt: map['salt'] as String,
    securityQuestion: map['security_question'] as String,
    securityAnswerHash: map['security_answer_hash'] as String,
    failedAttempts: (map['failed_attempts'] as int?) ?? 0,
    lockoutUntil: parseIsoOrNull(map['lockout_until'] as String?),
    createdAt: parseIsoOrNull(map['created_at'] as String?),
  );

  /// Belirli alanları değiştirilmiş bir kopya üretir (immutable update).
  ///
  /// [clearLockout] true verilirse [lockoutUntil] zorla null'a çekilir
  /// — başarılı login sonrası kilidi kaldırmak için kullanılır.
  User copyWith({
    int? id,
    String? username,
    String? passwordHash,
    String? salt,
    String? securityQuestion,
    String? securityAnswerHash,
    int? failedAttempts,
    DateTime? lockoutUntil,
    bool clearLockout = false,
    DateTime? createdAt,
  }) => User(
    id: id ?? this.id,
    username: username ?? this.username,
    passwordHash: passwordHash ?? this.passwordHash,
    salt: salt ?? this.salt,
    securityQuestion: securityQuestion ?? this.securityQuestion,
    securityAnswerHash: securityAnswerHash ?? this.securityAnswerHash,
    failedAttempts: failedAttempts ?? this.failedAttempts,
    lockoutUntil: clearLockout ? null : (lockoutUntil ?? this.lockoutUntil),
    createdAt: createdAt ?? this.createdAt,
  );
}
