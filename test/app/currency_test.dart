import 'package:balancio/app/currency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Currencies.byCode', () {
    test('bilinen kodu doğru para birimine çevirir', () {
      expect(Currencies.byCode('USD'), Currencies.usd);
      expect(Currencies.byCode('EUR').symbol, '€');
      expect(Currencies.byCode('TRY').symbol, '₺');
    });

    test('bilinmeyen veya null kod için fallback (TRY) döner', () {
      expect(Currencies.byCode('XYZ'), Currencies.fallback);
      expect(Currencies.byCode(null), Currencies.fallback);
      expect(Currencies.fallback, Currencies.tryLira);
    });

    test('tüm katalog kodları benzersiz', () {
      final codes = Currencies.all.map((c) => c.code).toList();
      expect(codes.toSet().length, codes.length);
    });
  });
}
