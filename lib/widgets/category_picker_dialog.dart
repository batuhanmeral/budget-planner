import 'package:flutter/material.dart';

import '../app/app_constants.dart';
import '../app/locale_controller.dart';
import '../services/category_service.dart';

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
