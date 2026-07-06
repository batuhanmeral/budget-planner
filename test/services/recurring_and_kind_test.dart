import 'package:budget_planner/models/custom_category.dart';
import 'package:budget_planner/models/recurring_income.dart';
import 'package:budget_planner/models/user.dart';
import 'package:budget_planner/services/custom_category_repository.dart';
import 'package:budget_planner/services/database_service.dart';
import 'package:budget_planner/services/recurring_income_repository.dart';
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
        username: 'kindtester',
        passwordHash: 'h',
        salt: 's',
        securityQuestion: 'q',
        securityAnswerHash: 'a',
      ),
    );
  });

  tearDownAll(() async => DatabaseService.instance.close());

  group('users.full_name', () {
    test('updateFullName yazar ve okur, boşsa null', () async {
      await UserRepository.instance.updateFullName(
        userId: userId,
        fullName: '  Batuhan Meral  ',
      );
      var u = await UserRepository.instance.findById(userId);
      expect(u!.fullName, 'Batuhan Meral');

      await UserRepository.instance.updateFullName(
        userId: userId,
        fullName: '',
      );
      u = await UserRepository.instance.findById(userId);
      expect(u!.fullName, isNull);
    });
  });

  group('custom_categories.kind ayrımı', () {
    test('gider ve gelir kategorileri ayrı listelenir', () async {
      await CustomCategoryRepository.instance.insert(
        CustomCategory(
          userId: userId,
          name: 'Kira',
          iconCode: 100,
          colorInt: 0xFF000000,
          kind: 'expense',
        ),
      );
      await CustomCategoryRepository.instance.insert(
        CustomCategory(
          userId: userId,
          name: 'Freelance',
          iconCode: 101,
          colorInt: 0xFF111111,
          kind: 'income',
        ),
      );

      final expense = await CustomCategoryRepository.instance.getAllForUser(
        userId,
        kind: 'expense',
      );
      final income = await CustomCategoryRepository.instance.getAllForUser(
        userId,
        kind: 'income',
      );
      expect(expense.map((c) => c.name), contains('Kira'));
      expect(expense.map((c) => c.name), isNot(contains('Freelance')));
      expect(income.map((c) => c.name), contains('Freelance'));

      expect(
        await CustomCategoryRepository.instance.existsByName(
          userId: userId,
          name: 'Kira',
          kind: 'income',
        ),
        isFalse,
      );
    });
  });

  group('recurring_incomes', () {
    test('insert + getActiveForUser yalnızca aktifleri döner', () async {
      await RecurringIncomeRepository.instance.insert(
        RecurringIncome(
          userId: userId,
          amount: 5000,
          source: 'Maaş',
          dayOfMonth: 1,
        ),
      );
      await RecurringIncomeRepository.instance.insert(
        RecurringIncome(
          userId: userId,
          amount: 100,
          source: 'Kira Geliri',
          dayOfMonth: 5,
          active: false,
        ),
      );
      final active = await RecurringIncomeRepository.instance.getActiveForUser(
        userId,
      );
      expect(active.length, 1);
      expect(active.first.source, 'Maaş');
    });

    test('markInsertedFor çift eklemeyi engelleyecek işareti yazar', () async {
      final all = await RecurringIncomeRepository.instance.getAllForUser(
        userId,
      );
      final tpl = all.firstWhere((t) => t.source == 'Maaş');
      await RecurringIncomeRepository.instance.markInsertedFor(
        id: tpl.id!,
        yearMonth: '2026-06',
      );
      final updated = (await RecurringIncomeRepository.instance.getAllForUser(
        userId,
      )).firstWhere((t) => t.id == tpl.id);
      expect(updated.lastInsertedYearMonth, '2026-06');
    });
  });
}
