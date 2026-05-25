import 'money_utils.dart';

/// Form alanlarının [TextFormField.validator] callback'leri için statik
/// fonksiyon koleksiyonu.
///
/// Her fonksiyon `String?` alır ve standart Flutter convention'ına göre
/// hata yoksa `null`, varsa Türkçe hata mesajı döner. Tüm hata metinleri
/// kullanıcıya doğrudan gösterileceği için kibar ve net tutulmuştur.
class Validators {
  // Sınıfı namespacing için kullanıyoruz; instance oluşturulmasını engelle.
  Validators._();

  // Regex'ler bir kez derlensin diye static final olarak tutulur.
  static final _usernameRegex = RegExp(r'^[A-Za-z0-9_]+$');
  static final _passwordLetterRegex = RegExp(r'[A-Za-z]');
  static final _passwordDigitRegex = RegExp(r'[0-9]');

  /// Alan boş mu? `trim()` sonrası kontrol — sadece boşluk girilse de
  /// boş kabul edilir.
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan boş bırakılamaz';
    }
    return null;
  }

  /// Karakter sayısı sınırı. Notlar gibi serbest metin alanlarında
  /// veritabanı şişmesini engellemek için kullanılır.
  static String? maxLength(String? value, int max) {
    if (value == null) return null;
    if (value.length > max) return 'En fazla $max karakter olabilir';
    return null;
  }

  /// Para tutarı doğrulayıcı.
  ///
  /// Türkçe virgüllü (`12,50`) ve noktalı (`12.50`) girdileri kabul eder;
  /// parse [parseMoneyInput] üzerinden yapılır. 0 veya negatif değerleri
  /// reddeder — bütçe/harcama mantığında her ikisi de anlamsız.
  static String? moneyAmount(String? value) {
    final required = requiredField(value);
    if (required != null) return required;
    final parsed = parseMoneyInput(value);
    if (parsed == null) return 'Geçerli bir tutar girin (örn. 12,50)';
    if (parsed <= 0) return 'Tutar 0\'dan büyük olmalı';
    return null;
  }

  /// Kullanıcı adı kuralları:
  /// - 3-20 karakter uzunluk
  /// - Sadece harf, rakam ve alt çizgi
  ///
  /// Türkçe karakter veya boşluk içermez; çünkü insert sırasında
  /// `normalizeIdentifier` ile zaten ASCII'ye çevriliyor ve karşılaştırma
  /// tutarlılığı için bu sınırlama getirildi.
  static String? username(String? value) {
    final required = requiredField(value);
    if (required != null) return required;
    final v = value!.trim();
    if (v.length < 3 || v.length > 20) {
      return 'Kullanıcı adı 3-20 karakter olmalı';
    }
    if (!_usernameRegex.hasMatch(v)) {
      return 'Sadece harf, rakam ve alt çizgi kullanabilirsiniz';
    }
    return null;
  }

  /// Parola kuralları:
  /// - En az 6 karakter
  /// - En az 1 harf
  /// - En az 1 rakam
  ///
  /// Bu, ders projesi için makul bir minimum. Üretim uygulamasında çok
  /// daha sıkı kurallar (özel karakter, max uzunluk, common-password
  /// listesi vb.) eklenmelidir.
  static String? password(String? value) {
    final required = requiredField(value);
    if (required != null) return required;
    final v = value!;
    if (v.length < 6) return 'Parola en az 6 karakter olmalı';
    if (!_passwordLetterRegex.hasMatch(v)) {
      return 'Parola en az bir harf içermeli';
    }
    if (!_passwordDigitRegex.hasMatch(v)) {
      return 'Parola en az bir rakam içermeli';
    }
    return null;
  }

  /// Parola tekrar alanı için. İlk parolayı [other] olarak alır ve
  /// birebir eşitlik karşılaştırması yapar.
  static String? passwordMatch(String? value, String other) {
    final required = requiredField(value);
    if (required != null) return required;
    if (value != other) return 'Parolalar eşleşmiyor';
    return null;
  }

  /// Güvenlik sorusu cevabı için minimum 2 karakter ister.
  /// Cevap zaten salt+hash ile saklandığı için karakter setine
  /// sınır koymuyoruz.
  static String? securityAnswer(String? value) {
    final required = requiredField(value);
    if (required != null) return required;
    if (value!.trim().length < 2) return 'En az 2 karakter girin';
    return null;
  }
}
