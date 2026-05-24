import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
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

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
      case home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      default:
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
