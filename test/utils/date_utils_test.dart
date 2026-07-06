import 'package:budget_planner/utils/date_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stripTime drops hour/minute', () {
    final d = DateTime(2026, 5, 25, 14, 30, 45);
    final s = stripTime(d);
    expect(s.hour, 0);
    expect(s.minute, 0);
    expect(s.second, 0);
  });

  test('formatDateOnly returns YYYY-MM-DD', () {
    expect(formatDateOnly(DateTime(2026, 5, 3)), '2026-05-03');
  });

  test('startOfMonth is the first day', () {
    expect(startOfMonth(DateTime(2026, 5, 25)), DateTime(2026, 5, 1));
  });

  test('endOfMonth handles December rollover', () {
    final e = endOfMonth(DateTime(2026, 12, 15));
    expect(e.year, 2026);
    expect(e.month, 12);
    expect(e.day, 31);
  });

  test('startOfWeek is Monday', () {
    expect(startOfWeek(DateTime(2026, 5, 25)).weekday, DateTime.monday);
    expect(startOfWeek(DateTime(2026, 5, 31)), DateTime(2026, 5, 25));
  });

  test('monthPrefix pads month', () {
    expect(monthPrefix(2026, 5), '2026-05');
    expect(monthPrefix(2026, 12), '2026-12');
  });
}
