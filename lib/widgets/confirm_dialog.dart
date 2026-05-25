import 'package:flutter/material.dart';

/// Genel amaçlı onay diyalogu helper'ı.
///
/// Silme gibi geri alınamaz işlemler için kullanılır. `destructive`
/// true (varsayılan) onay butonunu kırmızı yapar.
///
/// Kullanıcı "Vazgeç"e bastıysa veya diyalogu kapattıysa `false` döner;
/// onay butonuna bastıysa `true`.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Sil',
  String cancelLabel = 'Vazgeç',
  bool destructive = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          style: destructive
              ? TextButton.styleFrom(foregroundColor: Colors.red)
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
