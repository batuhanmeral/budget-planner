import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_constants.dart';

/// Uygulamanın tema modunu (Light/Dark/System) yönetir.
///
/// Flutter SDK'sının kendi [ChangeNotifier] sınıfını kullanır — üçüncü
/// parti state-management paketi (Provider, Riverpod, vb.) YOK. UI
/// tarafında `AnimatedBuilder(animation: ThemeController.instance, ...)`
/// ile dinlenir.
///
/// Kullanıcının seçimi `shared_preferences` üzerinden kalıcıdır;
/// uygulamayı kapatıp açtıkta tercih korunur.
class ThemeController extends ChangeNotifier {
  ThemeController._();

  /// Singleton instance — tüm uygulama bunu paylaşır.
  static final instance = ThemeController._();

  // Varsayılan: cihaz ayarını takip et.
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  /// Prefs'ten kaydedilmiş tema tercihini yükler. `main()` içinde
  /// `runApp`'tan önce çağrılır.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(PrefsKeys.themeMode);
    _mode = _decode(raw);
    notifyListeners();
  }

  /// Yeni tema modunu hem belleğe set eder, hem dinleyicileri uyarır,
  /// hem de prefs'e yazar.
  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.themeMode, _encode(mode));
  }

  // Prefs'te string olarak saklanan değeri enum'a çevirir.
  // Bilinmeyen değer için varsayılan: system.
  static ThemeMode _decode(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // Enum'u prefs için string'e çevirir.
  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
