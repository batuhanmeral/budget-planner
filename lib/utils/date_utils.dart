/// Tarih ile ilgili tüm yardımcı fonksiyonların toplandığı dosya.
///
/// Bu uygulamadaki tarih kuralları:
///
/// 1. **Harcama tarihleri** sadece günü ifade eder (saat YOK). DB'ye
///    yazılmadan önce mutlaka [stripTime] ile indirgenir; aksi takdirde
///    `showDatePicker`'ın döndürdüğü saat alanı sızıntı yapar ve
///    `WHERE date LIKE '2026-05%'` gibi ay filtreleri tutarsızlaşır.
///
/// 2. **Zaman damgaları** (created_at, lockout_until) **UTC** olarak
///    saklanır. SQLite'ın `CURRENT_TIMESTAMP` fonksiyonu UTC döner;
///    Dart tarafında da [nowUtcIso] ile UTC ISO-8601 yazılır. Lokal
///    saatle UTC karıştırılırsa lockout karşılaştırması yanlış çalışır.
///
/// 3. **"Bu Hafta"** Pazartesi 00:00 → Pazar 23:59:59.999 olarak
///    tanımlanır (ISO 8601 ve TR standardı).
library;

/// [d] tarihinin saat bilgisini sıfırlar.
///
/// `showDatePicker` saatli `DateTime` döndüğü için DB'ye yazmadan önce
/// kullanılır. Ay/hafta filtrelerinin doğru çalışması bu indirgemeye bağlı.
DateTime stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

/// Şu anki UTC zamanını ISO-8601 string olarak döner.
///
/// `created_at`, `updated_at` ve `lockout_until` alanları her zaman
/// bu fonksiyondan üretilir.
String nowUtcIso() => DateTime.now().toUtc().toIso8601String();

/// ISO-8601 string'i [DateTime]'a parse eder; başarısızsa `null` döner.
///
/// Model sınıflarının `fromMap` fabrikalarında null alanları (`lockout_until`,
/// `created_at`) güvenli parse için kullanılır.
DateTime? parseIsoOrNull(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

/// [d] tarihini `YYYY-MM-DD` formatında string'e çevirir.
///
/// SQLite tarafında `expenses.date` bu formatta saklanır. Saat bilgisi
/// otomatik olarak [stripTime] ile düşürülür.
String formatDateOnly(DateTime d) {
  final local = stripTime(d);
  final m = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$m-$day';
}

/// [d]'nin ait olduğu ayın 1'i (00:00) — örn. 2026-05-25 → 2026-05-01.
DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

/// [d]'nin ait olduğu ayın son anı (23:59:59.999).
///
/// Aralık inclusive olduğu için "bir sonraki ayın 1'inden 1 ms önce"
/// formülü kullanılır. Aralık ayında yıl artar.
DateTime endOfMonth(DateTime d) {
  // Ay aşımı: Aralık ayında bir sonraki yıla geç.
  final firstOfNext = (d.month == 12)
      ? DateTime(d.year + 1, 1, 1)
      : DateTime(d.year, d.month + 1, 1);
  return firstOfNext.subtract(const Duration(milliseconds: 1));
}

/// [d]'nin ait olduğu haftanın Pazartesisi (00:00).
///
/// Dart'ta `DateTime.weekday` Pazartesi=1 ... Pazar=7 değerini döner.
/// Pazartesi'ye geri saymak için aradaki gün farkı kadar çıkarılır.
DateTime startOfWeek(DateTime d) {
  final clean = stripTime(d);
  final diff = clean.weekday - DateTime.monday;
  return clean.subtract(Duration(days: diff));
}

/// [d]'nin ait olduğu haftanın Pazar günü son anı (23:59:59.999).
DateTime endOfWeek(DateTime d) {
  final start = startOfWeek(d);
  return start
      .add(const Duration(days: 7))
      .subtract(const Duration(milliseconds: 1));
}

/// SQLite'ta `WHERE date LIKE ?` ile aylık filtreleme için kullanılan
/// prefix. Örnek: `monthPrefix(2026, 5)` → `'2026-05'`.
///
/// Ay tek haneli ise başına `0` eklenir; tarih formatıyla tutarlılık
/// için kritik.
String monthPrefix(int year, int month) {
  final m = month.toString().padLeft(2, '0');
  return '$year-$m';
}
