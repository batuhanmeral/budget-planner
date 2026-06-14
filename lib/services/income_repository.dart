import '../models/income.dart';
import '../utils/date_utils.dart';
import '../utils/money_utils.dart';
import 'database_service.dart';
import 'expense_repository.dart' show MonthTotal;

enum IncomeSort { dateDesc, dateAsc, amountDesc, amountAsc, source }

extension on IncomeSort {
  String get sql {
    switch (this) {
      case IncomeSort.dateDesc:
        return 'date DESC, id DESC';
      case IncomeSort.dateAsc:
        return 'date ASC, id ASC';
      case IncomeSort.amountDesc:
        return 'amount DESC, id DESC';
      case IncomeSort.amountAsc:
        return 'amount ASC, id ASC';
      case IncomeSort.source:
        return 'source ASC, date DESC';
    }
  }
}

class IncomeRepository {
  IncomeRepository._();
  static final instance = IncomeRepository._();

  Future<int> insert(Income income) async {
    final db = await DatabaseService.instance.database;
    final data = income.toMap()..['created_at'] = nowUtcIso();
    return db.insert('incomes', data);
  }

  Future<int> update(Income income) async {
    if (income.id == null) {
      throw ArgumentError('update için id zorunlu');
    }
    final db = await DatabaseService.instance.database;
    final data = income.toMap()..remove('id');
    return db.update(
      'incomes',
      data,
      where: 'id = ? AND user_id = ?',
      whereArgs: [income.id, income.userId],
    );
  }

  Future<int> delete({required int id, required int userId}) async {
    final db = await DatabaseService.instance.database;
    return db.delete(
      'incomes',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<int> deleteAllForUser(int userId) async {
    final db = await DatabaseService.instance.database;
    return db.delete('incomes', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<Income?> getById({required int id, required int userId}) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'incomes',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Income.fromMap(rows.first);
  }

  Future<List<Income>> getAllForUser(
    int userId, {
    IncomeSort sort = IncomeSort.dateDesc,
  }) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'incomes',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: sort.sql,
    );
    return rows.map(Income.fromMap).toList();
  }

  Future<List<Income>> getFilteredAndSorted({
    required int userId,
    String? source,
    DateTime? from,
    DateTime? to,
    String? noteQuery,
    IncomeSort sort = IncomeSort.dateDesc,
  }) async {
    final db = await DatabaseService.instance.database;
    final where = <String>['user_id = ?'];
    final args = <Object?>[userId];

    if (source != null) {
      where.add('source = ?');
      args.add(source);
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
      'incomes',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: sort.sql,
    );
    return rows.map(Income.fromMap).toList();
  }

  Future<List<Income>> getByDateRange({
    required int userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'incomes',
      where: 'user_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [userId, formatDateOnly(from), formatDateOnly(to)],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(Income.fromMap).toList();
  }

  Future<double> getMonthlyTotal({
    required int userId,
    required int year,
    required int month,
  }) async {
    final db = await DatabaseService.instance.database;
    final prefix = '${monthPrefix(year, month)}%';
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM incomes '
      'WHERE user_id = ? AND date LIKE ?',
      [userId, prefix],
    );
    final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
    return roundMoney(total);
  }

  Future<List<MonthTotal>> getYearlyTotalsByMonth({
    required int userId,
    required int year,
  }) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery(
      "SELECT substr(date, 6, 2) AS m, SUM(amount) AS total FROM incomes "
      "WHERE user_id = ? AND date LIKE ? "
      "GROUP BY m",
      [userId, '$year-%'],
    );
    final byMonth = <int, double>{
      for (final r in rows)
        int.parse(r['m'] as String): roundMoney((r['total'] as num).toDouble()),
    };
    return List.generate(
      12,
      (i) => MonthTotal(month: i + 1, total: byMonth[i + 1] ?? 0.0),
    );
  }

  Future<Map<String, double>> getMonthlyTotalBySource({
    required int userId,
    required int year,
    required int month,
  }) async {
    final db = await DatabaseService.instance.database;
    final prefix = '${monthPrefix(year, month)}%';
    final rows = await db.rawQuery(
      'SELECT source, SUM(amount) AS total FROM incomes '
      'WHERE user_id = ? AND date LIKE ? '
      'GROUP BY source',
      [userId, prefix],
    );
    return {
      for (final r in rows)
        r['source'] as String: roundMoney((r['total'] as num).toDouble()),
    };
  }

  Future<Map<String, double>> getYearTotalBySource({
    required int userId,
    required int year,
  }) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery(
      'SELECT source, SUM(amount) AS total FROM incomes '
      'WHERE user_id = ? AND date LIKE ? '
      'GROUP BY source',
      [userId, '$year-%'],
    );
    return {
      for (final r in rows)
        r['source'] as String: roundMoney((r['total'] as num).toDouble()),
    };
  }

  Future<Map<String, double>> getRangeTotalBySource({
    required int userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery(
      'SELECT source, SUM(amount) AS total FROM incomes '
      'WHERE user_id = ? AND date BETWEEN ? AND ? '
      'GROUP BY source',
      [userId, formatDateOnly(from), formatDateOnly(to)],
    );
    return {
      for (final r in rows)
        r['source'] as String: roundMoney((r['total'] as num).toDouble()),
    };
  }
}
