import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/locale_controller.dart';
import '../../models/income.dart';
import '../../services/auth_service.dart';
import '../../services/income_repository.dart';
import '../../utils/date_utils.dart' as du;
import '../../utils/formatters.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/income_tile.dart';
import 'income_detail_screen.dart';

const _incomeColor = Color(0xFF16A34A);

class IncomeCalendarView extends StatefulWidget {
  const IncomeCalendarView({super.key});

  @override
  State<IncomeCalendarView> createState() => _IncomeCalendarViewState();
}

class _IncomeCalendarViewState extends State<IncomeCalendarView> {
  late DateTime _currentMonth;
  late Future<Map<int, double>> _future;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _future = _load();
  }

  Future<Map<int, double>> _load() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return const {};
    final incomes = await IncomeRepository.instance.getByDateRange(
      userId: user.id!,
      from: du.startOfMonth(_currentMonth),
      to: du.endOfMonth(_currentMonth),
    );
    final byDay = <int, double>{};
    for (final e in incomes) {
      byDay[e.date.day] = (byDay[e.date.day] ?? 0) + e.amount;
    }
    return byDay;
  }

  void _shiftMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + delta,
        1,
      );
      _future = _load();
    });
  }

  Future<void> _showDay(DateTime day) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final dayIncomes = await IncomeRepository.instance.getByDateRange(
      userId: user.id!,
      from: day,
      to: day,
    );
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => _DayIncomesSheet(day: day, incomes: dayIncomes),
    );
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final monthFmt = DateFormat('MMMM y', Intl.defaultLocale);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _shiftMonth(-1),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    monthFmt.format(_currentMonth),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _shiftMonth(1),
              ),
            ],
          ),
        ),
        const _WeekdayHeader(),
        const SizedBox(height: 4),
        Expanded(
          child: FutureBuilder<Map<int, double>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final byDay = snapshot.data ?? const <int, double>{};
              return _CalendarGrid(
                month: _currentMonth,
                totalsByDay: byDay,
                onDayTap: _showDay,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.E(Intl.defaultLocale);
    final labels = List.generate(
      7,
      (i) => fmt.format(DateTime(2026, 5, 25).add(Duration(days: i))),
    );
    final color = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (final l in labels)
            Expanded(
              child: Center(
                child: Text(
                  l,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final Map<int, double> totalsByDay;
  final ValueChanged<DateTime> onDayTap;

  const _CalendarGrid({
    required this.month,
    required this.totalsByDay,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = firstDay.weekday - DateTime.monday;
    final totalCells = leadingEmpty + daysInMonth;
    final trailingEmpty = (7 - (totalCells % 7)) % 7;
    final cells = totalCells + trailingEmpty;

    final maxAmount = totalsByDay.values.fold<double>(
      0,
      (m, v) => v > m ? v : m,
    );
    final today = DateTime.now();
    final isCurrentMonth =
        today.year == month.year && today.month == month.month;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.85,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: cells,
      itemBuilder: (_, i) {
        final dayNumber = i - leadingEmpty + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }
        final amount = totalsByDay[dayNumber] ?? 0.0;
        final isToday = isCurrentMonth && dayNumber == today.day;
        return _DayCell(
          dayNumber: dayNumber,
          amount: amount,
          maxAmount: maxAmount,
          isToday: isToday,
          onTap: () => onDayTap(DateTime(month.year, month.month, dayNumber)),
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  final int dayNumber;
  final double amount;
  final double maxAmount;
  final bool isToday;
  final VoidCallback onTap;

  const _DayCell({
    required this.dayNumber,
    required this.amount,
    required this.maxAmount,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasAmount = amount > 0;
    final ratio = maxAmount <= 0 ? 0.0 : (amount / maxAmount).clamp(0.0, 1.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isToday
                ? _incomeColor
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: isToday ? 1.5 : 1,
          ),
          color: hasAmount ? _incomeColor.withValues(alpha: 0.06) : null,
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$dayNumber',
              style: TextStyle(
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: isToday ? _incomeColor : null,
                fontSize: 13,
              ),
            ),
            if (hasAmount)
              Container(
                height: (4 + ratio * 14),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _incomeColor.withValues(alpha: 0.6 + ratio * 0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              )
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _DayIncomesSheet extends StatelessWidget {
  final DateTime day;
  final List<Income> incomes;

  const _DayIncomesSheet({required this.day, required this.incomes});

  Future<void> _openDetail(BuildContext context, Income income) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IncomeDetailScreen(incomeId: income.id!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = incomes.fold<double>(0, (s, e) => s + e.amount);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Formatters.dateLong(day),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (incomes.isNotEmpty)
                        Text(
                          '+${Formatters.money(total)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _incomeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            if (incomes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: EmptyState(
                  icon: Icons.savings_outlined,
                  title: context.l10n.emptyIncomesTitle,
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: incomes.length,
                  itemBuilder: (_, i) => IncomeTile(
                    income: incomes[i],
                    onTap: () => _openDetail(context, incomes[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
