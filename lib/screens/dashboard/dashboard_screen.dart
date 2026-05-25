import 'package:flutter/material.dart';

import '../../app/app_constants.dart';
import '../../models/budget.dart';
import '../../models/expense.dart';
import '../../services/auth_service.dart';
import '../../services/budget_repository.dart';
import '../../services/expense_repository.dart';
import '../../utils/formatters.dart';
import '../../utils/money_utils.dart';
import '../../widgets/budget_alert_banner.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/expense_tile.dart';
import '../../widgets/weekly_bar_chart.dart';
import '../expenses/expense_detail_screen.dart';

/// Dashboard'un tek seferde yüklediği tüm verileri taşıyan immutable
/// veri sınıfı. `Future.wait` ile paralel sorgular sonucu üretilir.
class _DashboardData {
  final double monthlyTotal;
  final double previousMonthTotal;
  final List<DailyTotal> dailyTotals;
  final Map<String, double> monthlyByCategory;
  final List<Expense> recent;
  final List<Budget> budgets;

  const _DashboardData({
    required this.monthlyTotal,
    required this.previousMonthTotal,
    required this.dailyTotals,
    required this.monthlyByCategory,
    required this.recent,
    required this.budgets,
  });
}

/// Özet ekranı — kullanıcının bu ayki finansal durumuna tek bakışta
/// erişim sağlar.
///
/// İçerikler (yukarıdan aşağıya):
/// 1. Karşılama (Merhaba, {username})
/// 2. Bu ay toplam + geçen aya göre yüzde değişim
/// 3. Bütçe uyarı banner'ı (varsa)
/// 4. Son 7 gün bar grafiği
/// 5. Kategori dağılımı (toplam + yüzde)
/// 6. Son 5 harcama (tıklanabilir)
///
/// Tüm sorgular [Future.wait] ile paralel çalışır — DB rountrip sayısı
/// minimize edilir.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DashboardData> _load() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      return const _DashboardData(
        monthlyTotal: 0,
        previousMonthTotal: 0,
        dailyTotals: [],
        monthlyByCategory: {},
        recent: [],
        budgets: [],
      );
    }
    final now = DateTime.now();
    final prev = DateTime(now.year, now.month - 1, 1);

    final results = await Future.wait([
      ExpenseRepository.instance.getMonthlyTotal(
        userId: user.id!,
        year: now.year,
        month: now.month,
      ),
      ExpenseRepository.instance.getMonthlyTotal(
        userId: user.id!,
        year: prev.year,
        month: prev.month,
      ),
      ExpenseRepository.instance.getDailyTotalsForLastNDays(
        userId: user.id!,
        days: 7,
      ),
      ExpenseRepository.instance.getMonthlyTotalByCategory(
        userId: user.id!,
        year: now.year,
        month: now.month,
      ),
      ExpenseRepository.instance.getAllForUser(user.id!),
      BudgetRepository.instance.getAllForUser(user.id!),
    ]);

    final all = results[4] as List<Expense>;
    return _DashboardData(
      monthlyTotal: results[0] as double,
      previousMonthTotal: results[1] as double,
      dailyTotals: results[2] as List<DailyTotal>,
      monthlyByCategory: results[3] as Map<String, double>,
      recent: all.take(5).toList(),
      budgets: results[5] as List<Budget>,
    );
  }

  void reload() {
    setState(() => _future = _load());
  }

  List<BudgetAlert> _buildAlerts(_DashboardData data) {
    return [
      for (final b in data.budgets)
        BudgetAlert(
          category: b.category,
          ratio: b.monthlyLimit <= 0
              ? 0
              : (data.monthlyByCategory[b.category] ?? 0) / b.monthlyLimit,
        ),
    ];
  }

  Future<void> _openExpense(Expense expense) async {
    final navigator = Navigator.of(context);
    final changed = await navigator.push<bool>(
      MaterialPageRoute(
        builder: (_) => ExpenseDetailScreen(expenseId: expense.id!),
      ),
    );
    if (changed == true) reload();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return FutureBuilder<_DashboardData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Veriler yüklenemedi.'));
        }
        final data = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async => reload(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            children: [
              _GreetingCard(username: user.username),
              const SizedBox(height: 12),
              _MonthTotalCard(
                total: data.monthlyTotal,
                previous: data.previousMonthTotal,
              ),
              const SizedBox(height: 12),
              BudgetAlertBanner(alerts: _buildAlerts(data)),
              const SizedBox(height: 4),
              _WeeklyChartCard(data: data.dailyTotals),
              const SizedBox(height: 12),
              _CategoryBreakdownCard(
                totalByCategory: data.monthlyByCategory,
                total: data.monthlyTotal,
              ),
              const SizedBox(height: 12),
              _RecentExpensesCard(recent: data.recent, onTap: _openExpense),
            ],
          ),
        );
      },
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final String username;
  const _GreetingCard({required this.username});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.15),
          foregroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.waving_hand),
        ),
        title: Text(
          'Merhaba, $username',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Bugünkü harcamalarına göz at.'),
      ),
    );
  }
}

class _MonthTotalCard extends StatelessWidget {
  final double total;
  final double previous;

  const _MonthTotalCard({required this.total, required this.previous});

  ({IconData icon, String label, Color color})? _delta(BuildContext context) {
    if (previous <= 0) return null;
    final diff = total - previous;
    final pct = (diff / previous * 100).abs();
    if (diff == 0) {
      return (
        icon: Icons.remove,
        label: 'Geçen ayla aynı',
        color: Theme.of(context).colorScheme.outline,
      );
    }
    final up = diff > 0;
    return (
      icon: up ? Icons.arrow_upward : Icons.arrow_downward,
      label:
          'Geçen aya göre %${pct.toStringAsFixed(0)} ${up ? 'arttı' : 'azaldı'}',
      color: up ? Colors.red : Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _delta(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bu ay toplam',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Formatters.money(roundMoney(total)),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (d != null)
              Row(
                children: [
                  Icon(d.icon, size: 16, color: d.color),
                  const SizedBox(width: 4),
                  Text(
                    d.label,
                    style: TextStyle(
                      color: d.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            else
              Text(
                'Geçen ay için veri yok.',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChartCard extends StatelessWidget {
  final List<DailyTotal> data;
  const _WeeklyChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Son 7 gün', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            WeeklyBarChart(data: data),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  final Map<String, double> totalByCategory;
  final double total;

  const _CategoryBreakdownCard({
    required this.totalByCategory,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final entries = totalByCategory.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori dağılımı',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Text(
                'Bu ay harcama yok.',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              )
            else
              for (final e in entries) ...[
                _CategoryRow(
                  category: AppCategories.byName(e.key),
                  amount: e.value,
                  percent: total <= 0 ? 0 : (e.value / total),
                ),
                const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final AppCategory category;
  final double amount;
  final double percent;

  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: CategoryChip(category: category, dense: true)),
        Text(
          Formatters.money(amount),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
          child: Text(
            '%${(percent * 100).toStringAsFixed(0)}',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentExpensesCard extends StatelessWidget {
  final List<Expense> recent;
  final ValueChanged<Expense> onTap;

  const _RecentExpensesCard({required this.recent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son harcamalar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (recent.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: EmptyState(
                  icon: Icons.history,
                  title: 'Henüz harcama yok',
                ),
              )
            else
              for (final e in recent)
                ExpenseTile(expense: e, onTap: () => onTap(e)),
          ],
        ),
      ),
    );
  }
}
