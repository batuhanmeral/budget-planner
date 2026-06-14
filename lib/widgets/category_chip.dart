import 'package:flutter/material.dart';

import '../app/app_constants.dart';

class CategoryChip extends StatelessWidget {
  final AppCategory category;
  final bool dense;

  const CategoryChip({super.key, required this.category, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final bg = category.color.withValues(alpha: 0.15);
    final fg = category.color;
    final padding = dense
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 6);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: dense ? 14 : 16, color: fg),
          const SizedBox(width: 6),
          Text(
            category.name,
            style: TextStyle(
              color: fg,
              fontSize: dense ? 12 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
