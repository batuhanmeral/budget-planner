import 'package:flutter/material.dart';

import '../app/app_constants.dart';
import '../models/income.dart';
import '../utils/formatters.dart';

class IncomeTile extends StatelessWidget {
  final Income income;
  final VoidCallback? onTap;

  const IncomeTile({super.key, required this.income, this.onTap});

  @override
  Widget build(BuildContext context) {
    final src = IncomeSources.byName(income.source);
    const positive = Color(0xFF16A34A);
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: src.color.withValues(alpha: 0.15),
          foregroundColor: src.color,
          child: Icon(src.icon),
        ),
        title: Text(
          '+${Formatters.money(income.amount)}',
          style: const TextStyle(fontWeight: FontWeight.w700, color: positive),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  src.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: src.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    Formatters.dateShort(income.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            if (income.note != null && income.note!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                income.note!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
