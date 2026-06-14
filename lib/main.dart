import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app_routes.dart';
import 'app/app_theme.dart';
import 'app/currency_controller.dart';
import 'app/locale_controller.dart';
import 'app/theme_controller.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('tr_TR', null);
  await initializeDateFormatting('en_US', null);

  await Future.wait([
    LocaleController.instance.load(),
    ThemeController.instance.load(),
    CurrencyController.instance.load(),
  ]);

  final db = await DatabaseService.instance.database;
  debugPrint('SQLite ready at ${db.path}');

  runApp(const BudgetPlannerApp());
}

class BudgetPlannerApp extends StatelessWidget {
  const BudgetPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ThemeController.instance,
        LocaleController.instance,
        CurrencyController.instance,
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
          builder: (context, child) => AppReactiveScope(
            localeCode: LocaleController.instance.locale.languageCode,
            currencyCode: CurrencyController.instance.currency.code,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
