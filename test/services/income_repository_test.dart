import 'package:budget_planner/models/income.dart';
import 'package:budget_planner/models/user.dart';
import 'package:budget_planner/services/database_service.dart';
import 'package:budget_planner/services/expense_repository.dart';
import 'package:budget_planner/models/expense.dart';
import 'package:budget_planner/services/income_repository.dart';
import 'package:budget_planner/services/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late int userId;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseService.testDatabasePath = inMemoryDatabasePath;

    userId = await UserRepository.instance.insert(
      const User(
        username: 'tester',
        passwordHash: 'hash',
        salt: 'salt',
        securityQuestion: 'q',
        securityAnswerHash: 'a',
      ),
    );
  });

  tearDownAll(() async {
    await DatabaseService.instance.close();
  });

  setUp(() async {
    await IncomeRepository.instance.deleteAllForUser(userId);
  });

  Income sample({
    double amount = 100,
    String source = 'Maaş',
    required DateTime date,
    String? note,
  }) => Income(
    userId: userId,
    amount: amount,
    source: source,
    date: date,
    note: note,
  );

  test('insert + getById alanları korur', () async {
    final id = await IncomeRepository.instance.insert(
      sample(
        amount: 1500,
        source: 'Maaş',
        date: DateTime(2026, 6, 1),
        note: 'haziran',
      ),
    );
    final fetched = await IncomeRepository.instance.getById(
      id: id,
      userId: userId,
    );
    expect(fetched, isNotNull);
    expect(fetched!.amount, 1500);
    expect(fetched.source, 'Maaş');
    expect(fetched.note, 'haziran');
    expect(fetched.createdAt, isNotNull);
  });

  test('getMonthlyTotal sadece ilgili ayı toplar', () async {
    await IncomeRepository.instance.insert(
      sample(amount: 1000, date: DateTime(2026, 6, 5)),
    );
    await IncomeRepository.instance.insert(
      sample(amount: 500, date: DateTime(2026, 6, 25)),
    );
    await IncomeRepository.instance.insert(
      sample(amount: 999, date: DateTime(2026, 5, 30)),
    );

    final total = await IncomeRepository.instance.getMonthlyTotal(
      userId: userId,
      year: 2026,
      month: 6,
    );
    expect(total, 1500);
  });

  test('net bakiye = aylık gelir - aylık gider', () async {
    await IncomeRepository.instance.insert(
      sample(amount: 2000, date: DateTime(2026, 6, 10)),
    );
    await ExpenseRepository.instance.insert(
      Expense(
        userId: userId,
        amount: 750,
        category: 'Yemek',
        date: DateTime(2026, 6, 12),
      ),
    );

    final income = await IncomeRepository.instance.getMonthlyTotal(
      userId: userId,
      year: 2026,
      month: 6,
    );
    final expense = await ExpenseRepository.instance.getMonthlyTotal(
      userId: userId,
      year: 2026,
      month: 6,
    );
    expect(income - expense, 1250);

    await ExpenseRepository.instance.deleteAllForUser(userId);
  });

  test('getMonthlyTotalBySource kaynak bazında gruplar', () async {
    await IncomeRepository.instance.insert(
      sample(amount: 3000, source: 'Maaş', date: DateTime(2026, 6, 1)),
    );
    await IncomeRepository.instance.insert(
      sample(amount: 400, source: 'Hediye', date: DateTime(2026, 6, 3)),
    );
    await IncomeRepository.instance.insert(
      sample(amount: 100, source: 'Hediye', date: DateTime(2026, 6, 4)),
    );

    final bySource = await IncomeRepository.instance.getMonthlyTotalBySource(
      userId: userId,
      year: 2026,
      month: 6,
    );
    expect(bySource['Maaş'], 3000);
    expect(bySource['Hediye'], 500);
  });

  test('update tutarı değiştirir', () async {
    final id = await IncomeRepository.instance.insert(
      sample(amount: 100, date: DateTime(2026, 6, 1)),
    );
    final existing = await IncomeRepository.instance.getById(
      id: id,
      userId: userId,
    );
    await IncomeRepository.instance.update(existing!.copyWith(amount: 250));
    final updated = await IncomeRepository.instance.getById(
      id: id,
      userId: userId,
    );
    expect(updated!.amount, 250);
  });

  test('delete kaydı kaldırır', () async {
    final id = await IncomeRepository.instance.insert(
      sample(amount: 100, date: DateTime(2026, 6, 1)),
    );
    await IncomeRepository.instance.delete(id: id, userId: userId);
    final gone = await IncomeRepository.instance.getById(
      id: id,
      userId: userId,
    );
    expect(gone, isNull);
  });

  test('getByDateRange aralık dışını hariç tutar', () async {
    await IncomeRepository.instance.insert(
      sample(amount: 10, date: DateTime(2026, 6, 1)),
    );
    await IncomeRepository.instance.insert(
      sample(amount: 20, date: DateTime(2026, 6, 15)),
    );
    await IncomeRepository.instance.insert(
      sample(amount: 30, date: DateTime(2026, 7, 1)),
    );
    final inRange = await IncomeRepository.instance.getByDateRange(
      userId: userId,
      from: DateTime(2026, 6, 1),
      to: DateTime(2026, 6, 30),
    );
    expect(inRange.length, 2);
    expect(inRange.map((i) => i.amount).toList()..sort(), [10, 20]);
  });
}
