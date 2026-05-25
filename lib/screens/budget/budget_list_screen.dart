import 'package:flutter/material.dart';

import '../../app/app_constants.dart';
import '../../models/budget.dart';
import '../../services/auth_service.dart';
import '../../services/budget_repository.dart';
import '../../services/expense_repository.dart';
import '../../widgets/budget_alert_banner.dart';
import '../../widgets/budget_progress_card.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import 'budget_form_screen.dart';

class _BudgetListData {
  final List<Budget> budgets;
  final Map<String, double> monthlyTotals;
  const _BudgetListData(this.budgets, this.monthlyTotals);
}

class BudgetListScreen extends StatefulWidget {
  const BudgetListScreen({super.key});

  @override
  State<BudgetListScreen> createState() => BudgetListScreenState();
}

class BudgetListScreenState extends State<BudgetListScreen> {
  late Future<_BudgetListData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_BudgetListData> _load() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return const _BudgetListData([], {});
    final now = DateTime.now();
    final budgets = await BudgetRepository.instance.getAllForUser(user.id!);
    final totals = await ExpenseRepository.instance.getMonthlyTotalByCategory(
      userId: user.id!,
      year: now.year,
      month: now.month,
    );
    return _BudgetListData(budgets, totals);
  }

  void reload() {
    setState(() => _future = _load());
  }

  Future<void> openAdd({List<String> existing = const []}) async {
    final navigator = Navigator.of(context);
    final saved = await navigator.push<bool>(
      MaterialPageRoute(
        builder: (_) => BudgetFormScreen(existingCategories: existing),
      ),
    );
    if (saved == true) reload();
  }

  Future<void> _edit(Budget budget) async {
    final navigator = Navigator.of(context);
    final saved = await navigator.push<bool>(
      MaterialPageRoute(builder: (_) => BudgetFormScreen(initial: budget)),
    );
    if (saved == true) reload();
  }

  Future<void> _delete(Budget budget) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final ok = await showConfirmDialog(
      context,
      title: 'Bütçeyi sil',
      message:
          '${budget.category} kategorisinin bütçesini silmek istediğinize emin misiniz?',
    );
    if (!ok || !mounted) return;
    try {
      await BudgetRepository.instance.delete(id: budget.id!, userId: user.id!);
      reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silinemedi. Lütfen tekrar deneyin.')),
      );
    }
  }

  List<BudgetAlert> _buildAlerts(_BudgetListData data) {
    return [
      for (final b in data.budgets)
        BudgetAlert(
          category: b.category,
          ratio: b.monthlyLimit <= 0
              ? 0
              : (data.monthlyTotals[b.category] ?? 0) / b.monthlyLimit,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return FutureBuilder<_BudgetListData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Veriler yüklenemedi.'));
        }
        final data = snapshot.data ?? const _BudgetListData([], {});

        if (data.budgets.isEmpty) {
          return EmptyState(
            icon: Icons.savings_outlined,
            title: 'Henüz bütçe yok',
            subtitle: 'Sağ alttaki + ile kategori başına aylık limit belirle.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => reload(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
            children: [
              BudgetAlertBanner(alerts: _buildAlerts(data)),
              for (final b in data.budgets)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: BudgetProgressCard(
                    category: AppCategories.byName(b.category),
                    spent: data.monthlyTotals[b.category] ?? 0,
                    limit: b.monthlyLimit,
                    onEdit: () => _edit(b),
                    onDelete: () => _delete(b),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// FAB için: mevcut bütçesi olan kategorileri çıkarıp [openAdd]'a iletir.
  Future<void> openAddSmart() async {
    final data = await _future;
    if (!mounted) return;
    await openAdd(existing: data.budgets.map((b) => b.category).toList());
  }
}
