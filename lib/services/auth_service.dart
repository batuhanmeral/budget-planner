import 'package:shared_preferences/shared_preferences.dart';

import '../app/app_constants.dart';
import '../app/locale_controller.dart';
import '../l10n/app_l10n.dart';
import '../models/user.dart';
import 'category_service.dart';
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

  static String _msg(String Function(AppL10n l10n) f) =>
      f(LocaleController.instance.l10n);

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
    await CategoryService.instance.loadForUser(user.id!);
    return user;
  }

  Future<User> register({
    required String username,
    required String password,
    required String securityQuestion,
    required String securityAnswer,
    String? fullName,
  }) async {
    final existing = await UserRepository.instance.findByUsername(username);
    if (existing != null) {
      throw AuthException(_msg((l) => l.errUsernameTaken));
    }
    final salt = PasswordHasher.generateSalt();
    final passwordHash = PasswordHasher.hash(password, salt);
    final answerHash = PasswordHasher.hashAnswer(securityAnswer, salt);

    final trimmedName = fullName?.trim();
    final draft = User(
      username: username,
      fullName: (trimmedName == null || trimmedName.isEmpty) ? null : trimmedName,
      passwordHash: passwordHash,
      salt: salt,
      securityQuestion: securityQuestion,
      securityAnswerHash: answerHash,
    );
    final id = await UserRepository.instance.insert(draft);
    final saved = await UserRepository.instance.findById(id);
    if (saved == null) {
      throw AuthException(_msg((l) => l.unexpectedError));
    }
    _currentUser = saved;
    await _persistSession(id);
    await CategoryService.instance.loadForUser(saved.id!);
    return saved;
  }

  Future<User> login({
    required String username,
    required String password,
  }) async {
    final user = await UserRepository.instance.findByUsername(username);
    if (user == null) {
      throw AuthException(_msg((l) => l.errBadCredentials));
    }
    final now = DateTime.now().toUtc();
    if (user.lockoutUntil != null && now.isBefore(user.lockoutUntil!.toUtc())) {
      final remaining = user.lockoutUntil!.toUtc().difference(now).inSeconds;
      throw AuthException(_msg((l) => l.errLockedOut(remaining)));
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
      throw AuthException(_msg((l) => l.errBadCredentials));
    }

    await UserRepository.instance.resetFailedState(user.id!);
    final fresh = await UserRepository.instance.findById(user.id!);
    _currentUser = fresh;
    await _persistSession(user.id!);
    await CategoryService.instance.loadForUser(user.id!);
    return fresh!;
  }

  Future<void> logout() async {
    _currentUser = null;
    CategoryService.instance.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefsKeys.lastUserId);
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = _currentUser;
    if (user == null) throw AuthException(_msg((l) => l.errSessionInactive));
    final ok = PasswordHasher.verify(
      password: oldPassword,
      salt: user.salt,
      expectedHash: user.passwordHash,
    );
    if (!ok) throw AuthException(_msg((l) => l.errOldPasswordWrong));

    final newSalt = PasswordHasher.generateSalt();
    final newHash = PasswordHasher.hash(newPassword, newSalt);
    await UserRepository.instance.updatePassword(
      userId: user.id!,
      passwordHash: newHash,
      salt: newSalt,
    );
    _currentUser = user.copyWith(passwordHash: newHash, salt: newSalt);
  }

  Future<void> changeUsername(String newUsername) async {
    final user = _currentUser;
    if (user == null) throw AuthException(_msg((l) => l.errSessionInactive));
    final trimmed = newUsername.trim();
    final existing = await UserRepository.instance.findByUsername(trimmed);
    if (existing != null && existing.id != user.id) {
      throw AuthException(_msg((l) => l.errUsernameTaken));
    }
    await UserRepository.instance.updateUsername(
      userId: user.id!,
      username: trimmed,
    );
    final fresh = await UserRepository.instance.findById(user.id!);
    if (fresh != null) _currentUser = fresh;
  }

  Future<void> updateAvatar(String? avatarPath) async {
    final user = _currentUser;
    if (user == null) throw AuthException(_msg((l) => l.errSessionInactive));
    await UserRepository.instance.updateAvatarPath(
      userId: user.id!,
      avatarPath: avatarPath,
    );
    _currentUser = user.copyWith(
      avatarPath: avatarPath,
      clearAvatar: avatarPath == null,
    );
  }

  Future<void> updateFullName(String? fullName) async {
    final user = _currentUser;
    if (user == null) throw AuthException(_msg((l) => l.errSessionInactive));
    await UserRepository.instance.updateFullName(
      userId: user.id!,
      fullName: fullName,
    );
    final trimmed = fullName?.trim();
    _currentUser = user.copyWith(
      fullName: trimmed,
      clearFullName: trimmed == null || trimmed.isEmpty,
    );
  }

  Future<void> deleteAccount(String password) async {
    final user = _currentUser;
    if (user == null) throw AuthException(_msg((l) => l.errSessionInactive));
    final ok = PasswordHasher.verify(
      password: password,
      salt: user.salt,
      expectedHash: user.passwordHash,
    );
    if (!ok) throw AuthException(_msg((l) => l.errOldPasswordWrong));

    await UserRepository.instance.delete(user.id!);
    _currentUser = null;
    CategoryService.instance.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefsKeys.lastUserId);
  }

  Future<String> getSecurityQuestion(String username) async {
    final user = await UserRepository.instance.findByUsername(username);
    if (user == null) {
      throw AuthException(_msg((l) => l.errAnswerOrUsername));
    }
    return user.securityQuestion;
  }

  Future<void> verifySecurityAnswer({
    required String username,
    required String answer,
  }) async {
    final user = await UserRepository.instance.findByUsername(username);
    if (user == null) {
      throw AuthException(_msg((l) => l.errAnswerOrUsername));
    }
    final ok = PasswordHasher.verifyAnswer(
      answer: answer,
      salt: user.salt,
      expectedHash: user.securityAnswerHash,
    );
    if (!ok) {
      throw AuthException(_msg((l) => l.errAnswerOrUsername));
    }
  }

  Future<void> resetPasswordViaSecurityAnswer({
    required String username,
    required String answer,
    required String newPassword,
  }) async {
    final user = await UserRepository.instance.findByUsername(username);
    if (user == null) {
      throw AuthException(_msg((l) => l.errAnswerOrUsername));
    }
    final ok = PasswordHasher.verifyAnswer(
      answer: answer,
      salt: user.salt,
      expectedHash: user.securityAnswerHash,
    );
    if (!ok) {
      throw AuthException(_msg((l) => l.errAnswerOrUsername));
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
