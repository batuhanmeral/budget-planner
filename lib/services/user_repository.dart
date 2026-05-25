import '../models/user.dart';
import '../utils/date_utils.dart';
import '../utils/string_utils.dart';
import 'database_service.dart';

/// `users` tablosu için CRUD operasyonlarını sarmalayan repository.
///
/// Yüksek seviye iş mantığı (parola hashleme, lockout vb.) AuthService
/// içinde; bu sınıf yalnızca DB ile konuşur.
class UserRepository {
  UserRepository._();
  static final instance = UserRepository._();

  /// Yeni kullanıcı ekler. Username insert öncesi normalize edilir
  /// (Türkçe karakter + lowercase) ve created_at UTC olarak set edilir.
  ///
  /// Eklenen satırın ID'sini döner. UNIQUE çakışması olursa sqflite
  /// exception fırlatır — bunu AuthService.register zaten önceden
  /// findByUsername ile kontrol ediyor.
  Future<int> insert(User user) async {
    final db = await DatabaseService.instance.database;
    final data = user.toMap()
      ..['username'] = normalizeIdentifier(user.username)
      ..['created_at'] = nowUtcIso();
    return db.insert('users', data);
  }

  /// Username ile kullanıcı arar. Parametre normalize edilerek
  /// karşılaştırılır — "İSTANBUL", "istanbul" ve "ISTANBUL" aynı kaydı
  /// bulur.
  Future<User?> findByUsername(String username) async {
    final db = await DatabaseService.instance.database;
    final normalized = normalizeIdentifier(username);
    final rows = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [normalized],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  /// Primary key ile kullanıcıyı bulur. Auto-login ve oturum tazeleme
  /// için kullanılır.
  Future<User?> findById(int id) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  /// Parola hash'i ve salt'ı günceller. Yeni salt her parola
  /// değişikliğinde üretilir (AuthService sorumluluğu).
  Future<int> updatePassword({
    required int userId,
    required String passwordHash,
    required String salt,
  }) async {
    final db = await DatabaseService.instance.database;
    return db.update(
      'users',
      {'password_hash': passwordHash, 'salt': salt},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Başarısız deneme sayısını günceller (brute-force koruma).
  Future<int> updateFailedAttempts(int userId, int attempts) async {
    final db = await DatabaseService.instance.database;
    return db.update(
      'users',
      {'failed_attempts': attempts},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Kilit bitiş zamanını UTC olarak yazar. `null` verirse kilidi kaldırır.
  Future<int> updateLockout(int userId, DateTime? until) async {
    final db = await DatabaseService.instance.database;
    return db.update(
      'users',
      {'lockout_until': until?.toUtc().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Başarılı giriş sonrası: hem deneme sayacını hem kilidi sıfırlar.
  /// Tek bir UPDATE ile atomik şekilde yapılır.
  Future<int> resetFailedState(int userId) async {
    final db = await DatabaseService.instance.database;
    return db.update(
      'users',
      {'failed_attempts': 0, 'lockout_until': null},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Kullanıcı silme — cascade ile harcamaları ve bütçeleri de düşer.
  Future<int> delete(int userId) async {
    final db = await DatabaseService.instance.database;
    return db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }
}
