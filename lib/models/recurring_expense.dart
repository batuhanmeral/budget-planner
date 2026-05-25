import '../utils/date_utils.dart';

/// Her ay belirli bir günde otomatik üretilen harcama şablonu.
///
/// Splash/Home açılışında [last_inserted_year_month] kontrol edilir;
/// içinde bulunulan ay için hâlâ insert yapılmadıysa ve gün geldiyse
/// gerçek bir [Expense] yaratılır.
///
/// 30/31 olmayan aylarda ([dayOfMonth] = 31, Şubat ayı vs.) son güne
/// kaydırılır — RecurringExpenseRunner sorumluluğunda.
class RecurringExpense {
  final int? id;
  final int userId;
  final double amount;
  final String category;
  final String? note;
  final int dayOfMonth;
  final String? lastInsertedYearMonth; // 'YYYY-MM'
  final bool active;
  final DateTime? createdAt;

  const RecurringExpense({
    this.id,
    required this.userId,
    required this.amount,
    required this.category,
    this.note,
    required this.dayOfMonth,
    this.lastInsertedYearMonth,
    this.active = true,
    this.createdAt,
  });

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'amount': amount,
    'category': category,
    'note': note,
    'day_of_month': dayOfMonth,
    'last_inserted_year_month': lastInsertedYearMonth,
    'active': active ? 1 : 0,
    if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
  };

  factory RecurringExpense.fromMap(Map<String, Object?> map) =>
      RecurringExpense(
        id: map['id'] as int?,
        userId: map['user_id'] as int,
        amount: (map['amount'] as num).toDouble(),
        category: map['category'] as String,
        note: map['note'] as String?,
        dayOfMonth: map['day_of_month'] as int,
        lastInsertedYearMonth: map['last_inserted_year_month'] as String?,
        active: (map['active'] as int) == 1,
        createdAt: parseIsoOrNull(map['created_at'] as String?),
      );

  RecurringExpense copyWith({
    int? id,
    int? userId,
    double? amount,
    String? category,
    String? note,
    bool clearNote = false,
    int? dayOfMonth,
    String? lastInsertedYearMonth,
    bool clearLastInserted = false,
    bool? active,
    DateTime? createdAt,
  }) => RecurringExpense(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    note: clearNote ? null : (note ?? this.note),
    dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    lastInsertedYearMonth: clearLastInserted
        ? null
        : (lastInsertedYearMonth ?? this.lastInsertedYearMonth),
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
  );
}
