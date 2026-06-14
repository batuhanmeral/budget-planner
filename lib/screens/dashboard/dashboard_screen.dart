import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/app_constants.dart';
import '../../app/locale_controller.dart';
import '../../models/budget.dart';
import '../../models/expense.dart';
import '../../services/auth_service.dart';
import '../../services/budget_repository.dart';
import '../../services/category_service.dart';
import '../../services/expense_repository.dart';
import '../../services/income_repository.dart';
import '../../utils/date_utils.dart' as du;
import '../../utils/formatters.dart';
import '../../utils/money_utils.dart';
import '../../widgets/budget_alert_banner.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/category_pie_chart.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/expense_tile.dart';
import '../../widgets/weekly_bar_chart.dart';
import '../expenses/expense_detail_screen.dart';

const _positive = Color(0xFF16A34A);
const _recentLimit = 8;

class _MonthNet {
  final int year;
  final int month;
  final double income;
  final double expense;
  const _MonthNet({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
  });
  double get net => roundMoney(income - expense);
}

class _DashboardData {
  final double monthlyTotal;
  final double monthlyIncome;
  final List<DailyTotal> dailyTotals;
  final Map<String, double> monthlyByCategory;
  final Map<String, double> weeklyByCategory;
  final Map<String, double> yearByCategory;
  final Map<String, double> monthlyIncomeBySource;
  final Map<String, double> weeklyIncomeBySource;
  final Map<String, double> yearIncomeBySource;
  final List<Expense> recent;
  final List<Budget> budgets;
  final List<_MonthNet> trend;

  const _DashboardData({
    required this.monthlyTotal,
    required this.monthlyIncome,
    required this.dailyTotals,
    required this.monthlyByCategory,
    required this.weeklyByCategory,
    required this.yearByCategory,
    required this.monthlyIncomeBySource,
    required this.weeklyIncomeBySource,
    required this.yearIncomeBySource,
    required this.recent,
    required this.budgets,
    required this.trend,
  });

