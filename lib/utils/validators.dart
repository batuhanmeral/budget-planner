import 'money_utils.dart';

/// Form `validator` callback'leri için statik fonksiyonlar.
/// Hepsi `String?` alır, hata yoksa `null`, varsa Türkçe mesaj döner.
class Validators {
  Validators._();

  static final _usernameRegex = RegExp(r'^[A-Za-z0-9_]+$');
  static final _passwordLetterRegex = RegExp(r'[A-Za-z]');
  static final _passwordDigitRegex = RegExp(r'[0-9]');

  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan boş bırakılamaz';
    }
    return null;
  }

  static String? maxLength(String? value, int max) {
    if (value == null) return null;
    if (value.length > max) return 'En fazla $max karakter olabilir';
    return null;
  }

  static String? moneyAmount(String? value) {
    final required = requiredField(value);
    if (required != null) return required;
    final parsed = parseMoneyInput(value);
    if (parsed == null) return 'Geçerli bir tutar girin (örn. 12,50)';
    if (parsed <= 0) return 'Tutar 0\'dan büyük olmalı';
    return null;
  }

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

  static String? passwordMatch(String? value, String other) {
    final required = requiredField(value);
    if (required != null) return required;
    if (value != other) return 'Parolalar eşleşmiyor';
    return null;
  }

  static String? securityAnswer(String? value) {
    final required = requiredField(value);
    if (required != null) return required;
    if (value!.trim().length < 2) return 'En az 2 karakter girin';
    return null;
  }
}
