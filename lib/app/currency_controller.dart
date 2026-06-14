import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_constants.dart';
import 'currency.dart';

class CurrencyController extends ChangeNotifier {
  CurrencyController._();

  static final instance = CurrencyController._();

  Currency _currency = Currencies.fallback;
  Currency get currency => _currency;

  String get symbol => _currency.symbol;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(PrefsKeys.currencyCode);
    _currency = Currencies.byCode(code);
    notifyListeners();
  }

  Future<void> setCurrency(Currency currency) async {
    _currency = currency;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.currencyCode, currency.code);
  }
}
