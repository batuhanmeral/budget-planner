import 'package:flutter/material.dart';

import '../app/app_constants.dart';
import '../services/category_service.dart';

/// Bir kategori seçtirip [AppCategory] döndüren basit diyalog.
///
/// Toplu seçim akışında "Kategori değiştir" butonu bunu çağırır.
/// Hem sabit hem özel kategoriler listelenir.
Future<AppCategory?> pickCategory(BuildContext context) async {
  return showDialog<AppCategory>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: const Text('Kategori seç'),
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
