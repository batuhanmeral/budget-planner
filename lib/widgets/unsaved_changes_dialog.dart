import 'package:flutter/material.dart';

/// Form ekranlarında kullanıcı bir alana yazdıktan sonra geri tuşuna
/// basarsa gösterilen "kaydedilmemiş değişiklikler" onay diyalogu.
///
/// Form ekranları [PopScope] ile `canPop: !isDirty` belirtir; pop
/// engellenirse bu diyalog gösterilir ve yanıt true ise pop manuel
/// yapılır.
///
/// Kullanıcı "Çık"ı seçerse `true`, "Vazgeç" veya dışarı tıklarsa
/// `false` döner.
Future<bool> confirmDiscardChanges(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Değişiklikler kaydedilmedi'),
      content: const Text(
        'Yaptığınız değişiklikler kaybolacak. Çıkmak istediğinize emin misiniz?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Vazgeç'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Çık'),
        ),
      ],
    ),
  );
  return result ?? false;
}
