import 'package:flutter/material.dart';

import '../app/locale_controller.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = true,
}) async {
  final l = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel ?? l.cancel),
        ),
        TextButton(
          style: destructive
              ? TextButton.styleFrom(foregroundColor: Colors.red)
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel ?? l.delete),
        ),
      ],
    ),
  );
  return result ?? false;
}
