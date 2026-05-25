import 'package:budget_planner/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('moneyAmount', () {
    test('accepts Turkish comma', () {
      expect(Validators.moneyAmount('12,50'), isNull);
    });

    test('rejects zero and negatives', () {
      expect(Validators.moneyAmount('0'), isNotNull);
      expect(Validators.moneyAmount('-5'), isNotNull);
    });

    test('rejects garbage', () {
      expect(Validators.moneyAmount('abc'), isNotNull);
      expect(Validators.moneyAmount(''), isNotNull);
    });
  });

  group('username', () {
    test('accepts 3-20 alnum/underscore', () {
      expect(Validators.username('ali_123'), isNull);
    });

    test('rejects short or invalid characters', () {
      expect(Validators.username('ab'), isNotNull);
      expect(Validators.username('ali star'), isNotNull);
    });
  });

  group('password', () {
    test('requires letter and digit, min 6', () {
      expect(Validators.password('abc123'), isNull);
      expect(Validators.password('abcdef'), isNotNull);
      expect(Validators.password('123456'), isNotNull);
      expect(Validators.password('a1'), isNotNull);
    });
  });

  test('passwordMatch', () {
    expect(Validators.passwordMatch('abc123', 'abc123'), isNull);
    expect(Validators.passwordMatch('abc123', 'xyz123'), isNotNull);
  });
}
