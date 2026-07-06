import 'package:budget_planner/utils/money_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('roundMoney', () {
    test('handles double precision drift', () {
      expect(roundMoney(0.1 + 0.2), 0.3);
    });

    test('rounds to 2 decimals', () {
      expect(roundMoney(12.345), 12.35);
      expect(roundMoney(12.344), 12.34);
    });
  });

  group('parseMoneyInput', () {
    test('accepts dot decimal', () {
      expect(parseMoneyInput('12.50'), 12.5);
    });

    test('accepts Turkish comma decimal', () {
      expect(parseMoneyInput('12,50'), 12.5);
    });

    test('trims whitespace', () {
      expect(parseMoneyInput('  7,25  '), 7.25);
    });

    test('returns null for invalid input', () {
      expect(parseMoneyInput('abc'), isNull);
      expect(parseMoneyInput(''), isNull);
      expect(parseMoneyInput(null), isNull);
    });
  });

  test('sumAmounts rounds the result', () {
    expect(sumAmounts([0.1, 0.2, 0.3]), 0.6);
  });
}
