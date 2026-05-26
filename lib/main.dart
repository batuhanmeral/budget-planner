import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app_routes.dart';
import 'app/app_theme.dart';
import 'app/locale_controller.dart';
import 'app/theme_controller.dart';
import 'services/database_service.dart';

/// Uygulamanın giriş noktası.
///
/// `runApp` öncesi hazırlıklar:
/// 1. Flutter binding'in başlaması
/// 2. TR + EN tarih sembollerinin yüklenmesi
/// 3. Kullanıcı tema + dil tercihinin yüklenmesi
/// 4. SQLite veritabanının açılması (gerekirse oluşturulması)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // İki locale için tarih sembollerini hazırla — kullanıcı dil
  // değiştirdiğinde yeniden init gerektirmez.
  await initializeDateFormatting('tr_TR', null);
  await initializeDateFormatting('en_US', null);

  // Locale + tema tercihlerini paralel yükle.
  await Future.wait([
    LocaleController.instance.load(),
    ThemeController.instance.load(),
  ]);

  final db = await DatabaseService.instance.database;
  debugPrint('SQLite ready at ${db.path}');

  runApp(const BudgetPlannerApp());
}

/// MaterialApp wrapper — tema, locale, navigasyon kurulumu.
///
/// Hem [ThemeController] hem [LocaleController] [ChangeNotifier] olduğu
/// için ikisini [Listenable.merge] ile birleştirip [AnimatedBuilder] ile
/// dinleriz. Herhangi biri değişince MaterialApp rebuild olur.
class BudgetPlannerApp extends StatelessWidget {
  const BudgetPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ThemeController.instance,
        LocaleController.instance,
      ]),
      builder: (context, _) {
        final l10n = LocaleController.instance.l10n;
        return MaterialApp(
          title: l10n.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeController.instance.mode,
          locale: LocaleController.instance.locale,
          supportedLocales: const [Locale('tr'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}