  double get netBalance => roundMoney(monthlyIncome - monthlyTotal);
  double get weeklyTotal => weeklyByCategory.values.fold(0.0, (s, v) => s + v);
  double get monthlyExpenseTotal => monthlyTotal;
  double get yearTotal => yearByCategory.values.fold(0.0, (s, v) => s + v);
  double get monthlyIncomeTotal =>
      monthlyIncomeBySource.values.fold(0.0, (s, v) => s + v);
  double get weeklyIncomeTotal =>
      weeklyIncomeBySource.values.fold(0.0, (s, v) => s + v);
  double get yearIncomeTotal =>
      yearIncomeBySource.values.fold(0.0, (s, v) => s + v);
}

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onSeeAllExpenses;

  const DashboardScreen({super.key, this.onSeeAllExpenses});

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
        monthlyIncome: 0,
        dailyTotals: [],
        monthlyByCategory: {},
        weeklyByCategory: {},
        yearByCategory: {},
        monthlyIncomeBySource: {},
        weeklyIncomeBySource: {},
        yearIncomeBySource: {},
        recent: [],
        budgets: [],
        trend: [],
      );
    }
    final uid = user.id!;
    final now = DateTime.now();
    final weekStart = du.startOfWeek(now);
    final weekEnd = du.endOfWeek(now);

    final results = await Future.wait([
      ExpenseRepository.instance.getMonthlyTotal(
        userId: uid,
        year: now.year,
        month: now.month,
      ),
      ExpenseRepository.instance.getDailyTotalsForLastNDays(
        userId: uid,
        days: 7,
      ),
      ExpenseRepository.instance.getMonthlyTotalByCategory(
        userId: uid,
        year: now.year,
        month: now.month,
      ),
      ExpenseRepository.instance.getRangeTotalByCategory(
        userId: uid,
        from: weekStart,
        to: weekEnd,
      ),
      ExpenseRepository.instance.getAllForUser(uid),
      BudgetRepository.instance.getAllForUser(uid),
      IncomeRepository.instance.getMonthlyTotal(
        userId: uid,
        year: now.year,
        month: now.month,
      ),
      IncomeRepository.instance.getMonthlyTotalBySource(
        userId: uid,
        year: now.year,
        month: now.month,
      ),
      IncomeRepository.instance.getRangeTotalBySource(
        userId: uid,
        from: weekStart,
        to: weekEnd,
      ),
      ExpenseRepository.instance.getYearTotalByCategory(
        userId: uid,
        year: now.year,
      ),
      IncomeRepository.instance.getYearTotalBySource(
        userId: uid,
        year: now.year,
      ),
    ]);

    final months = List.generate(
      6,
      (i) => DateTime(now.year, now.month - 5 + i, 1),
    );
    final trendResults = await Future.wait([
      for (final m in months) ...[
        IncomeRepository.instance.getMonthlyTotal(
          userId: uid,
          year: m.year,
          month: m.month,
        ),
        ExpenseRepository.instance.getMonthlyTotal(
          userId: uid,
          year: m.year,
          month: m.month,
        ),
      ],
    ]);
    final trend = [
      for (var i = 0; i < months.length; i++)
        _MonthNet(
          year: months[i].year,
          month: months[i].month,
          income: trendResults[i * 2],
          expense: trendResults[i * 2 + 1],
        ),
    ];

    final all = results[4] as List<Expense>;
    return _DashboardData(
      monthlyTotal: results[0] as double,
      dailyTotals: results[1] as List<DailyTotal>,
      monthlyByCategory: results[2] as Map<String, double>,
      weeklyByCategory: results[3] as Map<String, double>,
      recent: all.take(_recentLimit).toList(),
      budgets: results[5] as List<Budget>,
      monthlyIncome: results[6] as double,
      monthlyIncomeBySource: results[7] as Map<String, double>,
      weeklyIncomeBySource: results[8] as Map<String, double>,
      yearByCategory: results[9] as Map<String, double>,
      yearIncomeBySource: results[10] as Map<String, double>,
      trend: trend,
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
    final l = context.l10n;
    final user = AuthService.instance.currentUser;
    if (user == null) return const SizedBox.shrink();
    final displayName =
        (user.fullName != null && user.fullName!.trim().isNotEmpty)
        ? user.fullName!.trim()
        : user.username;

    return FutureBuilder<_DashboardData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(l.loadingDataError));
        }
        final data = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async => reload(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            children: [
              _GreetingCard(name: displayName),
              const SizedBox(height: 12),
              _NetBalanceCard(
                income: data.monthlyIncome,
                expense: data.monthlyTotal,
                net: data.netBalance,
              ),
              const SizedBox(height: 12),
              BudgetAlertBanner(alerts: _buildAlerts(data)),
              const SizedBox(height: 4),
              _WeeklyChartCard(data: data.dailyTotals),
              const SizedBox(height: 12),
              _SixMonthSummaryCard(trend: data.trend),
              const SizedBox(height: 12),
              _CategoryBreakdownCard(
                monthlyByCategory: data.monthlyByCategory,
                weeklyByCategory: data.weeklyByCategory,
                yearByCategory: data.yearByCategory,
                monthlyTotal: data.monthlyTotal,
                weeklyTotal: data.weeklyTotal,
                yearTotal: data.yearTotal,
                monthlyIncomeBySource: data.monthlyIncomeBySource,
                weeklyIncomeBySource: data.weeklyIncomeBySource,
                yearIncomeBySource: data.yearIncomeBySource,
                monthlyIncomeTotal: data.monthlyIncomeTotal,
                weeklyIncomeTotal: data.weeklyIncomeTotal,
                yearIncomeTotal: data.yearIncomeTotal,
              ),
              const SizedBox(height: 12),
              _RecentExpensesCard(
                recent: data.recent,
                onTap: _openExpense,
                onSeeAll: widget.onSeeAllExpenses,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final String name;
  const _GreetingCard({required this.name});

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
          context.l10n.greeting(name),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(context.l10n.greetingSubtitle),
      ),
    );
  }
}

class _NetBalanceCard extends StatelessWidget {
  final double income;
  final double expense;
  final double net;

