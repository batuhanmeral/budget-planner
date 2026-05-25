import 'package:shared_preferences/shared_preferences.dart';

import '../app/app_constants.dart';
import '../models/user.dart';
import 'password_hasher.dart';
import 'user_repository.dart';

/// Auth katmanından fırlatılan beklenen hatalar (yanlış parola, kilit vb).
///
/// UI tarafında `try / catch (AuthException)` ile yakalanıp `SnackBar`
/// ile gösterilir. Mesaj kullanıcıya doğrudan iletilebilir.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

/// Uygulamanın kimlik doğrulama akışını yöneten singleton servis.
///
/// Sorumlulukları:
/// - Kayıt, giriş, çıkış akışları
/// - Auto-login (oturum hatırlama) [SharedPreferences] üzerinden
/// - Parola değiştirme + güvenlik sorusu ile sıfırlama
/// - Hesap silme (cascade ile veri temizliği)
/// - Brute-force koruması: 5 başarısız denemede 30 sn kilit
///
/// Aktif kullanıcı [currentUser] içinde bellekte tutulur; uygulama
/// kapanınca kaybolur ama prefs üzerinden tekrar `tryAutoLogin` ile
/// yüklenir.
class AuthService {
  AuthService._();
  static final instance = AuthService._();

  // Brute-force koruma parametreleri.
  static const _maxFailedAttempts = 5;
  static const _lockoutDuration = Duration(seconds: 30);

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Splash ekranında çağrılır. Daha önce login olmuş kullanıcı varsa
  /// (prefs'te lastUserId kayıtlıysa ve DB'de hâlâ varsa) otomatik giriş
  /// yapar. Aksi takdirde null döner ve LoginScreen'e yönlendirme yapılır.
  ///
  /// DB'de bulunamayan stale ID'ler temizlenir.
  Future<User?> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(PrefsKeys.lastUserId);
    if (id == null) return null;
    final user = await UserRepository.instance.findById(id);
    if (user == null) {
      // Kullanıcı silinmiş veya DB sıfırlanmış — stale ref'i temizle.
      await prefs.remove(PrefsKeys.lastUserId);
      return null;
    }
    _currentUser = user;
    return user;
  }

  /// Yeni kullanıcı kaydı. Aşağıdaki adımları sırayla yapar:
  /// 1. Kullanıcı adı çakışmasını kontrol et.
  /// 2. Rastgele salt üret, parola ve cevap hash'lerini hesapla.
  /// 3. DB'ye insert et.
  /// 4. Yeni kaydı oku ([createdAt] dolsun diye).
  /// 5. `currentUser` set + prefs'e ID yaz (otomatik login).
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
      // Beklenmedik durum — insert hemen sonra findById null veriyor.
      throw AuthException('Kayıt sırasında bir hata oluştu');
    }
    _currentUser = saved;
    await _persistSession(id);
    return saved;
  }

  /// Giriş akışı:
  /// 1. Kullanıcıyı bul (normalize edilmiş username ile).
  /// 2. Aktif lockout var mı kontrol et — varsa hata fırlat.
  /// 3. Parolayı verify et.
  ///    - Yanlışsa: failed_attempts++; eşiği aşarsa lockout set.
  /// 4. Doğruysa: failed state sıfırla, currentUser set, prefs'e yaz.
  ///
  /// Hata mesajı her durumda generic ("Kullanıcı adı veya parola
  /// hatalı") — kullanıcı sayımı sızdırmaz (user enumeration).
  Future<User> login({
    required String username,
    required String password,
  }) async {
    final user = await UserRepository.instance.findByUsername(username);
    if (user == null) {
      throw AuthException('Kullanıcı adı veya parola hatalı');
    }
    // Lockout kontrolü — UTC zamanla karşılaştır.
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
      // Başarısız deneme — sayacı artır, eşiğe ulaşırsa kilitle.
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

    // Başarılı giriş — sayacı ve kilidi sıfırla, oturumu kaydet.
    await UserRepository.instance.resetFailedState(user.id!);
    final fresh = await UserRepository.instance.findById(user.id!);
    _currentUser = fresh;
    await _persistSession(user.id!);
    return fresh!;
  }

  /// Çıkış: belleği ve prefs'i temizler. UI tarafı sonrasında
  /// LoginScreen'e yönlendirir.
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefsKeys.lastUserId);
  }

  /// Parola değiştirme. Eski parolayı doğrular, yeni bir salt + hash
  /// üretir ve [currentUser]'ı bellek üzerinde de günceller.
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

    // Salt'ı her parola değişikliğinde tazelemek güvenlik için kritik.
    final newSalt = PasswordHasher.generateSalt();
    final newHash = PasswordHasher.hash(newPassword, newSalt);
    await UserRepository.instance.updatePassword(
      userId: user.id!,
      passwordHash: newHash,
      salt: newSalt,
    );
    _currentUser = user.copyWith(passwordHash: newHash, salt: newSalt);
  }

  /// Hesap silme.
  ///
  /// Parola onayı ister. Önemli: bu code path login akışından bağımsızdır
  /// — başarısız doğrulama [failedAttempts] sayacını ARTIRMAZ. Aksi
  /// takdirde kullanıcı kendi hesabını silmeye çalışırken login'den de
  /// kilitlenirdi.
  ///
  /// Silme cascade ile harcamaları ve bütçeleri de düşürür.
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
    // Prefs'te kalan stale lastUserId'yi de temizle.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefsKeys.lastUserId);
  }

  /// "Parolamı Unuttum" akışının 2. adımı — kayıtlı güvenlik sorusunu
  /// döner. Kullanıcı bulunamazsa generic hata.
  Future<String> getSecurityQuestion(String username) async {
    final user = await UserRepository.instance.findByUsername(username);
    if (user == null) {
      throw AuthException('Kullanıcı adı veya cevap hatalı');
    }
    return user.securityQuestion;
  }

  /// "Parolamı Unuttum" akışının son adımı.
  ///
  /// Güvenlik cevabını doğrular (cevap normalize edilerek hash karşılaştırılır)
  /// ve doğruysa yeni salt + hash ile parolayı sıfırlar. Failed_attempts
  /// de sıfırlanır — kullanıcı tekrar denemekten kurtulur.
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

  /// `lastUserId` prefs anahtarına yazar — auto-login için.
  Future<void> _persistSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.lastUserId, userId);
  }
}
