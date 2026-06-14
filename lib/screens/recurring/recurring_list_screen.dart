import 'package:flutter/material.dart';

import '../../app/app_constants.dart';
import '../../app/locale_controller.dart';
import '../../l10n/app_l10n.dart';
import '../../models/recurring_expense.dart';
import '../../models/recurring_income.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/recurring_expense_repository.dart';
import '../../services/recurring_expense_runner.dart';
import '../../services/recurring_income_repository.dart';
import '../../services/recurring_income_runner.dart';
import '../../utils/formatters.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import 'recurring_form_screen.dart';
import 'recurring_income_form_screen.dart';

class RecurringListScreen extends StatefulWidget {
  const RecurringListScreen({super.key});

  @override
  State<RecurringListScreen> createState() => _RecurringListScreenState();
}

class _RecurringListScreenState extends State<RecurringListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _expenseKey = GlobalKey<_RecurringExpenseTabState>();
  final _incomeKey = GlobalKey<_RecurringIncomeTabState>();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _onAdd() {
    if (_tab.index == 0) {
      _expenseKey.currentState?.openAdd();
    } else {
      _incomeKey.currentState?.openAdd();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.recurringTitle),
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(text: l.expenseDistribution),
            Tab(text: l.incomeDistribution),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _RecurringExpenseTab(key: _expenseKey),
          _RecurringIncomeTab(key: _incomeKey),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RecurringExpenseTab extends StatefulWidget {
  const _RecurringExpenseTab({super.key});

  @override
  State<_RecurringExpenseTab> createState() => _RecurringExpenseTabState();
}

class _RecurringExpenseTabState extends State<_RecurringExpenseTab> {
  AppL10n get _l => LocaleController.instance.l10n;

  late Future<List<RecurringExpense>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<RecurringExpense>> _load() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return [];
    // Vadesi gelmiş şablonları bu açılışta yakala (ör. gün geçtiyse ekle).
    await RecurringExpenseRunner.runForUser(user.id!);
    return RecurringExpenseRepository.instance.getAllForUser(user.id!);
  }

  void _reload() {
    setState(() => _future = _load());
  }

  Future<void> openAdd() => _openForm();

  Future<void> _openForm({RecurringExpense? initial}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RecurringFormScreen(initial: initial)),
    );
    if (saved == true) _reload();
  }

  Future<void> _toggleActive(RecurringExpense r, bool value) async {
    try {
      await RecurringExpenseRepository.instance.update(
        r.copyWith(active: value),
      );
      _reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_l.notUpdated)));
    }
  }

  Future<void> _delete(RecurringExpense r) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final ok = await showConfirmDialog(
      context,
      title: _l.deleteRecurringTitle,
      message: _l.deleteRecurringMessage,
    );
    if (!ok || !mounted) return;
    try {
      await RecurringExpenseRepository.instance.delete(
        id: r.id!,
        userId: user.id!,
      );
      _reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_l.notDeleted)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return FutureBuilder<List<RecurringExpense>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? const <RecurringExpense>[];
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.repeat,
            title: l.emptyRecurringTitle,
            subtitle: l.emptyRecurringSubtitle,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final r = items[i];
            return _RecurringTile(
              category: CategoryService.instance.byName(r.category),
              amount: r.amount,
              dayOfMonth: r.dayOfMonth,
              note: r.note,
              active: r.active,
              onTap: () => _openForm(initial: r),
              onToggle: (v) => _toggleActive(r, v),
              onDelete: () => _delete(r),
            );
          },
        );
      },
    );
  }
}

class _RecurringIncomeTab extends StatefulWidget {
  const _RecurringIncomeTab({super.key});

  @override
  State<_RecurringIncomeTab> createState() => _RecurringIncomeTabState();
}

class _RecurringIncomeTabState extends State<_RecurringIncomeTab> {
  AppL10n get _l => LocaleController.instance.l10n;

  late Future<List<RecurringIncome>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<RecurringIncome>> _load() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return [];
    await RecurringIncomeRunner.runForUser(user.id!);
    return RecurringIncomeRepository.instance.getAllForUser(user.id!);
  }

  void _reload() {
    setState(() => _future = _load());
  }

  Future<void> openAdd() => _openForm();

  Future<void> _openForm({RecurringIncome? initial}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RecurringIncomeFormScreen(initial: initial),
      ),
    );
    if (saved == true) _reload();
  }

  Future<void> _toggleActive(RecurringIncome r, bool value) async {
    try {
      await RecurringIncomeRepository.instance.update(r.copyWith(active: value));
      _reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_l.notUpdated)));
    }
  }

  Future<void> _delete(RecurringIncome r) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final ok = await showConfirmDialog(
      context,
      title: _l.deleteRecurringTitle,
      message: _l.deleteRecurringMessage,
    );
    if (!ok || !mounted) return;
    try {
      await RecurringIncomeRepository.instance.delete(
        id: r.id!,
        userId: user.id!,
      );
      _reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_l.notDeleted)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return FutureBuilder<List<RecurringIncome>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? const <RecurringIncome>[];
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.repeat,
            title: l.emptyRecurringTitle,
            subtitle: l.emptyRecurringSubtitle,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final r = items[i];
            return _RecurringTile(
              category: CategoryService.instance.incomeByName(r.source),
              amount: r.amount,
              dayOfMonth: r.dayOfMonth,
              note: r.note,
              active: r.active,
              income: true,
              onTap: () => _openForm(initial: r),
              onToggle: (v) => _toggleActive(r, v),
              onDelete: () => _delete(r),
            );
          },
        );
      },
    );
  }
}

class _RecurringTile extends StatelessWidget {
  final AppCategory category;
  final double amount;
  final int dayOfMonth;
  final String? note;
  final bool active;
  final bool income;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _RecurringTile({
    required this.category,
    required this.amount,
    required this.dayOfMonth,
    required this.note,
    required this.active,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
    this.income = false,
  });

  @override
  Widget build(BuildContext context) {
    const positive = Color(0xFF16A34A);
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: category.color.withValues(alpha: 0.15),
          foregroundColor: category.color,
          child: Icon(category.icon),
        ),
        title: Text(
          income
              ? '+${Formatters.money(amount)}'
              : Formatters.money(amount),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: income ? positive : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                CategoryChip(category: category, dense: true),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    context.l10n.everyMonthOnDay(dayOfMonth),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            if (note != null && note!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                note!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(value: active, onChanged: onToggle),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
