import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app/app_constants.dart';
import 'app/app_routes.dart';
import 'app/app_theme.dart';
import 'app/theme_controller.dart';
import 'services/database_service.dart';

/// Uygulamanın giriş noktası.
///
/// `runApp` çağrılmadan önce yapılması gereken async hazırlıklar:
/// 1. Flutter binding'in başlaması ([WidgetsFlutterBinding.ensureInitialized])
/// 2. Türkçe tarih sembollerinin yüklenmesi
/// 3. Kullanıcının tema tercihinin yüklenmesi
/// 4. SQLite veritabanının açılması (ve gerekirse oluşturulması)
Future<void> main() async {
  // Async kod runApp öncesi çalışacaksa bu çağrı zorunlu — aksi takdirde
  // platform channel'lar henüz hazır değil ve çökme yaşanır.
  WidgetsFlutterBinding.ensureInitialized();

  // intl paketinin Türkçe ay/gün isimlerini yükle. Bu olmadan
  // DateFormat('d MMMM y', 'tr_TR') çağrısı runtime'da exception atar.
  await initializeDateFormatting(AppStrings.locale, null);
  Intl.defaultLocale = AppStrings.locale;

  // Tema tercihini prefs'ten yükle — ilk açılışta system varsayılan.
  await ThemeController.instance.load();

  // DB'yi şimdiden aç; SplashScreen'in auto-login için hazır olsun.
  // Path'i debug log'a yazıyoruz — geliştirme sırasında dosyaya
  // ulaşabilmek için.
  final db = await DatabaseService.instance.database;
  debugPrint('SQLite ready at ${db.path}');

  runApp(const BudgetPlannerApp());
}

/// MaterialApp wrapper — tema, locale, navigasyon kurulumu.
///
/// [ThemeController] bir [ChangeNotifier] olduğu için [AnimatedBuilder]
/// ile dinlenir; tema değişince MaterialApp rebuild olur.
class BudgetPlannerApp extends StatelessWidget {
  const BudgetPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeController.instance.mode,
          // Locale ayarları — showDatePicker ve Material widget'larının
          // Türkçe gelmesi için gerekli.
          locale: const Locale('tr', 'TR'),
          supportedLocales: const [Locale('tr', 'TR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Splash önce çalışır → auto-login kontrolü → Home veya Login.
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}
