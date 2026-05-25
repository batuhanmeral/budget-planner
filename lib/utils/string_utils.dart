// Türkçe metin karşılaştırması için yardımcılar.
//
// Dart'ın String.toLowerCase() metodu Türkçe locale-aware değildir.
// Örneğin "İSTANBUL".toLowerCase() sonucu "i̇stanbul" olur (i karakterine
// üst nokta combining character olarak eklenir). Bu durumda "istanbul"
// ile karşılaştırma başarısız olur.
//
// Çözüm: Türkçe karakterleri ASCII karşılıklarına dönüştürüp sonra
// lowercase yaparak güvenli bir karşılaştırma anahtarı üretmek.

/// Kullanıcı adı, güvenlik cevabı vb. alanları karşılaştırmaya hazırlar.
///
/// Türkçe karakterleri ASCII'ye çevirir, başındaki/sonundaki boşlukları
/// siler ve tümünü küçük harfe dönüştürür. Hem kayıt hem doğrulama
/// adımında aynı fonksiyon kullanılmalıdır; aksi takdirde "İSTANBUL"
/// ve "istanbul" eşleşmez.
///
/// Örnek:
/// ```
/// normalizeIdentifier('İSTANBUL') == normalizeIdentifier('istanbul')
/// ```
String normalizeIdentifier(String input) {
  // Türkçe karakter haritalaması — toLowerCase'in locale problemini bypass eder.
  final swapped = input
      .replaceAll('İ', 'i')
      .replaceAll('I', 'i')
      .replaceAll('ı', 'i')
      .replaceAll('Ş', 's')
      .replaceAll('ş', 's')
      .replaceAll('Ğ', 'g')
      .replaceAll('ğ', 'g')
      .replaceAll('Ü', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('Ö', 'o')
      .replaceAll('ö', 'o')
      .replaceAll('Ç', 'c')
      .replaceAll('ç', 'c');
  return swapped.trim().toLowerCase();
}