  const _NetBalanceCard({
    required this.income,
    required this.expense,
    required this.net,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final netColor = net >= 0 ? _positive : theme.colorScheme.error;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.netBalanceTitle,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Formatters.money(net),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: netColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _BalanceLeg(
                    icon: Icons.arrow_upward,
                    color: _positive,
                    label: l.incomeWord,
                    amount: income,
                  ),
                ),
                Expanded(
                  child: _BalanceLeg(
                    icon: Icons.arrow_downward,
                    color: theme.colorScheme.error,
                    label: l.expenseWord,
                    amount: expense,
                  ),
                ),
              ],
            ),
            if (income <= 0) ...[
              const SizedBox(height: 8),
              Text(
                l.noIncomeThisMonth,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BalanceLeg extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final double amount;

  const _BalanceLeg({
    required this.icon,
    required this.color,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withValues(alpha: 0.15),
          foregroundColor: color,
          child: Icon(icon, size: 18),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              Text(
                Formatters.money(amount),
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
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
            Text(
              context.l10n.weeklyChartTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            WeeklyBarChart(data: data),
          ],
        ),
      ),
    );
  }
}

class _SixMonthSummaryCard extends StatefulWidget {
  final List<_MonthNet> trend;
  const _SixMonthSummaryCard({required this.trend});

  @override
  State<_SixMonthSummaryCard> createState() => _SixMonthSummaryCardState();
}

class _SixMonthSummaryCardState extends State<_SixMonthSummaryCard> {
  int? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.trend.isNotEmpty) _selected = widget.trend.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final trend = widget.trend;
    if (trend.isEmpty) return const SizedBox.shrink();

    final expenseColor = theme.colorScheme.primary;
    final monthFmt = DateFormat('MMM', Intl.defaultLocale);
    final maxVal = trend.fold<double>(0, (m, e) {
      final localMax = e.income > e.expense ? e.income : e.expense;
      return localMax > m ? localMax : m;
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.sixMonthSummaryTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                _LegendDot(color: _positive, label: l.incomeWord),
                const SizedBox(width: 16),
                _LegendDot(color: expenseColor, label: l.expenseWord),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < trend.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _selected = i),
                        child: _MonthBars(
                          month: trend[i],
                          maxVal: maxVal,
                          selected: _selected == i,
                          incomeColor: _positive,
                          expenseColor: expenseColor,
                          label: monthFmt.format(
                            DateTime(trend[i].year, trend[i].month),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_selected != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _MonthDetail(month: trend[_selected!]),
            ],
          ],
        ),
      ),
    );
  }
}

class _MonthBars extends StatelessWidget {
  final _MonthNet month;
  final double maxVal;
  final bool selected;
  final Color incomeColor;
  final Color expenseColor;
  final String label;

  const _MonthBars({
    required this.month,
    required this.maxVal,
    required this.selected,
    required this.incomeColor,
    required this.expenseColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emptyColor = theme.colorScheme.surfaceContainerHighest;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                double barH(double v) => maxVal == 0
                    ? 2.0
                    : (v / maxVal * (c.maxHeight - 2)).clamp(
                        v > 0 ? 2.0 : 0.0,
                        c.maxHeight,
                      );
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Bar(
                      height: barH(month.income),
                      color: month.income > 0 ? incomeColor : emptyColor,
                    ),
                    const SizedBox(width: 2),
                    _Bar(
                      height: barH(month.expense),
                      color: month.expense > 0 ? expenseColor : emptyColor,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;
  const _Bar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
      ),
    );
  }
}

