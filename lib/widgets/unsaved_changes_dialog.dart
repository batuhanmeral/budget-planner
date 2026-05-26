import 'package:flutter/material.dart';

import '../app/locale_controller.dart';

/// Form ekranlarında kullanıcı bir alana yazdıktan sonra geri tuşuna
/// basarsa gösterilen "kaydedilmemiş değişiklikler" onay diyalogu.
///
/// Kullanıcı "Çık"ı seçerse `true`, "Vazgeç" veya dışarı tıklarsa
/// `false` döner.
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
