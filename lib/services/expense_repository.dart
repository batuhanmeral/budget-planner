import '../models/expense.dart';
import '../utils/date_utils.dart';
import '../utils/money_utils.dart';
import 'database_service.dart';

/// Harcama listesinin sıralama seçenekleri.
///
/// UI'daki sıralama menüsünden geliyor. Enum kullanılarak SQL injection
/// önleniyor — kullanıcının yazdığı bir string ORDER BY'a girmiyor.
enum ExpenseSort { dateDesc, dateAsc, amountDesc, amountAsc, category }

extension on ExpenseSort {
  /// Her enum değerinin karşılığı olan SQL ORDER BY ifadesi.
  /// `id DESC` ikincil anahtar: aynı tarihte birden fazla harcama varsa
  /// yeni eklenen üstte görünür.
  String get sql {
    switch (this) {
      case ExpenseSort.dateDesc:
        return 'date DESC, id DESC';
      case ExpenseSort.dateAsc:
        return 'date ASC, id ASC';
      case ExpenseSort.amountDesc:
        return 'amount DESC, id DESC';
      case ExpenseSort.amountAsc:
        return 'amount ASC, id ASC';
      case ExpenseSort.category:
        return 'category ASC, date DESC';
    }
  }
}

/// Bir gün için toplam harcama. Dashboard'daki haftalık bar grafiği bu
/// listeyi tüketir.
class DailyTotal {
  final DateTime date;
  final double total;
  const DailyTotal(this.date, this.total);
}

/// Bir ay için toplam harcama. Yıllık bar grafiğinde her sütun bir
/// [MonthTotal]'dir.
class MonthTotal {
  final int month; // 1-12
  final double total;
  const MonthTotal({required this.month, required this.total});
}

/// `expenses` tablosu için CRUD + sorgu metodları.
///
/// **Tüm metodlar `userId` parametresi alır** ve sorgularına
/// `WHERE user_id = ?` ekler. Bu, veri izolasyon kuralının taşıyıcısıdır;
/// bir kullanıcı asla başka kullanıcının verisini göremez/değiştiremez.
class ExpenseRepository {
  ExpenseRepository._();
  static final instance = ExpenseRepository._();

  /// Yeni harcama ekler. `created_at` UTC olarak set edilir, ID DB'den
  /// AUTOINCREMENT olarak gelir.
  Future<int> insert(Expense expense) async {
    final db = await DatabaseService.instance.database;
    final data = expense.toMap()..['created_at'] = nowUtcIso();
    return db.insert('expenses', data);
  }

  /// Mevcut harcamayı günceller. `id == null` ise programcı hatası
  /// (ekleme yerine güncelleme çağrılmış) — ArgumentError.
  ///
  /// WHERE koşulu hem `id` hem `user_id`'yi içerir: başka kullanıcının
  /// kaydı yanlışlıkla güncellenmez.
  Future<int> update(Expense expense) async {
    if (expense.id == null) {
      throw ArgumentError('update için id zorunlu');
    }
    final db = await DatabaseService.instance.database;
    final data = expense.toMap()..remove('id');
    return db.update(
      'expenses',
      data,
      where: 'id = ? AND user_id = ?',
      whereArgs: [expense.id, expense.userId],
    );
  }

