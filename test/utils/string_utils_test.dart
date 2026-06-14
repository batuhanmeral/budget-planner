import 'package:balancio/utils/string_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeIdentifier', () {
    test('Turkish capital İ matches lowercase i', () {
      expect(normalizeIdentifier('İSTANBUL'), normalizeIdentifier('istanbul'));
    });

    test('handles ı/I correctly', () {
      expect(normalizeIdentifier('Iğdır'), 'igdir');
    });

    test('trims and lowercases', () {
      expect(normalizeIdentifier('  Ali  '), 'ali');
    });

    test('strips Turkish diacritics for comparison', () {
      expect(normalizeIdentifier('Çiçek'), 'cicek');
      expect(normalizeIdentifier('Öğretmen'), 'ogretmen');
    });
  });
}
