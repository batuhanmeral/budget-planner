import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/expense_repository.dart';

/// 12 ay için aylık toplam harcamayı gösteren bar grafiği.
///
/// [WeeklyBarChart] ile aynı saf-widget yaklaşımı: paket yok,
/// `Row + Container + LayoutBuilder` ile orantılı barlar.
/// X ekseninde 3 harfli ay kısaltmaları (Oca, Şub, ...) gösterilir.
class YearlyBarChart extends StatelessWidget {
  final List<MonthTotal> data;
  final double height;

  const YearlyBarChart({super.key, required this.data, this.height = 160});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.fold<double>(
      0,
      (m, e) => e.total > m ? e.total : m,
    );
    // Türkçe ay kısaltması — DateFormat 'MMM' lokal ile.
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
                          // Boş ay için minimum 4px; en yüksek ay c.maxHeight - 4.
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
                      // Türkçe locale ay kısaltması — DateTime(2024, m) ile.
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
