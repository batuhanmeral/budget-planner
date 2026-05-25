import 'package:shared_preferences/shared_preferences.dart';

import '../app/app_constants.dart';
import '../models/user.dart';
import 'password_hasher.dart';
import 'user_repository.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  static const _maxFailedAttempts = 5;
  static const _lockoutDuration = Duration(seconds: 30);

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<User?> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(PrefsKeys.lastUserId);
    if (id == null) return null;
    final user = await UserRepository.instance.findById(id);
    if (user == null) {
      await prefs.remove(PrefsKeys.lastUserId);
      return null;
    }
    _currentUser = user;
    return user;
  }

  Future<User> register({
    required String username,
    required String password,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    final existing = await UserRepository.instance.findByUsername(username);
    if (existing != null) {
      throw AuthException('Bu kullanıcı adı zaten kullanılıyor');
    }
    final salt = PasswordHasher.generateSalt();
    final passwordHash = PasswordHasher.hash(password, salt);
    final answerHash = PasswordHasher.hashAnswer(securityAnswer, salt);

    final draft = User(
      username: username,
      passwordHash: passwordHash,
      salt: salt,
      securityQuestion: securityQuestion,
      securityAnswerHash: answerHash,
    );
    final id = await UserRepository.instance.insert(draft);
    final saved = await UserRepository.instance.findById(id);
    if (saved == null) {
      throw AuthException('Kayıt sırasında bir hata oluştu');
    }
    _currentUser = saved;
    await _persistSession(id);
    return saved;
  }

  Future<User> login({
    required String username,
    required String password,
  }) async {
    final user = await UserRepository.instance.findByUsername(username);
    if (user == null) {
      throw AuthException('Kullanıcı adı veya parola hatalı');
    }
    final now = DateTime.now().toUtc();
    if (user.lockoutUntil != null && now.isBefore(user.lockoutUntil!.toUtc())) {
      final remaining = user.lockoutUntil!.toUtc().difference(now).inSeconds;
      throw AuthException(
        'Çok fazla başarısız deneme. $remaining saniye sonra tekrar deneyin.',
      );
    }

    final ok = PasswordHasher.verify(
      password: password,
      salt: user.salt,
      expectedHash: user.passwordHash,
    );
    if (!ok) {
      final attempts = user.failedAttempts + 1;
      if (attempts >= _maxFailedAttempts) {
        await UserRepository.instance.updateFailedAttempts(user.id!, attempts);
        await UserRepository.instance.updateLockout(
          user.id!,
          now.add(_lockoutDuration),
        );
      } else {
        await UserRepository.instance.updateFailedAttempts(user.id!, attempts);
      }
      throw AuthException('Kullanıcı adı veya parola hatalı');
    }

    await UserRepository.instance.resetFailedState(user.id!);
    final fresh = await UserRepository.instance.findById(user.id!);
    _currentUser = fresh;
    await _persistSession(user.id!);
    return fresh!;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefsKeys.lastUserId);
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = _currentUser;
    if (user == null) throw AuthException('Oturum açık değil');
    final ok = PasswordHasher.verify(
      password: oldPassword,
      salt: user.salt,
      expectedHash: user.passwordHash,
    );
    if (!ok) throw AuthException('Mevcut parola hatalı');

    final newSalt = PasswordHasher.generateSalt();
    final newHash = PasswordHasher.hash(newPassword, newSalt);
    await UserRepository.instance.updatePassword(
      userId: user.id!,
      passwordHash: newHash,
      salt: newSalt,
    );
    _currentUser = user.copyWith(passwordHash: newHash, salt: newSalt);
  }

  /// Hesap silme akışındaki parola doğrulaması `failed_attempts` sayacını
  /// etkilemez — login akışından ayrı bir code path'tir.
  Future<void> deleteAccount(String password) async {
    final user = _currentUser;
    if (user == null) throw AuthException('Oturum açık değil');
    final ok = PasswordHasher.verify(
      password: password,
      salt: user.salt,
      expectedHash: user.passwordHash,
    );
    if (!ok) throw AuthException('Parola hatalı');

    await UserRepository.instance.delete(user.id!);
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefsKeys.lastUserId);
  }

  Future<String> getSecurityQuestion(String username) async {
    final user = await UserRepository.instance.findByUsername(username);
    if (user == null) {
      throw AuthException('Kullanıcı adı veya cevap hatalı');
    }
    return user.securityQuestion;
  }

  Future<void> resetPasswordViaSecurityAnswer({
    required String username,
    required String answer,
    required String newPassword,
  }) async {
    final user = await UserRepository.instance.findByUsername(username);
    if (user == null) {
      throw AuthException('Kullanıcı adı veya cevap hatalı');
    }
    final ok = PasswordHasher.verifyAnswer(
      answer: answer,
      salt: user.salt,
      expectedHash: user.securityAnswerHash,
    );
    if (!ok) {
      throw AuthException('Kullanıcı adı veya cevap hatalı');
    }
    final newSalt = PasswordHasher.generateSalt();
    final newHash = PasswordHasher.hash(newPassword, newSalt);
    await UserRepository.instance.updatePassword(
      userId: user.id!,
      passwordHash: newHash,
      salt: newSalt,
    );
    await UserRepository.instance.resetFailedState(user.id!);
  }

  Future<void> _persistSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.lastUserId, userId);
  }
}
