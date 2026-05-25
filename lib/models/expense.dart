import '../utils/date_utils.dart';

/// Tek bir harcama kaydını temsil eden immutable veri sınıfı.
///
/// SQLite'taki `expenses` tablosuyla birebir eşleşir. Her harcama bir
/// kullanıcıya bağlıdır ([userId]) ve kullanıcı silindiğinde cascade
/// ile birlikte düşer.
class Expense {
  /// Birincil anahtar. Yeni harcamalarda null.
  final int? id;

  /// Sahibi olan kullanıcının ID'si. Asla null olmamalıdır.
  final int userId;

  /// Tutar (TL). 0'dan büyük olmalıdır — CHECK kısıtı DB seviyesinde de
  /// var. UI'da [roundMoney] ile 2 ondalığa yuvarlanır.
  final double amount;

  /// Kategori adı (örn. "Yemek"). [AppCategories.all] içindeki bir
  /// kategorinin ismiyle eşleşmesi beklenir.
  final String category;

  /// Harcamanın gerçekleştiği tarih. Saat bilgisi YOK — DB'ye yazılırken
  /// [formatDateOnly] ile `YYYY-MM-DD` formatına indirgenir.
  final DateTime date;

  /// Opsiyonel kullanıcı notu (max 200 karakter, validator'da sınır var).
  final String? note;

  /// Kaydın oluşturulma zamanı (UTC). DB tarafından `CURRENT_TIMESTAMP`
  /// olarak set edilir.
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

  /// SQLite insert/update için Map.
  ///
  /// `id` null ise eklenmez. `date` her zaman saatsiz YYYY-MM-DD olarak
  /// yazılır — ay/hafta LIKE filtreleri buna bağımlı.
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

  /// Belirli alanları değiştirilmiş kopya. [clearNote] true ise notu
  /// zorla null'a çeker (kullanıcı not alanını boşaltıp kaydederse).
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
