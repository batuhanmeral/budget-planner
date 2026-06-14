import '../models/expense.dart';
import 'expense_repository.dart';
import 'recurring_expense_repository.dart';

class RecurringExpenseRunner {
  RecurringExpenseRunner._();

  /// Aktif şablonları, en son eklenen aydan (yoksa oluşturma ayından) bugüne
  /// kadar eksik kalan tüm aylar için geri doldurur (backfill). Her ay için o
  /// ayın gününde tek bir kayıt ekler; gelecekteki tarihleri eklemez.
  static Future<int> runForUser(int userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final templates = await RecurringExpenseRepository.instance
        .getActiveForUser(userId);
    var insertedCount = 0;

    for (final t in templates) {
      var cursor = _startMonth(t.lastInsertedYearMonth, t.createdAt, now);

      while (!cursor.isAfter(DateTime(now.year, now.month, 1))) {
        final daysInMonth = DateTime(cursor.year, cursor.month + 1, 0).day;
        final effectiveDay = t.dayOfMonth > daysInMonth
            ? daysInMonth
            : t.dayOfMonth;
        final candidate = DateTime(cursor.year, cursor.month, effectiveDay);

        if (!candidate.isAfter(today)) {
          final ym =
              '${cursor.year}-${cursor.month.toString().padLeft(2, '0')}';
          try {
            await ExpenseRepository.instance.insert(
              Expense(
                userId: userId,
                amount: t.amount,
                category: t.category,
                date: candidate,
                note: t.note,
              ),
            );
            await RecurringExpenseRepository.instance.markInsertedFor(
              id: t.id!,
              yearMonth: ym,
            );
            insertedCount++;
          } catch (_) {
            // Bu ayı atla, sonraki aya geç.
          }
        }
        cursor = DateTime(cursor.year, cursor.month + 1, 1);
      }
    }
    return insertedCount;
  }

  /// Doldurmaya başlanacak ilk ay: son eklenen aydan sonraki ay; hiç
  /// eklenmediyse oluşturma ayı (o da yoksa içinde bulunulan ay).
  static DateTime _startMonth(
    String? lastInsertedYearMonth,
    DateTime? createdAt,
    DateTime now,
  ) {
    if (lastInsertedYearMonth != null) {
      final parts = lastInsertedYearMonth.split('-');
      final year = int.tryParse(parts[0]);
      final month = parts.length > 1 ? int.tryParse(parts[1]) : null;
      if (year != null && month != null) {
        return DateTime(year, month + 1, 1);
      }
    }
    final created = createdAt?.toLocal() ?? now;
    return DateTime(created.year, created.month, 1);
  }
}
