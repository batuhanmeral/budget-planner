import 'package:flutter/material.dart';

import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/settings/settings_screen.dart';

/// Uygulamanın navigasyon haritası — named route sabitleri ve
/// [onGenerateRoute] fabrikası.
///
/// Route'lar string constant olarak tutulur ki UI tarafında
/// `Navigator.pushNamed(context, AppRoutes.login)` gibi typo-safe
/// kullanım sağlansın.
///
/// Profile, ChangePassword gibi bazı ekranlar named route yerine
/// doğrudan `MaterialPageRoute` ile push edilir; çünkü onlar parametre
/// alır (`expenseId`, `Expense` vb.) ve route arguments'a göre üretmek
/// karmaşıklaştırır.
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const expenseForm = '/expense-form';
  static const expenseDetail = '/expense-detail';
  static const budgetForm = '/budget-form';
  static const settings = '/settings';
  static const profile = '/profile';
  static const changePassword = '/change-password';

  /// `MaterialApp.onGenerateRoute` callback'i — route adına göre uygun
  /// ekranı döner. Bilinmeyen rota için 404 sayfası gösterir.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );
      case onboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OnboardingScreen(),
        );
      case login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case register:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );
      case forgotPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ForgotPasswordScreen(),
        );
      case home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SettingsScreen(),
        );
      default:
        // Bilinmeyen rota — geliştirme sırasında hatayı görebilelim diye
        // crash yerine bilgi sayfası gösteriyoruz.
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Sayfa bulunamadı')),
            body: Center(child: Text('Bilinmeyen rota: ${settings.name}')),
          ),
        );
    }
  }
}
