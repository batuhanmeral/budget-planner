import '../utils/date_utils.dart';

class Expense {
  final int? id;

  final int userId;

  final double amount;

  final String category;

  final DateTime date;

  final String? note;

  final DateTime? createdAt;

  const Expense({
    this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.createdAt,
  });

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'amount': amount,
    'category': category,
    'date': formatDateOnly(date),
    'note': note,
    if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
  };

  factory Expense.fromMap(Map<String, Object?> map) => Expense(
    id: map['id'] as int?,
    userId: map['user_id'] as int,
    amount: (map['amount'] as num).toDouble(),
    category: map['category'] as String,
    date: DateTime.parse(map['date'] as String),
    note: map['note'] as String?,
    createdAt: parseIsoOrNull(map['created_at'] as String?),
  );

  Expense copyWith({
    int? id,
    int? userId,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    bool clearNote = false,
    DateTime? createdAt,
  }) => Expense(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    date: date ?? this.date,
    note: clearNote ? null : (note ?? this.note),
    createdAt: createdAt ?? this.createdAt,
  );
}
