import 'package:intl/intl.dart';

import '../app/app_constants.dart';

/// Türkçe formatlama yardımcıları.
class Formatters {
  Formatters._();

  static final NumberFormat _money = NumberFormat.currency(
    locale: AppStrings.locale,
    symbol: AppStrings.currencySymbol,
    decimalDigits: 2,
  );

  static final DateFormat _longDate = DateFormat('d MMMM y', AppStrings.locale);
  static final DateFormat _shortDate = DateFormat('d MMM y', AppStrings.locale);

  static String money(double amount) => _money.format(amount);

  static String dateLong(DateTime d) => _longDate.format(d);

  static String dateShort(DateTime d) => _shortDate.format(d);
}
