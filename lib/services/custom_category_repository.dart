import '../models/custom_category.dart';
import 'database_service.dart';

/// `custom_categories` tablosu için CRUD repository.
///
/// Sabit kategorilerle birleştirme `CategoryService` katmanında yapılır
/// (bkz. [CategoryService]). Bu repo yalnızca DB ile konuşur.
class CustomCategoryRepository {
  CustomCategoryRepository._();
  static final instance = CustomCategoryRepository._();

  /// Yeni özel kategori ekler. UNIQUE(user_id, name) varsa sqflite
  /// exception fırlatır — UI tarafı önce findByName ile kontrol etmeli.
  Future<int> insert(CustomCategory category) async {
    final db = await DatabaseService.instance.database;
    return db.insert('custom_categories', category.toMap());
  }

  Future<int> update(CustomCategory category) async {
    if (category.id == null) {
      throw ArgumentError('update için id zorunlu');
    }
    final db = await DatabaseService.instance.database;
    final data = category.toMap()..remove('id');
    return db.update(
      'custom_categories',
      data,
      where: 'id = ? AND user_id = ?',
      whereArgs: [category.id, category.userId],
    );
  }

  Future<int> delete({required int id, required int userId}) async {
    final db = await DatabaseService.instance.database;
    return db.delete(
      'custom_categories',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<List<CustomCategory>> getAllForUser(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'custom_categories',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(CustomCategory.fromMap).toList();
  }

  /// Aynı isimde kategori var mı kontrol — form'da çakışma uyarısı için.
  Future<bool> existsByName({
    required int userId,
    required String name,
  }) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'custom_categories',
      where: 'user_id = ? AND name = ? COLLATE NOCASE',
      whereArgs: [userId, name],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
