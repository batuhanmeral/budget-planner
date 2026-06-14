double roundMoney(double v) => (v * 100).round() / 100;

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
