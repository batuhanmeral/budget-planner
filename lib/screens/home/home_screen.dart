import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/locale_controller.dart';
import '../../services/auth_service.dart';
import '../budget/budget_list_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../expenses/expense_list_screen.dart';
import '../income/income_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _dashboardKey = GlobalKey<DashboardScreenState>();
  final _expensesKey = GlobalKey<ExpenseListScreenState>();
  final _incomeKey = GlobalKey<IncomeListScreenState>();
  final _budgetKey = GlobalKey<BudgetListScreenState>();

  void _onTabChange(int i) {
    setState(() => _index = i);
    if (i == 0) _dashboardKey.currentState?.reload();
    if (i == 2) _incomeKey.currentState?.reload();
    if (i == 3) _budgetKey.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final titles = [l.tabDashboard, l.tabExpenses, l.tabIncome, l.tabBudget];
    final user = AuthService.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
      });
      return const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            tooltip: l.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.of(context).pushNamed(AppRoutes.settings);
              if (!mounted) return;
              _dashboardKey.currentState?.reload();
              _expensesKey.currentState?.reload();
              _incomeKey.currentState?.reload();
              _budgetKey.currentState?.reload();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(
            key: _dashboardKey,
            onSeeAllExpenses: () => _onTabChange(1),
          ),
          ExpenseListScreen(key: _expensesKey),
          IncomeListScreen(key: _incomeKey),
          BudgetListScreen(key: _budgetKey),
        ],
      ),
      floatingActionButton: switch (_index) {
        1 => FloatingActionButton(
          onPressed: () => _expensesKey.currentState?.openAdd(),
          child: const Icon(Icons.add),
        ),
        2 => FloatingActionButton(
          onPressed: () => _incomeKey.currentState?.openAdd(),
          child: const Icon(Icons.add),
        ),
        3 => FloatingActionButton(
          onPressed: () => _budgetKey.currentState?.openAddSmart(),
          child: const Icon(Icons.add),
        ),
        _ => null,
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onTabChange,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.pie_chart_outline),
            selectedIcon: const Icon(Icons.pie_chart),
            label: l.tabDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.list_alt_outlined),
            selectedIcon: const Icon(Icons.list_alt),
            label: l.tabExpenses,
          ),
          NavigationDestination(
            icon: const Icon(Icons.trending_up),
            selectedIcon: const Icon(Icons.trending_up),
            label: l.tabIncome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.savings_outlined),
            selectedIcon: const Icon(Icons.savings),
            label: l.tabBudget,
          ),
        ],
      ),
    );
  }
}
