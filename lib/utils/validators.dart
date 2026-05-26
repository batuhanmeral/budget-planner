import '../app/locale_controller.dart';
import '../l10n/app_l10n.dart';
import 'money_utils.dart';

/// Form alanlarının [TextFormField.validator] callback'leri için statik
/// fonksiyon koleksiyonu.
///
/// Hata mesajları aktif dile göre [LocaleController.instance.l10n]'dan
/// alınır. Bu sayede dil değişince validator mesajları da değişir.
class Validators {
  Validators._();

  static final _usernameRegex = RegExp(r'^[A-Za-z0-9_]+$');
  static final _passwordLetterRegex = RegExp(r'[A-Za-z]');
  static final _passwordDigitRegex = RegExp(r'[0-9]');

  static String _l(String Function(AppL10n l10n) f) =>
      f(LocaleController.instance.l10n);

  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _l((l) => l.vRequired);
    }
    return null;
  }

  static String? maxLength(String? value, int max) {
    if (value == null) return null;
    if (value.length > max) return _l((l) => l.vMaxLength(max));
    return null;
  }

  static String? moneyAmount(String? value) {
    final required = requiredField(value);
    if (required != null) return required;
    final parsed = parseMoneyInput(value);
    if (parsed == null) return _l((l) => l.vMoneyInvalid);
    if (parsed <= 0) return _l((l) => l.vMoneyPositive);
    return null;
  }

  static String? username(String? value) {
    final required = requiredField(value);
    if (required != null) return required;
    final v = value!.trim();
    if (v.length < 3 || v.length > 20) {
      return _l((l) => l.vUsernameLength);
    }
    if (!_usernameRegex.hasMatch(v)) {
      return _l((l) => l.vUsernameChars);
    }
    return null;
  }

  static String? password(String? value) {
    final required = requiredField(value);
    if (required != null) return required;
    final v = value!;
    if (v.length < 6) return _l((l) => l.vPasswordMin);
    if (!_passwordLetterRegex.hasMatch(v)) {
      return _l((l) => l.vPasswordLetter);
    }
    if (!_passwordDigitRegex.hasMatch(v)) {
      return _l((l) => l.vPasswordDigit);
    }
    return null;
  }

  static String? passwordMatch(String? value, String other) {
    final required = requiredField(value);
    if (required != null) return required;
    if (value != other) return _l((l) => l.vPasswordsNotMatching);
    return null;
  }

  static String? securityAnswer(String? value) {
    final required = requiredField(value);
    if (required != null) return required;
    if (value!.trim().length < 2) return _l((l) => l.vAnswerMin);
    return null;
  }
}
