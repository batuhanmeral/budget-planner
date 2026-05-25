import '../models/expense.dart';
import '../utils/date_utils.dart';
import '../utils/money_utils.dart';
import 'database_service.dart';

enum ExpenseSort { dateDesc, dateAsc, amountDesc, amountAsc, category }

extension on ExpenseSort {
  String get sql {
    switch (this) {
      case ExpenseSort.dateDesc:
        return 'date DESC, id DESC';
      case ExpenseSort.dateAsc:
        return 'date ASC, id ASC';
      case ExpenseSort.amountDesc:
        return 'amount DESC, id DESC';
      case ExpenseSort.amountAsc:
        return 'amount ASC, id ASC';
      case ExpenseSort.category:
        return 'category ASC, date DESC';
    }
  }
}

class DailyTotal {
  final DateTime date;
  final double total;
  const DailyTotal(this.date, this.total);
}

class ExpenseRepository {
  ExpenseRepository._();
  static final instance = ExpenseRepository._();

  Future<int> insert(Expense expense) async {
    final db = await DatabaseService.instance.database;
    final data = expense.toMap()..['created_at'] = nowUtcIso();
    return db.insert('expenses', data);
  }

  Future<int> update(Expense expense) async {
    if (expense.id == null) {
      throw ArgumentError('update için id zorunlu');
    }
    final db = await DatabaseService.instance.database;
    final data = expense.toMap()..remove('id');
    return db.update(
      'expenses',
      data,
      where: 'id = ? AND user_id = ?',
      whereArgs: [expense.id, expense.userId],
    );
  }

  Future<int> delete({required int id, required int userId}) async {
    final db = await DatabaseService.instance.database;
    return db.delete(
      'expenses',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<int> deleteAllForUser(int userId) async {
    final db = await DatabaseService.instance.database;
    return db.delete('expenses', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<Expense?> getById({required int id, required int userId}) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'expenses',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Expense.fromMap(rows.first);
  }

  Future<List<Expense>> getAllForUser(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'expenses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  Future<List<Expense>> getByDateRange({
    required int userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'expenses',
      where: 'user_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [userId, formatDateOnly(from), formatDateOnly(to)],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  Future<List<Expense>> getByCategory({
    required int userId,
    required String category,
  }) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'expenses',
      where: 'user_id = ? AND category = ?',
      whereArgs: [userId, category],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  Future<double> getMonthlyTotal({
    required int userId,
    required int year,
    required int month,
  }) async {
    final db = await DatabaseService.instance.database;
    final prefix = '${monthPrefix(year, month)}%';
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM expenses '
      'WHERE user_id = ? AND date LIKE ?',
      [userId, prefix],
    );
    final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
    return roundMoney(total);
  }

  Future<Map<String, double>> getMonthlyTotalByCategory({
    required int userId,
    required int year,
    required int month,
  }) async {
    final db = await DatabaseService.instance.database;
    final prefix = '${monthPrefix(year, month)}%';
    final rows = await db.rawQuery(
      'SELECT category, SUM(amount) AS total FROM expenses '
      'WHERE user_id = ? AND date LIKE ? '
      'GROUP BY category',
      [userId, prefix],
    );
    return {
      for (final r in rows)
        r['category'] as String: roundMoney((r['total'] as num).toDouble()),
    };
  }

  Future<List<DailyTotal>> getDailyTotalsForLastNDays({
    required int userId,
    required int days,
  }) async {
    final db = await DatabaseService.instance.database;
    final today = stripTime(DateTime.now());
    final from = today.subtract(Duration(days: days - 1));
    final rows = await db.rawQuery(
      'SELECT date, SUM(amount) AS total FROM expenses '
      'WHERE user_id = ? AND date BETWEEN ? AND ? '
      'GROUP BY date',
      [userId, formatDateOnly(from), formatDateOnly(today)],
    );
    final byDate = <String, double>{
      for (final r in rows)
        r['date'] as String: roundMoney((r['total'] as num).toDouble()),
    };
    final result = <DailyTotal>[];
    for (var i = 0; i < days; i++) {
      final d = from.add(Duration(days: i));
      final key = formatDateOnly(d);
      result.add(DailyTotal(d, byDate[key] ?? 0.0));
    }
    return result;
  }

  Future<List<Expense>> search({
    required int userId,
    required String query,
  }) async {
    if (query.trim().isEmpty) return getAllForUser(userId);
    final db = await DatabaseService.instance.database;
    final escaped = query
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    final pattern = '%$escaped%';
    final rows = await db.rawQuery(
      "SELECT * FROM expenses "
      "WHERE user_id = ? AND note LIKE ? ESCAPE '\\' "
      "ORDER BY date DESC, id DESC",
      [userId, pattern],
    );
    return rows.map(Expense.fromMap).toList();
  }

  /// Liste ekranı için tek noktadan filtre + sıralama.
  Future<List<Expense>> getFilteredAndSorted({
    required int userId,
    String? category,
    DateTime? from,
    DateTime? to,
    String? noteQuery,
    ExpenseSort sort = ExpenseSort.dateDesc,
  }) async {
    final db = await DatabaseService.instance.database;
    final where = <String>['user_id = ?'];
    final args = <Object?>[userId];

    if (category != null) {
      where.add('category = ?');
      args.add(category);
    }
    if (from != null) {
      where.add('date >= ?');
      args.add(formatDateOnly(from));
    }
    if (to != null) {
      where.add('date <= ?');
      args.add(formatDateOnly(to));
    }
    if (noteQuery != null && noteQuery.trim().isNotEmpty) {
      final escaped = noteQuery
          .replaceAll(r'\', r'\\')
          .replaceAll('%', r'\%')
          .replaceAll('_', r'\_');
      where.add("note LIKE ? ESCAPE '\\'");
      args.add('%$escaped%');
    }

    final rows = await db.query(
      'expenses',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: sort.sql,
    );
    return rows.map(Expense.fromMap).toList();
  }
}
