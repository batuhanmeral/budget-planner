import '../models/recurring_income.dart';
import 'database_service.dart';

class RecurringIncomeRepository {
  RecurringIncomeRepository._();
  static final instance = RecurringIncomeRepository._();

  Future<int> insert(RecurringIncome recurring) async {
    final db = await DatabaseService.instance.database;
    return db.insert('recurring_incomes', recurring.toMap());
  }

  Future<int> update(RecurringIncome recurring) async {
    if (recurring.id == null) {
      throw ArgumentError('update için id zorunlu');
    }
    final db = await DatabaseService.instance.database;
    final data = recurring.toMap()..remove('id');
    return db.update(
      'recurring_incomes',
      data,
      where: 'id = ? AND user_id = ?',
      whereArgs: [recurring.id, recurring.userId],
    );
  }

  Future<int> delete({required int id, required int userId}) async {
    final db = await DatabaseService.instance.database;
    return db.delete(
      'recurring_incomes',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<List<RecurringIncome>> getAllForUser(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'recurring_incomes',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'day_of_month ASC, id ASC',
    );
    return rows.map(RecurringIncome.fromMap).toList();
  }

  Future<List<RecurringIncome>> getActiveForUser(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'recurring_incomes',
      where: 'user_id = ? AND active = 1',
      whereArgs: [userId],
    );
    return rows.map(RecurringIncome.fromMap).toList();
  }

  Future<int> markInsertedFor({
    required int id,
    required String yearMonth,
  }) async {
    final db = await DatabaseService.instance.database;
    return db.update(
      'recurring_incomes',
      {'last_inserted_year_month': yearMonth},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
