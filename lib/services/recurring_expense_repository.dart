import '../models/recurring_expense.dart';
import 'database_service.dart';

class RecurringExpenseRepository {
  RecurringExpenseRepository._();
  static final instance = RecurringExpenseRepository._();

  Future<int> insert(RecurringExpense recurring) async {
    final db = await DatabaseService.instance.database;
    return db.insert('recurring_expenses', recurring.toMap());
  }

  Future<int> update(RecurringExpense recurring) async {
    if (recurring.id == null) {
      throw ArgumentError('update için id zorunlu');
    }
    final db = await DatabaseService.instance.database;
    final data = recurring.toMap()..remove('id');
    return db.update(
      'recurring_expenses',
      data,
      where: 'id = ? AND user_id = ?',
      whereArgs: [recurring.id, recurring.userId],
    );
  }

  Future<int> delete({required int id, required int userId}) async {
    final db = await DatabaseService.instance.database;
    return db.delete(
      'recurring_expenses',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<List<RecurringExpense>> getAllForUser(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'recurring_expenses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'day_of_month ASC, id ASC',
    );
    return rows.map(RecurringExpense.fromMap).toList();
  }

  Future<List<RecurringExpense>> getActiveForUser(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'recurring_expenses',
      where: 'user_id = ? AND active = 1',
      whereArgs: [userId],
    );
    return rows.map(RecurringExpense.fromMap).toList();
  }

  Future<int> markInsertedFor({
    required int id,
    required String yearMonth,
  }) async {
    final db = await DatabaseService.instance.database;
    return db.update(
      'recurring_expenses',
      {'last_inserted_year_month': yearMonth},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
