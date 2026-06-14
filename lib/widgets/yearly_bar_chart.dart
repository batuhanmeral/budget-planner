import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/expense_repository.dart';

class YearlyBarChart extends StatelessWidget {
  final List<MonthTotal> data;
  final double height;

  const YearlyBarChart({super.key, required this.data, this.height = 160});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.fold<double>(0, (m, e) => e.total > m ? e.total : m);
    final monthFmt = DateFormat('MMM', Intl.defaultLocale);
    final theme = Theme.of(context);
    final barColor = theme.colorScheme.primary;
    final emptyColor = theme.colorScheme.surfaceContainerHighest;
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final m in data)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final h = maxVal == 0
                              ? 4.0
                              : (m.total / maxVal) * (c.maxHeight - 4);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: h.clamp(4.0, c.maxHeight),
                                decoration: BoxDecoration(
                                  color: m.total == 0 ? emptyColor : barColor,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      monthFmt.format(DateTime(2024, m.month)),
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