class _MonthDetail extends StatelessWidget {
  final _MonthNet month;
  const _MonthDetail({required this.month});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final netColor = month.net >= 0 ? _positive : theme.colorScheme.error;
    final monthName = DateFormat(
      'MMMM yyyy',
      Intl.defaultLocale,
    ).format(DateTime(month.year, month.month));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          monthName,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _DetailItem(
                label: l.incomeWord,
                value: Formatters.money(month.income),
                color: _positive,
              ),
            ),
            Expanded(
              child: _DetailItem(
                label: l.expenseWord,
                value: Formatters.money(month.expense),
                color: theme.colorScheme.error,
              ),
            ),
            Expanded(
              child: _DetailItem(
                label: l.netWord,
                value: Formatters.money(month.net),
                color: netColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _DetailItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w700, color: color),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

enum _Kind { expense, income }

enum _Period { week, month, year }

class _CategoryBreakdownCard extends StatefulWidget {
  final Map<String, double> monthlyByCategory;
  final Map<String, double> weeklyByCategory;
  final Map<String, double> yearByCategory;
  final double monthlyTotal;
  final double weeklyTotal;
  final double yearTotal;
  final Map<String, double> monthlyIncomeBySource;
  final Map<String, double> weeklyIncomeBySource;
  final Map<String, double> yearIncomeBySource;
  final double monthlyIncomeTotal;
  final double weeklyIncomeTotal;
  final double yearIncomeTotal;

  const _CategoryBreakdownCard({
    required this.monthlyByCategory,
    required this.weeklyByCategory,
    required this.yearByCategory,
    required this.monthlyTotal,
    required this.weeklyTotal,
    required this.yearTotal,
    required this.monthlyIncomeBySource,
    required this.weeklyIncomeBySource,
    required this.yearIncomeBySource,
    required this.monthlyIncomeTotal,
    required this.weeklyIncomeTotal,
    required this.yearIncomeTotal,
  });

  @override
  State<_CategoryBreakdownCard> createState() => _CategoryBreakdownCardState();
}

class _CategoryBreakdownCardState extends State<_CategoryBreakdownCard> {
  _Kind _kind = _Kind.expense;
  _Period _period = _Period.month;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isIncome = _kind == _Kind.income;

    final Map<String, double> map;
    final double total;
    if (isIncome) {
      map = switch (_period) {
        _Period.week => widget.weeklyIncomeBySource,
        _Period.month => widget.monthlyIncomeBySource,
        _Period.year => widget.yearIncomeBySource,
      };
      total = switch (_period) {
        _Period.week => widget.weeklyIncomeTotal,
        _Period.month => widget.monthlyIncomeTotal,
        _Period.year => widget.yearIncomeTotal,
      };
    } else {
      map = switch (_period) {
        _Period.week => widget.weeklyByCategory,
        _Period.month => widget.monthlyByCategory,
        _Period.year => widget.yearByCategory,
      };
      total = switch (_period) {
        _Period.week => widget.weeklyTotal,
        _Period.month => widget.monthlyTotal,
        _Period.year => widget.yearTotal,
      };
    }

    AppCategory resolve(String name) => isIncome
        ? CategoryService.instance.incomeByName(name)
        : CategoryService.instance.byName(name);

    final entries = map.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final slices = [
      for (final e in entries)
        PieSlice(category: resolve(e.key), amount: e.value),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.categoryBreakdownTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<_Kind>(
              segments: [
                ButtonSegment(
                  value: _Kind.expense,
                  label: Text(l.expenseDistribution),
                ),
                ButtonSegment(
                  value: _Kind.income,
                  label: Text(l.incomeDistribution),
                ),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
            const SizedBox(height: 8),
            SegmentedButton<_Period>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: _Period.week,
                  label: Text(l.filterThisWeek),
                ),
                ButtonSegment(
                  value: _Period.month,
                  label: Text(l.filterThisMonth),
                ),
                ButtonSegment(
                  value: _Period.year,
                  label: Text(l.filterThisYear),
                ),
              ],
              selected: {_period},
              onSelectionChanged: (s) => setState(() => _period = s.first),
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  isIncome ? l.noIncomeThisPeriod : l.noExpensesThisMonth,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              )
            else ...[
              Center(child: CategoryPieChart(slices: slices)),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              for (final e in entries) ...[
                _CategoryRow(
                  category: resolve(e.key),
                  amount: e.value,
                  percent: total <= 0 ? 0 : (e.value / total),
                ),
                const SizedBox(height: 8),
              ],
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
  final VoidCallback? onSeeAll;

  const _RecentExpensesCard({
    required this.recent,
    required this.onTap,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.recentExpensesTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: EmptyState(
                  icon: Icons.history,
                  title: l.emptyExpensesTitle,
                ),
              )
            else ...[
              for (final e in recent)
                ExpenseTile(expense: e, onTap: () => onTap(e)),
              if (onSeeAll != null) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    onPressed: onSeeAll,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: Text(l.showMore),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
