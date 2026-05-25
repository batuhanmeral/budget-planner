import 'package:intl/intl.dart';

import '../app/app_constants.dart';

/// Para birimi ve tarih gibi değerleri Türkçe locale'e göre biçimlendirir.
///
/// `intl` paketinin [NumberFormat] ve [DateFormat] sınıflarını sarmalayarak
/// uygulamanın her yerinde tek bir görsel tutarlılık sağlar. Format
/// nesneleri pahalı oluşturulduğu için statik final olarak tutulur.
class Formatters {
  Formatters._();

  // Para birimi: "1.234,56 ₺" formatında. Türkçe locale binlik ayracı
  // nokta, ondalık ayracı virgül olarak basar.
  static final NumberFormat _money = NumberFormat.currency(
    locale: AppStrings.locale,
    symbol: AppStrings.currencySymbol,
    decimalDigits: 2,
  );

  // "25 Mayıs 2026" gibi uzun tarih (detay ekranlarında).
  static final DateFormat _longDate = DateFormat('d MMMM y', AppStrings.locale);

  // "25 May 2026" gibi kısa tarih (listelerde kompakt görünüm için).
  static final DateFormat _shortDate = DateFormat('d MMM y', AppStrings.locale);

  /// Tutarı "1.234,56 ₺" gibi Türkçe para birimi formatında döner.
  static String money(double amount) => _money.format(amount);

  /// Tarihi "25 Mayıs 2026" formatında döner.
  static String dateLong(DateTime d) => _longDate.format(d);

  /// Tarihi "25 May 2026" formatında döner — daha az yer kaplar.
  static String dateShort(DateTime d) => _shortDate.format(d);
}
