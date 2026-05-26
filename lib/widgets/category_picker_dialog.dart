import 'package:flutter/material.dart';

import '../app/app_constants.dart';
import '../app/locale_controller.dart';
import '../services/category_service.dart';

/// Bir kategori seçtirip [AppCategory] döndüren basit diyalog.
///
/// Toplu seçim akışında "Kategori değiştir" butonu bunu çağırır.
/// Hem sabit hem özel kategoriler listelenir.
Future<AppCategory?> pickCategory(BuildContext context) async {
  final l = context.l10n;
  return showDialog<AppCategory>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: Text(l.pickCategoryTitle),
      children: [
        for (final c in CategoryService.instance.all)
          SimpleDialogOption(
            onPressed: () => Navigator.of(ctx).pop(c),
            child: Row(
              children: [
                Icon(c.icon, color: c.color),
                const SizedBox(width: 12),
                Text(c.name),
              ],
            ),
          ),
      ],
    ),
  );
}
