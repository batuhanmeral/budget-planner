import 'package:intl/intl.dart';

import '../app/currency_controller.dart';

class Formatters {
  Formatters._();

  static String money(double amount) {
    return NumberFormat.currency(
      locale: Intl.defaultLocale,
      symbol: CurrencyController.instance.symbol,
      decimalDigits: 2,
    ).format(amount);
  }

  static String dateLong(DateTime d) =>
      DateFormat.yMMMMd(Intl.defaultLocale).format(d);

  static String dateShort(DateTime d) =>
      DateFormat.yMMMd(Intl.defaultLocale).format(d);
}
