import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/category_service.dart';
import '../utils/formatters.dart';
import 'category_chip.dart';

/// Listede tek bir harcamayı gösteren kart.
///
/// Sol: kategori renkli daire ikon. Sağ üst: tutar (kalın). Altta:
/// kategori chip + tarih + (varsa) açıklama (max 2 satır). En sağda:
/// chevron ikonu — tıklanabilir olduğunu gösterir.
///
/// [onTap] verilirse detaya yönlendirir; null verilirse pasif.
class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;

  const ExpenseTile({super.key, required this.expense, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cat = CategoryService.instance.byName(expense.category);
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
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
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
