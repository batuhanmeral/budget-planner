import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_constants.dart';
import '../models/expense.dart';
import '../services/auth_service.dart';
import '../services/expense_repository.dart';
import '../utils/date_utils.dart' as du;
import '../utils/money_utils.dart';
import '../utils/validators.dart';
import 'category_chip.dart';

/// Tek bir kategoriye bugünün tarihiyle hızlı harcama eklemek için
/// bottom sheet.
///
/// Kategori önceden chip ile seçilmiş geldiği için form sadece tutar
/// ve opsiyonel not içerir. Tarih = bugün. Klavye otomatik açılır.
///
/// Başarılı kayıt sonrası `true` ile pop olur — çağıran dashboard'u
/// reload edebilir.
Future<bool> showQuickAddSheet(
  BuildContext context, {
  required AppCategory category,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      // Klavye açıkken sheet üst kısmı görünür kalsın.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom,
      ),
      child: _QuickAddSheet(category: category),
    ),
  );
  return result ?? false;
}

class _QuickAddSheet extends StatefulWidget {
  final AppCategory category;
  const _QuickAddSheet({required this.category});

  @override
  State<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<_QuickAddSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final amount = parseMoneyInput(_amountCtrl.text);
    if (amount == null) return;

    setState(() => _busy = true);
    try {
      final note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();
      await ExpenseRepository.instance.insert(
        Expense(
          userId: user.id!,
          amount: amount,
          category: widget.category.name,
          date: du.stripTime(DateTime.now()),
          note: note,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kaydedilemedi')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hızlı Harcama',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  CategoryChip(category: widget.category),
                  const SizedBox(width: 8),
                  Text(
                    'Bugün',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Tutar',
                  prefixIcon: Icon(Icons.payments_outlined),
                  suffixText: AppStrings.currencySymbol,
                ),
                validator: Validators.moneyAmount,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (opsiyonel)',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLength: 200,
                validator: (v) => Validators.maxLength(v, 200),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
