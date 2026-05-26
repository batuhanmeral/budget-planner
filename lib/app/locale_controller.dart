import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_l10n.dart';
import '../l10n/app_l10n_en.dart';
import '../l10n/app_l10n_tr.dart';
import 'app_constants.dart';

/// Uygulamanın aktif dilini yöneten singleton servis.
///
/// Hem [Locale] (Flutter widget tarafı için) hem [AppL10n] (uygulama
/// string'leri için) sunar. [ChangeNotifier] olduğu için MaterialApp
/// dil değişiminde rebuild olur.
///
/// Dil tercihi `shared_preferences` üzerinden kalıcıdır.
class LocaleController extends ChangeNotifier {
  LocaleController._();
  static final instance = LocaleController._();

  // Varsayılan: Türkçe.
  Locale _locale = const Locale('tr');
  Locale get locale => _locale;

  /// `intl` paketinin [DateFormat] / [NumberFormat] gibi sınıflarda
  /// kullanılan locale string'i — 'tr_TR' veya 'en_US'.
  String get intlLocale =>
      _locale.languageCode == 'en' ? 'en_US' : 'tr_TR';

  /// Aktif dilin string sözlüğü.
  AppL10n get l10n =>
      _locale.languageCode == 'en' ? const AppL10nEn() : const AppL10nTr();

  /// Prefs'ten kayıtlı dili yükler. main() içinde runApp öncesi çağrılır.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(PrefsKeys.languageCode);
    _locale = code == 'en' ? const Locale('en') : const Locale('tr');
    Intl.defaultLocale = intlLocale;
    notifyListeners();
  }

  /// Yeni dili seçer, prefs'e yazar, Intl.defaultLocale'i günceller ve
  /// dinleyicilere haber verir. MaterialApp rebuild olur.
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    Intl.defaultLocale = intlLocale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.languageCode, locale.languageCode);
  }
}

/// `context.l10n` kısayolu — daha okunaklı kullanım için.
extension AppL10nContext on BuildContext {
  AppL10n get l10n => LocaleController.instance.l10n;
}
