import '../models/user.dart';
import '../utils/date_utils.dart';
import '../utils/string_utils.dart';
import 'database_service.dart';

class UserRepository {
  UserRepository._();
  static final instance = UserRepository._();

  Future<int> insert(User user) async {
    final db = await DatabaseService.instance.database;
    final data = user.toMap()
      ..['username'] = normalizeIdentifier(user.username)
      ..['created_at'] = nowUtcIso();
    return db.insert('users', data);
  }

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

  Future<int> updateFailedAttempts(int userId, int attempts) async {
    final db = await DatabaseService.instance.database;
    return db.update(
      'users',
      {'failed_attempts': attempts},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateLockout(int userId, DateTime? until) async {
    final db = await DatabaseService.instance.database;
    return db.update(
      'users',
      {'lockout_until': until?.toUtc().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> resetFailedState(int userId) async {
    final db = await DatabaseService.instance.database;
    return db.update(
      'users',
      {'failed_attempts': 0, 'lockout_until': null},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> delete(int userId) async {
    final db = await DatabaseService.instance.database;
    return db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }
}
