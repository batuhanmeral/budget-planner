import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyIncomeExpense {
  final int month;
  final double income;
  final double expense;
  const MonthlyIncomeExpense({
    required this.month,
    required this.income,
    required this.expense,
  });
}

class IncomeExpenseBarChart extends StatelessWidget {
  final List<MonthlyIncomeExpense> data;
  final double height;

  static const incomeColor = Color(0xFF16A34A);

  const IncomeExpenseBarChart({
    super.key,
    required this.data,
    this.height = 170,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseColor = theme.colorScheme.primary;
    final emptyColor = theme.colorScheme.surfaceContainerHighest;
    final monthFmt = DateFormat('MMM', Intl.defaultLocale);

    final maxVal = data.fold<double>(0, (m, e) {
      final localMax = e.income > e.expense ? e.income : e.expense;
      return localMax > m ? localMax : m;
    });

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final e in data)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
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
                                height: barH(e.income),
                                color: e.income > 0 ? incomeColor : emptyColor,
                              ),
                              const SizedBox(width: 2),
                              _Bar(
                                height: barH(e.expense),
                                color: e.expense > 0
                                    ? expenseColor
                                    : emptyColor,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      monthFmt.format(DateTime(2024, e.month)),
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
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
      width: 5,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
      ),
    );
  }
}
