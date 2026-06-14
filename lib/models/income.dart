import '../utils/date_utils.dart';

class Income {
  final int? id;

  final int userId;

  final double amount;

  final String source;

  final DateTime date;

  final String? note;

  final DateTime? createdAt;

  const Income({
    this.id,
    required this.userId,
    required this.amount,
    required this.source,
    required this.date,
    this.note,
    this.createdAt,
  });

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'amount': amount,
    'source': source,
    'date': formatDateOnly(date),
    'note': note,
    if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
  };

  factory Income.fromMap(Map<String, Object?> map) => Income(
    id: map['id'] as int?,
    userId: map['user_id'] as int,
    amount: (map['amount'] as num).toDouble(),
    source: map['source'] as String,
    date: DateTime.parse(map['date'] as String),
    note: map['note'] as String?,
    createdAt: parseIsoOrNull(map['created_at'] as String?),
  );

  Income copyWith({
    int? id,
    int? userId,
    double? amount,
    String? source,
    DateTime? date,
    String? note,
    bool clearNote = false,
    DateTime? createdAt,
  }) => Income(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    amount: amount ?? this.amount,
    source: source ?? this.source,
    date: date ?? this.date,
    note: clearNote ? null : (note ?? this.note),
    createdAt: createdAt ?? this.createdAt,
  );
}
