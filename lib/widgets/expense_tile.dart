import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/category_service.dart';
import '../utils/formatters.dart';
import 'category_chip.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;

  const ExpenseTile({
    super.key,
    required this.expense,
    this.onTap,
    this.onLongPress,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final cat = CategoryService.instance.byName(expense.category);
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      color: selected ? primary.withValues(alpha: 0.12) : null,
      shape: selected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: primary, width: 1.5),
            )
          : null,
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: selected
            ? CircleAvatar(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                child: const Icon(Icons.check),
              )
            : CircleAvatar(
                backgroundColor: cat.color.withValues(alpha: 0.15),
                foregroundColor: cat.color,
                child: Icon(cat.icon),
              ),
        title: Text(
          Formatters.money(expense.amount),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                CategoryChip(category: cat, dense: true),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    Formatters.dateShort(expense.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            if (expense.note != null && expense.note!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                expense.note!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        trailing: selected ? null : const Icon(Icons.chevron_right),
      ),
    );
  }
}
