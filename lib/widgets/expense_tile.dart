import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/category_service.dart';
import '../utils/formatters.dart';
import 'category_chip.dart';

/// Listede tek bir harcamayı gösteren kart.
///
/// Sol: kategori renkli daire ikon (seçim modunda checkbox). Sağ üst:
/// tutar (kalın). Altta: kategori chip + tarih + (varsa) açıklama
/// (max 2 satır).
///
/// Toplu seçim akışı için:
/// - [selected] true ise vurgulu görsel (border + arka plan).
/// - [onLongPress] genelde seçim modunu açmak için kullanılır.
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
      // Seçili olduğunda primary tonunda hafif overlay ile vurgulu.
      color: selected
          ? primary.withValues(alpha: 0.12)
          : null,
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
        // Seçim modunda chevron yerine boşluk — checkbox baştadır.
        trailing: selected ? null : const Icon(Icons.chevron_right),
      ),
    );
  }
}
