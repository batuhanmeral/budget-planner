import '../models/budget.dart';
import '../utils/date_utils.dart';
import 'database_service.dart';

/// `budgets` tablosu için CRUD repository'si.
///
/// Insert/update tek bir [upsert] metodunda birleşir — UI tarafı
/// "ekleme mi güncelleme mi" sorusunu sormak zorunda değil; tablo
/// `UNIQUE(user_id, category)` kısıtıyla bu kararı kendisi verir.
class BudgetRepository {
  BudgetRepository._();
  static final instance = BudgetRepository._();

  /// Bütçe ekle veya güncelle (upsert).
  ///
  /// `ON CONFLICT(user_id, category)` aynı kullanıcı + aynı kategori
  /// kombinasyonunda eski limit'i yenisiyle değiştirir. Bu sayede form
  /// ekranı tek bir mantıkla çalışır: "Yemek için 500 TL koy" → ekleme
  /// veya güncelleme otomatik karar verilir.
  ///
  /// `excluded.monthly_limit` SQLite'ın çakışan satır için yeni değeri
  /// ifade eden özel referansı.
  Future<void> upsert({
    required int userId,
    required String category,
    required double monthlyLimit,
  }) async {
    final db = await DatabaseService.instance.database;
    await db.rawInsert(
      'INSERT INTO budgets (user_id, category, monthly_limit, updated_at) '
      'VALUES (?, ?, ?, ?) '
      'ON CONFLICT(user_id, category) DO UPDATE SET '
      'monthly_limit = excluded.monthly_limit, '
      'updated_at = excluded.updated_at',
      [userId, category, monthlyLimit, nowUtcIso()],
    );
  }

  /// Bütçe silme. `user_id` koşulu sahiplik güvencesi.
  Future<int> delete({required int id, required int userId}) async {
    final db = await DatabaseService.instance.database;
    return db.delete(
      'budgets',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  /// Kullanıcının tüm bütçeleri (alfabetik kategori sırasıyla).
  Future<List<Budget>> getAllForUser(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'budgets',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'category ASC',
    );
    return rows.map(Budget.fromMap).toList();
  }

  /// Belirli bir kategori için bütçeyi döner (yoksa null). Form
  /// ekranında "bu kategori için mevcut bütçe var mı?" sorusu için.
  Future<Budget?> getByCategoryForUser({
    required int userId,
    required String category,
  }) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'budgets',
      where: 'user_id = ? AND category = ?',
      whereArgs: [userId, category],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Budget.fromMap(rows.first);
  }
}
