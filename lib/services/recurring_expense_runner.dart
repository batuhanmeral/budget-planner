import '../models/expense.dart';
import 'expense_repository.dart';
import 'recurring_expense_repository.dart';

/// Tekrarlayan harcama şablonlarını her ay için gerçek [Expense]'a
/// dönüştüren servis.
///
/// Splash ekranında auto-login sonrası çağrılır. Her aktif şablon için:
/// 1. Bu ay için zaten insert edilmiş mi? → atla
/// 2. Tetik günü geldi mi? → değilse atla
/// 3. Geldiyse Expense insert + şablonun "son insert edildi" işareti güncelle
///
/// Şubat gibi 28/29 günlü aylarda `day_of_month = 30/31` ise son güne
/// kaydırılır — kullanıcı her ay aynı şablonun çalışmasını bekler.
class RecurringExpenseRunner {
  RecurringExpenseRunner._();

  /// Kullanıcının aktif tekrarlayanları için bu ayın insert işlemini
  /// yapar. İnsert edilen kayıt sayısını döner.
  static Future<int> runForUser(int userId) async {
    final today = DateTime.now();
    final yearMonth =
        '${today.year}-${today.month.toString().padLeft(2, '0')}';
    // Ayın son günü: bir sonraki ayın 0. günü = bu ayın son günü.
    final daysInThisMonth = DateTime(today.year, today.month + 1, 0).day;

    final templates = await RecurringExpenseRepository.instance
        .getActiveForUser(userId);
    var insertedCount = 0;

    for (final t in templates) {
      // Bu ay için zaten insert edildi mi? Çift insert'i önler.
      if (t.lastInsertedYearMonth == yearMonth) continue;

      // 31. gün ayarlı ama bu ay 30 gün varsa, son güne kaydır.
      final effectiveDay = t.dayOfMonth > daysInThisMonth
          ? daysInThisMonth
          : t.dayOfMonth;

      // Tetik günü henüz gelmediyse atla — gelecek aylarda otomatik kaçar.
      if (today.day < effectiveDay) continue;

      try {
        final expense = Expense(
          userId: userId,
          amount: t.amount,
          category: t.category,
          date: DateTime(today.year, today.month, effectiveDay),
          note: t.note,
        );
        await ExpenseRepository.instance.insert(expense);
        await RecurringExpenseRepository.instance.markInsertedFor(
          id: t.id!,
          yearMonth: yearMonth,
        );
        insertedCount++;
      } catch (_) {
        // Tek bir şablon başarısız olursa diğerlerini bloke etmesin.
        continue;
      }
    }
    return insertedCount;
  }
}