  /// Tek harcama silme. `user_id` koşulu sahiplik güvencesidir.
  Future<int> delete({required int id, required int userId}) async {
    final db = await DatabaseService.instance.database;
    return db.delete(
      'expenses',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  /// "Tüm harcamalarımı sil" akışı için — yalnızca aktif kullanıcının
  /// kayıtları silinir, bütçeleri korunur.
  Future<int> deleteAllForUser(int userId) async {
    final db = await DatabaseService.instance.database;
    return db.delete('expenses', where: 'user_id = ?', whereArgs: [userId]);
  }

  /// Tek bir harcamayı detay ekranı için yükler.
  Future<Expense?> getById({required int id, required int userId}) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'expenses',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Expense.fromMap(rows.first);
  }

  /// Kullanıcının tüm harcamaları — yeni tarihler üstte.
  Future<List<Expense>> getAllForUser(int userId) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'expenses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  /// İki tarih arasındaki harcamalar (inclusive). Dashboard ve filtre
  /// için kullanılır.
  Future<List<Expense>> getByDateRange({
    required int userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'expenses',
      where: 'user_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [userId, formatDateOnly(from), formatDateOnly(to)],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  /// Tek bir kategorideki harcamalar.
  Future<List<Expense>> getByCategory({
    required int userId,
    required String category,
  }) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      'expenses',
      where: 'user_id = ? AND category = ?',
      whereArgs: [userId, category],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  /// Belirtilen ayın toplam harcaması. Dashboard'daki "Bu ay toplam"
  /// ve aylık karşılaştırma için kullanılır.
  ///
  /// SQL'de `LIKE '2026-05%'` ile filtreliyoruz; `date` formatı
  /// `YYYY-MM-DD` olduğu için bu prefix güvenli ve hızlı.
  /// `COALESCE` boş sonuçta 0 döner.
  Future<double> getMonthlyTotal({
    required int userId,
    required int year,
    required int month,
  }) async {
    final db = await DatabaseService.instance.database;
    final prefix = '${monthPrefix(year, month)}%';
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM expenses '
      'WHERE user_id = ? AND date LIKE ?',
      [userId, prefix],
    );
    final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
    return roundMoney(total);
  }

  /// Kategori bazında aylık toplam (dashboard dağılım listesi ve bütçe
  /// doluluk hesabı için). Sadece harcama yapılmış kategoriler dönüş
  /// haritasında bulunur.
  Future<Map<String, double>> getMonthlyTotalByCategory({
    required int userId,
    required int year,
    required int month,
  }) async {
    final db = await DatabaseService.instance.database;
    final prefix = '${monthPrefix(year, month)}%';
    final rows = await db.rawQuery(
      'SELECT category, SUM(amount) AS total FROM expenses '
      'WHERE user_id = ? AND date LIKE ? '
      'GROUP BY category',
      [userId, prefix],
    );
    return {
      for (final r in rows)
        r['category'] as String: roundMoney((r['total'] as num).toDouble()),
    };
  }

  /// Son N günün günlük toplamları. Haftalık bar grafiği için.
  ///
  /// DB harcama olmayan günleri döndürmez; bu yüzden sonra 0'larla
  /// doldurulur — grafik her gün için bir bar göstermek zorunda.
  /// Belirli bir yılın 12 ayı için toplam harcama listesi (Ocak..Aralık).
  ///
  /// SQL `substr(date, 6, 2)` ile ay parçası çekilir; `date` formatı
  /// `YYYY-MM-DD` olduğu için bu güvenli. Harcama olmayan aylar için
  /// 0 ile doldurulur — grafik her ayı göstersin diye.
  Future<List<MonthTotal>> getYearlyTotalsByMonth({
    required int userId,
    required int year,
  }) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.rawQuery(
      "SELECT substr(date, 6, 2) AS m, SUM(amount) AS total FROM expenses "
      "WHERE user_id = ? AND date LIKE ? "
      "GROUP BY m",
      [userId, '$year-%'],
    );
    final byMonth = <int, double>{
      for (final r in rows)
        int.parse(r['m'] as String): roundMoney(
          (r['total'] as num).toDouble(),
        ),
    };
    return List.generate(
      12,
      (i) => MonthTotal(month: i + 1, total: byMonth[i + 1] ?? 0.0),
    );
  }

  Future<List<DailyTotal>> getDailyTotalsForLastNDays({
    required int userId,
    required int days,
  }) async {
    final db = await DatabaseService.instance.database;
    final today = stripTime(DateTime.now());
    final from = today.subtract(Duration(days: days - 1));
    final rows = await db.rawQuery(
      'SELECT date, SUM(amount) AS total FROM expenses '
      'WHERE user_id = ? AND date BETWEEN ? AND ? '
      'GROUP BY date',
      [userId, formatDateOnly(from), formatDateOnly(today)],
    );
    // DB sonucu önce map'e alıp, sonra tüm günleri (boş olanlar dahil)
    // sırayla üret.
    final byDate = <String, double>{
      for (final r in rows)
        r['date'] as String: roundMoney((r['total'] as num).toDouble()),
    };
    final result = <DailyTotal>[];
    for (var i = 0; i < days; i++) {
      final d = from.add(Duration(days: i));
      final key = formatDateOnly(d);
      result.add(DailyTotal(d, byDate[key] ?? 0.0));
    }
    return result;
  }

  /// Açıklamada metin arama (case-insensitive LIKE).
  ///
  /// LIKE pattern'ında `%` ve `_` özel karakterleri vardır; kullanıcı
  /// notuna "%50 indirim" gibi bir şey yazmışsa olduğu gibi aranmalı.
  /// Bu yüzden bu karakterler `\` ile escape edilir ve `ESCAPE '\'`
  /// clause kullanılır.
  Future<List<Expense>> search({
    required int userId,
    required String query,
  }) async {
    if (query.trim().isEmpty) return getAllForUser(userId);
    final db = await DatabaseService.instance.database;
    final escaped = query
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    final pattern = '%$escaped%';
    final rows = await db.rawQuery(
      "SELECT * FROM expenses "
      "WHERE user_id = ? AND note LIKE ? ESCAPE '\\' "
      "ORDER BY date DESC, id DESC",
      [userId, pattern],
    );
    return rows.map(Expense.fromMap).toList();
  }

  /// Liste ekranı için tek noktadan filtre + sıralama.
  ///
  /// Tüm filtre alanları opsiyoneldir — verilenler WHERE'e eklenir.
  /// ORDER BY [ExpenseSort] enum'ından geldiği için SQL injection
  /// imkansız.
  Future<List<Expense>> getFilteredAndSorted({
    required int userId,
    String? category,
    DateTime? from,
    DateTime? to,
    String? noteQuery,
    ExpenseSort sort = ExpenseSort.dateDesc,
  }) async {
    final db = await DatabaseService.instance.database;
    final where = <String>['user_id = ?'];
    final args = <Object?>[userId];

    if (category != null) {
      where.add('category = ?');
      args.add(category);
    }
    if (from != null) {
      where.add('date >= ?');
      args.add(formatDateOnly(from));
    }
    if (to != null) {
      where.add('date <= ?');
      args.add(formatDateOnly(to));
    }
    if (noteQuery != null && noteQuery.trim().isNotEmpty) {
      // LIKE özel karakterleri escape — search() ile aynı strateji.
      final escaped = noteQuery
          .replaceAll(r'\', r'\\')
          .replaceAll('%', r'\%')
          .replaceAll('_', r'\_');
      where.add("note LIKE ? ESCAPE '\\'");
      args.add('%$escaped%');
    }

    final rows = await db.query(
      'expenses',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: sort.sql,
    );
    return rows.map(Expense.fromMap).toList();
  }
}
