class Currency {
  final String code;

  final String symbol;

  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

class Currencies {
  Currencies._();

  static const tryLira = Currency(
    code: 'TRY',
    symbol: '₺',
    name: 'Türk Lirası',
  );
  static const usd = Currency(code: 'USD', symbol: '\$', name: 'US Dollar');
  static const eur = Currency(code: 'EUR', symbol: '€', name: 'Euro');
  static const gbp = Currency(code: 'GBP', symbol: '£', name: 'British Pound');
  static const jpy = Currency(code: 'JPY', symbol: '¥', name: 'Japanese Yen');

  static const all = <Currency>[tryLira, usd, eur, gbp, jpy];

  static const fallback = tryLira;

  static Currency byCode(String? code) {
    return all.firstWhere((c) => c.code == code, orElse: () => fallback);
  }
}
