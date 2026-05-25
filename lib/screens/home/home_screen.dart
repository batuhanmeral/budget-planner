import 'package:flutter/material.dart';

import '../../app/app_constants.dart';
import '../../app/app_routes.dart';
import '../../services/auth_service.dart';
import '../budget/budget_list_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../expenses/expense_list_screen.dart';

/// Uygulamanın ana iskeleti — login sonrası buraya gelinir.
///
/// Üç sekme: Özet (Dashboard), Harcamalar, Bütçe. Sekmeler
/// [IndexedStack] içinde tutulur — sekme değişiminde state korunur
/// (kullanıcı filtre/arama girdisini kaybetmez).
///
/// FAB sekmeye göre değişir: Harcamalar → ekle, Bütçe → ekle, Dashboard → yok.
/// AppBar'da ayarlar ikonu; ayarlar'dan dönüldüğünde sekmeler reload edilir
/// (silinen veriler yansısın diye).
///
/// Korumalı ekran kuralı: `currentUser == null` olursa hot-restart
/// senaryosunda login'e geri yönlendirir.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _dashboardKey = GlobalKey<DashboardScreenState>();
  final _expensesKey = GlobalKey<ExpenseListScreenState>();
  final _budgetKey = GlobalKey<BudgetListScreenState>();

  void _onTabChange(int i) {
    setState(() => _index = i);
    if (i == 0) _dashboardKey.currentState?.reload();
    if (i == 2) _budgetKey.currentState?.reload();
  }

  static const _titles = <String>[
    AppStrings.tabDashboard,
    AppStrings.tabExpenses,
    AppStrings.tabBudget,
  ];

  @override
  Widget build(BuildContext context) {
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
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Ayarlar',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.of(context).pushNamed(AppRoutes.settings);
              if (!mounted) return;
              _dashboardKey.currentState?.reload();
              _expensesKey.currentState?.reload();
              _budgetKey.currentState?.reload();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(key: _dashboardKey),
          ExpenseListScreen(key: _expensesKey),
          BudgetListScreen(key: _budgetKey),
        ],
      ),
      floatingActionButton: switch (_index) {
        1 => FloatingActionButton(
          onPressed: () => _expensesKey.currentState?.openAdd(),
          child: const Icon(Icons.add),
        ),
        2 => FloatingActionButton(
          onPressed: () => _budgetKey.currentState?.openAddSmart(),
          child: const Icon(Icons.add),
        ),
        _ => null,
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onTabChange,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: AppStrings.tabDashboard,
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: AppStrings.tabExpenses,
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings),
            label: AppStrings.tabBudget,
          ),
        ],
      ),
    );
  }
}
