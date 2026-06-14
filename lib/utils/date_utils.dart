library;

DateTime stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

String nowUtcIso() => DateTime.now().toUtc().toIso8601String();

DateTime? parseIsoOrNull(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

String formatDateOnly(DateTime d) {
  final local = stripTime(d);
  final m = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$m-$day';
}

DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

DateTime endOfMonth(DateTime d) {
  final firstOfNext = (d.month == 12)
      ? DateTime(d.year + 1, 1, 1)
      : DateTime(d.year, d.month + 1, 1);
  return firstOfNext.subtract(const Duration(milliseconds: 1));
}

DateTime startOfWeek(DateTime d) {
  final clean = stripTime(d);
  final diff = clean.weekday - DateTime.monday;
  return clean.subtract(Duration(days: diff));
}

DateTime endOfWeek(DateTime d) {
  final start = startOfWeek(d);
  return start
      .add(const Duration(days: 7))
      .subtract(const Duration(milliseconds: 1));
}

String monthPrefix(int year, int month) {
  final m = month.toString().padLeft(2, '0');
  return '$year-$m';
}
