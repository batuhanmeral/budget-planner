import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/app_constants.dart';
import '../../app/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/recurring_expense_runner.dart';
import '../../services/recurring_income_runner.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(PrefsKeys.onboardingSeen) ?? false;
    if (!seen) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      return;
    }

    final user = await AuthService.instance.tryAutoLogin();
    if (user != null) {
      await RecurringExpenseRunner.runForUser(user.id!);
      await RecurringIncomeRunner.runForUser(user.id!);
    }
    if (!mounted) return;
    final route = user != null ? AppRoutes.home : AppRoutes.login;
    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
