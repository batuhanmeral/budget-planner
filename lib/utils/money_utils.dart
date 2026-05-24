/// Para işlemleri için yardımcılar.
///
/// Tutar [REAL] olarak saklandığı için double aritmetiği küçük hatalar verir
/// (`0.1 + 0.2 != 0.3`). [roundMoney] her toplam/oran/UI gösteriminde kullanılır.
double roundMoney(double v) => (v * 100).round() / 100;

/// Türkçe kullanıcı genelde virgüllü tutar girer (`12,50`).
/// `double.parse` virgül kabul etmediği için normalize edilir.
double? parseMoneyInput(String? raw) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final normalized = trimmed.replaceAll(',', '.');
  final parsed = double.tryParse(normalized);
  if (parsed == null) return null;
  return roundMoney(parsed);
}

double sumAmounts(Iterable<double> amounts) {
  var total = 0.0;
  for (final a in amounts) {
    total += a;
  }
  return roundMoney(total);
}
