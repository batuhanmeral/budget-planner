import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/app_constants.dart';
import '../services/expense_repository.dart';
import '../utils/formatters.dart';

/// Son 7 gün için günlük toplam harcama bar grafiği.
///
/// Üçüncü parti charting paketi (fl_chart vb.) **KULLANILMAZ** —
/// müfredat kapsamı dışına çıkmamak için saf Flutter widget'larıyla
/// (Row + Container + LayoutBuilder) çizilir.
///
/// En yüksek değer 100% yüksekliği belirler; diğer barlar orantılı.
/// Sıfır olan günler küçük gri çubuk ile gösterilir (var olduğunu
/// belirtmek için).
class WeeklyBarChart extends StatelessWidget {
  final List<DailyTotal> data;
  final double height;

  const WeeklyBarChart({super.key, required this.data, this.height = 160});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.fold<double>(0, (m, d) => d.total > m ? d.total : m);
    final dayFmt = DateFormat('EEE', AppStrings.locale);
    final theme = Theme.of(context);
    final barColor = theme.colorScheme.primary;
    final emptyColor = theme.colorScheme.surfaceContainerHighest;
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final d in data)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final h = maxVal == 0
                              ? 4.0
                              : (d.total / maxVal) * (c.maxHeight - 24);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (d.total > 0)
                                Text(
                                  Formatters.money(d.total),
                                  style: theme.textTheme.labelSmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 2),
                              Container(
                                height: h.clamp(4.0, c.maxHeight),
                                decoration: BoxDecoration(
                                  color: d.total == 0 ? emptyColor : barColor,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dayFmt.format(d.date),
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
