import '../models/custom_category.dart';
import 'database_service.dart';

class CustomCategoryRepository {
  CustomCategoryRepository._();
  static final instance = CustomCategoryRepository._();

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

  Future<List<CustomCategory>> getAllForUser(int userId, {String? kind}) async {
    final db = await DatabaseService.instance.database;
    final where = StringBuffer('user_id = ?');
    final args = <Object?>[userId];
    if (kind != null) {
      where.write(' AND kind = ?');
      args.add(kind);
    }
    final rows = await db.query(
      'custom_categories',
      where: where.toString(),
      whereArgs: args,
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(CustomCategory.fromMap).toList();
  }

  Future<bool> existsByName({
    required int userId,
    required String name,
    String kind = 'expense',
  }) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'custom_categories',
      where: 'user_id = ? AND name = ? COLLATE NOCASE AND kind = ?',
      whereArgs: [userId, name, kind],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
