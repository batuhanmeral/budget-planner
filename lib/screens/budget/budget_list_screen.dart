import 'package:flutter/material.dart';

import '../../models/budget.dart';
import '../../app/locale_controller.dart';
import '../../l10n/app_l10n.dart';
import '../../services/auth_service.dart';
import '../../services/budget_repository.dart';
import '../../services/category_service.dart';
import '../../services/expense_repository.dart';
import '../../widgets/budget_alert_banner.dart';
import '../../widgets/budget_progress_card.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import 'budget_form_screen.dart';

/// Bütçe listesinin tek seferde yüklediği veriler — bütçeler ve bu
/// ayki kategori bazlı toplamlar (doluluk hesabı için).
class _BudgetListData {
  final List<Budget> budgets;
  final Map<String, double> monthlyTotals;
  const _BudgetListData(this.budgets, this.monthlyTotals);
}

/// Bütçe sekmesinin içeriği. Üstte [BudgetAlertBanner], altta her
/// bütçe için [BudgetProgressCard] ile doluluk gösterimi.
///
/// HomeScreen GlobalKey üzerinden [openAddSmart] ile FAB'ı tetikler
/// (mevcut kategorileri form'a iletir — dropdown elemesi için).
class BudgetListScreen extends StatefulWidget {
  const BudgetListScreen({super.key});

  @override
  State<BudgetListScreen> createState() => BudgetListScreenState();
}

class BudgetListScreenState extends State<BudgetListScreen> {
  AppL10n get _l => LocaleController.instance.l10n;

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
      title: _l.deleteBudgetTitle,
      message:
          _l.deleteBudgetMessage(budget.category),
    );
    if (!ok || !mounted) return;
    try {
      await BudgetRepository.instance.delete(id: budget.id!, userId: user.id!);
      reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l.notDeleted)),
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
    final l = context.l10n;
    final user = AuthService.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return FutureBuilder<_BudgetListData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(l.loadingDataError));
        }
        final data = snapshot.data ?? const _BudgetListData([], {});

        if (data.budgets.isEmpty) {
          return EmptyState(
            icon: Icons.savings_outlined,
            title: l.emptyBudgetTitle,
            subtitle: l.emptyBudgetSubtitle,
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
                    category: CategoryService.instance.byName(b.category),
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
