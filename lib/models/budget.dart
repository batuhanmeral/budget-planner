import '../utils/date_utils.dart';

/// Kullanıcının bir kategori için belirlediği aylık bütçe hedefini
/// temsil eden immutable veri sınıfı.
///
/// SQLite'taki `budgets` tablosuyla eşleşir. `UNIQUE(user_id, category)`
/// kısıtı sayesinde bir kullanıcının aynı kategori için tek bütçesi
/// olabilir; tekrar girilince upsert ile güncellenir.
class Budget {
  /// Birincil anahtar. Yeni bütçelerde null.
  final int? id;

  /// Bütçenin sahibi olan kullanıcının ID'si.
  final int userId;

  /// Hangi kategori için limit (örn. "Yemek").
  final String category;

  /// Aylık üst sınır (TL). 0'dan büyük olmalı — DB'de CHECK ile zorlu.
  final double monthlyLimit;

  /// Son güncelleme zamanı (UTC). Upsert sırasında otomatik tazelenir.
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
