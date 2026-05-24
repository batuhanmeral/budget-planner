import '../utils/date_utils.dart';

class User {
  final int? id;
  final String username;
  final String passwordHash;
  final String salt;
  final String securityQuestion;
  final String securityAnswerHash;
  final int failedAttempts;
  final DateTime? lockoutUntil;
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
