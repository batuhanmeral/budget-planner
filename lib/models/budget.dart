import '../utils/date_utils.dart';

class Budget {
  final int? id;
  final int userId;
  final String category;
  final double monthlyLimit;
  final DateTime? updatedAt;

  const Budget({
    this.id,
    required this.userId,
    required this.category,
    required this.monthlyLimit,
    this.updatedAt,
  });

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'category': category,
    'monthly_limit': monthlyLimit,
    if (updatedAt != null) 'updated_at': updatedAt!.toUtc().toIso8601String(),
  };

  factory Budget.fromMap(Map<String, Object?> map) => Budget(
    id: map['id'] as int?,
    userId: map['user_id'] as int,
    category: map['category'] as String,
    monthlyLimit: (map['monthly_limit'] as num).toDouble(),
    updatedAt: parseIsoOrNull(map['updated_at'] as String?),
  );

  Budget copyWith({
    int? id,
    int? userId,
    String? category,
    double? monthlyLimit,
    DateTime? updatedAt,
  }) => Budget(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    category: category ?? this.category,
    monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
