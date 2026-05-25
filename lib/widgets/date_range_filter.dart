import 'package:flutter/material.dart';

import '../utils/date_utils.dart' as du;
import '../utils/formatters.dart';

/// Hızlı tarih aralığı önayarları.
enum DateRangePreset { thisWeek, thisMonth, custom }

/// Tarih aralığı seçim sonucu — önayar türü + başlangıç/bitiş tarihi.
///
/// Custom değilse [from] ve [to] otomatik [du.startOfWeek/startOfMonth]
/// gibi yardımcılardan üretilir.
class DateRangeValue {
  final DateRangePreset preset;
  final DateTime from;
  final DateTime to;
  const DateRangeValue({
    required this.preset,
    required this.from,
    required this.to,
  });

  static DateRangeValue thisMonth() {
    final now = DateTime.now();
    return DateRangeValue(
      preset: DateRangePreset.thisMonth,
      from: du.startOfMonth(now),
      to: du.endOfMonth(now),
    );
  }

  static DateRangeValue thisWeek() {
    final now = DateTime.now();
    return DateRangeValue(
      preset: DateRangePreset.thisWeek,
      from: du.startOfWeek(now),
      to: du.endOfWeek(now),
    );
  }
}

/// Üç ChoiceChip'ten oluşan tarih filtresi: **Bu Hafta · Bu Ay · Özel**.
///
/// Özel seçildiğinde [showDateRangePicker] açılır; iptal edilirse mevcut
/// değer korunur, seçilirse [onChanged] tetiklenir.
class DateRangeFilter extends StatelessWidget {
  final DateRangeValue value;
  final ValueChanged<DateRangeValue> onChanged;

  const DateRangeFilter({
    super.key,
    required this.value,
    required this.onChanged,
  });

  Future<void> _pickCustom(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(start: value.from, end: value.to),
    );
    if (picked == null) return;
    onChanged(
      DateRangeValue(
        preset: DateRangePreset.custom,
        from: du.stripTime(picked.start),
        to: du.stripTime(picked.end),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Bu Hafta'),
              selected: value.preset == DateRangePreset.thisWeek,
              onSelected: (_) => onChanged(DateRangeValue.thisWeek()),
            ),
            ChoiceChip(
              label: const Text('Bu Ay'),
              selected: value.preset == DateRangePreset.thisMonth,
              onSelected: (_) => onChanged(DateRangeValue.thisMonth()),
            ),
            ChoiceChip(
              label: const Text('Özel'),
              selected: value.preset == DateRangePreset.custom,
              onSelected: (_) => _pickCustom(context),
            ),
          ],
        ),
        if (value.preset == DateRangePreset.custom) ...[
          const SizedBox(height: 6),
          Text(
            '${Formatters.dateShort(value.from)} → ${Formatters.dateShort(value.to)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
