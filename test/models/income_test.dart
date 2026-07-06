import 'package:budget_planner/models/income.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Income.toMap / fromMap', () {
    test('roundtrip alanları korur ve tarihi saatsiz yazar', () {
      final income = Income(
        id: 7,
        userId: 3,
        amount: 1500.50,
        source: 'Maaş',
        date: DateTime(2026, 6, 13, 14, 30),
        note: 'Haziran maaşı',
      );
      final map = income.toMap();
      expect(map['date'], '2026-06-13');
      expect(map['amount'], 1500.50);
      expect(map['source'], 'Maaş');

      final back = Income.fromMap(map);
      expect(back.id, 7);
      expect(back.userId, 3);
      expect(back.amount, 1500.50);
      expect(back.source, 'Maaş');
      expect(back.note, 'Haziran maaşı');
      expect(back.date, DateTime(2026, 6, 13));
    });

    test('id null olduğunda map\'e eklenmez (AUTOINCREMENT için)', () {
      final income = Income(
        userId: 1,
        amount: 100,
        source: 'Hediye',
        date: DateTime(2026, 1, 1),
      );
      expect(income.toMap().containsKey('id'), isFalse);
    });
  });

  group('Income.copyWith', () {
    final base = Income(
      id: 1,
      userId: 1,
      amount: 200,
      source: 'Ek Gelir',
      date: DateTime(2026, 5, 5),
      note: 'eski not',
    );

    test('verilen alanı değiştirir, gerisini korur', () {
      final updated = base.copyWith(amount: 350);
      expect(updated.amount, 350);
      expect(updated.source, 'Ek Gelir');
      expect(updated.note, 'eski not');
    });

    test('clearNote notu zorla null yapar', () {
      final cleared = base.copyWith(clearNote: true);
      expect(cleared.note, isNull);
    });
  });
}
