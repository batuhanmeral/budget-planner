import 'package:flutter/material.dart';

import '../app/app_constants.dart';
import '../utils/formatters.dart';
import 'category_chip.dart';

class BudgetProgressCard extends StatelessWidget {
  final AppCategory category;
  final double spent;
  final double limit;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetProgressCard({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    this.onEdit,
    this.onDelete,
  });

  double get _ratio => limit <= 0 ? 0 : (spent / limit).clamp(0.0, 1.0);
  bool get _isOver => spent >= limit;
  bool get _isWarning => !_isOver && spent >= limit * 0.9;

  Color _barColor(BuildContext context) {
    if (_isOver) return Colors.red;
    if (_isWarning) return Colors.orange;
    return category.color;
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (limit - spent);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: CategoryChip(category: category)),
                if (_isOver)
                  const Icon(Icons.error_outline, color: Colors.red, size: 20)
                else if (_isWarning)
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 20),
                if (onEdit != null)
                  IconButton(
                    tooltip: 'Düzenle',
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: onEdit,
                  ),
                if (onDelete != null)
                  IconButton(
                    tooltip: 'Sil',
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: _ratio,
                minHeight: 10,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(_barColor(context)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${Formatters.money(spent)} / ${Formatters.money(limit)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  _isOver
                      ? 'Limit aşıldı'
                      : 'Kalan ${Formatters.money(remaining)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _isOver ? Colors.red : null,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
