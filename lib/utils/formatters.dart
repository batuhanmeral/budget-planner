import 'package:intl/intl.dart';

import '../app/app_constants.dart';

/// Para birimi ve tarih gibi değerleri aktif locale'e göre biçimlendirir.
///
/// `intl` paketinin [NumberFormat] ve [DateFormat] sınıflarını sarmalayarak
/// uygulamanın her yerinde tek bir görsel tutarlılık sağlar.
///
/// **Dinamik locale:** Çoklu dil için her çağrıda `Intl.defaultLocale`
/// okunarak formatter yaratılır. Bu sayede [LocaleController.setLocale]
/// sonrası tüm formatlamalar yeni dile geçer.
class Formatters {
  Formatters._();

  /// Tutarı "1.234,56 ₺" (TR) veya "1,234.56 ₺" (EN) formatında döner.
  /// Para birimi sembolü her dilde ₺ — uygulama Türkçe finansa odaklı.
  static String money(double amount) {
    return NumberFormat.currency(
      locale: Intl.defaultLocale,
      symbol: AppStrings.currencySymbol,
      decimalDigits: 2,
    ).format(amount);
  }

  /// Tarihi "25 Mayıs 2026" (TR) veya "May 25, 2026" (EN) formatında döner.
  static String dateLong(DateTime d) =>
      DateFormat.yMMMMd(Intl.defaultLocale).format(d);

  /// Tarihi "25 May 2026" (TR) veya "May 25, 2026" (EN) — kısa görünüm.
  static String dateShort(DateTime d) =>
      DateFormat.yMMMd(Intl.defaultLocale).format(d);
}
