import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_l10n.dart';
import '../l10n/app_l10n_en.dart';
import '../l10n/app_l10n_tr.dart';
import 'app_constants.dart';

class LocaleController extends ChangeNotifier {
  LocaleController._();
  static final instance = LocaleController._();

  Locale _locale = const Locale('tr');
  Locale get locale => _locale;

  String get intlLocale => _locale.languageCode == 'en' ? 'en_US' : 'tr_TR';

  AppL10n get l10n =>
      _locale.languageCode == 'en' ? const AppL10nEn() : const AppL10nTr();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(PrefsKeys.languageCode);
    _locale = code == 'en' ? const Locale('en') : const Locale('tr');
    Intl.defaultLocale = intlLocale;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    Intl.defaultLocale = intlLocale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.languageCode, locale.languageCode);
  }
}

class AppReactiveScope extends InheritedWidget {
  final String localeCode;
  final String currencyCode;

  const AppReactiveScope({
    super.key,
    required this.localeCode,
    required this.currencyCode,
    required super.child,
  });

  static void watch(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<AppReactiveScope>();
  }

  @override
  bool updateShouldNotify(AppReactiveScope oldWidget) =>
      oldWidget.localeCode != localeCode ||
      oldWidget.currencyCode != currencyCode;
}

extension AppL10nContext on BuildContext {
  AppL10n get l10n {
    AppReactiveScope.watch(this);
    return LocaleController.instance.l10n;
  }
}
