import 'package:flutter/material.dart';

import '../app/locale_controller.dart';

Future<bool> confirmDiscardChanges(BuildContext context) async {
  final l = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(l.unsavedTitle),
      content: Text(l.unsavedMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l.unsavedStay),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l.unsavedDiscard),
        ),
      ],
    ),
  );
  return result ?? false;
}
