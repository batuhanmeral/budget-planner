// Para işlemleri için yardımcı fonksiyonlar.
//
// SQLite tablosunda amount REAL (double) olarak saklandığı için Dart'taki
// kayan nokta aritmetiği küçük yuvarlama hataları yapabilir. Örneğin
// 0.1 + 0.2 sonucu 0.30000000000000004 olur. Bu modül hem girdiyi
// normalize eder hem de toplam/oran hesaplarında 2 ondalığa yuvarlar.

/// [v] değerini 2 ondalık basamağa yuvarlar.
///
/// Toplama yaparken veya UI'da göstermeden önce mutlaka bu fonksiyondan
/// geçirilir. Aksi takdirde "12,30 TL" yerine "12,29999... TL" gibi
/// tutarsız görüntüler oluşur.
double roundMoney(double v) => (v * 100).round() / 100;

/// Kullanıcının form alanına yazdığı metni double'a dönüştürür.
///
/// Türkiye'de ondalık ayracı virgüldür (`12,50`) — fakat [double.tryParse]
/// yalnızca noktayı kabul eder. Bu fonksiyon önce virgülü noktaya çevirir,
/// sonra parse eder, son olarak [roundMoney] ile yuvarlar.
///
/// Geçersiz girdi (null, boş veya sayı olmayan) için `null` döner.
double? parseMoneyInput(String? raw) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  // Türkçe virgül desteği: "12,50" -> "12.50"
  final normalized = trimmed.replaceAll(',', '.');
  final parsed = double.tryParse(normalized);
  if (parsed == null) return null;
  return roundMoney(parsed);
}

/// Bir tutar listesinin toplamını yuvarlanmış olarak döner.
///
/// Her ara toplamı tekrar tekrar yuvarlamak yerine tek seferde sonu
/// yuvarlamak daha doğru sonuç verir.
double sumAmounts(Iterable<double> amounts) {
  var total = 0.0;
  for (final a in amounts) {
    total += a;
  }
  return roundMoney(total);
}
