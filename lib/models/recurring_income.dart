import '../utils/date_utils.dart';

class RecurringIncome {
  final int? id;
  final int userId;
  final double amount;
  final String source;
  final String? note;
  final int dayOfMonth;
  final String? lastInsertedYearMonth;
  final bool active;
  final DateTime? createdAt;

  const RecurringIncome({
    this.id,
    required this.userId,
    required this.amount,
    required this.source,
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
    'source': source,
    'note': note,
    'day_of_month': dayOfMonth,
    'last_inserted_year_month': lastInsertedYearMonth,
    'active': active ? 1 : 0,
    if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
  };

  factory RecurringIncome.fromMap(Map<String, Object?> map) => RecurringIncome(
    id: map['id'] as int?,
    userId: map['user_id'] as int,
    amount: (map['amount'] as num).toDouble(),
    source: map['source'] as String,
    note: map['note'] as String?,
    dayOfMonth: map['day_of_month'] as int,
    lastInsertedYearMonth: map['last_inserted_year_month'] as String?,
    active: (map['active'] as int) == 1,
    createdAt: parseIsoOrNull(map['created_at'] as String?),
  );

  RecurringIncome copyWith({
    int? id,
    int? userId,
    double? amount,
    String? source,
    String? note,
    bool clearNote = false,
    int? dayOfMonth,
    String? lastInsertedYearMonth,
    bool clearLastInserted = false,
    bool? active,
    DateTime? createdAt,
  }) => RecurringIncome(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    amount: amount ?? this.amount,
    source: source ?? this.source,
    note: clearNote ? null : (note ?? this.note),
    dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    lastInsertedYearMonth: clearLastInserted
        ? null
        : (lastInsertedYearMonth ?? this.lastInsertedYearMonth),
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
  );
}
