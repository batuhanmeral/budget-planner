import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_constants.dart';
import '../app/locale_controller.dart';
import '../models/expense.dart';
import '../services/auth_service.dart';
import '../services/expense_repository.dart';
import '../utils/date_utils.dart' as du;
import '../utils/money_utils.dart';
import '../utils/validators.dart';
import 'category_chip.dart';

Future<bool> showQuickAddSheet(
  BuildContext context, {
  required AppCategory category,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
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
        SnackBar(content: Text(LocaleController.instance.l10n.notSaved)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
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
                      l.quickAddSheetTitle,
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
                  Text(l.today, style: Theme.of(context).textTheme.bodySmall),
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
                decoration: InputDecoration(
                  labelText: l.amountLabel,
                  prefixIcon: Icon(Icons.payments_outlined),
                  suffixText: AppStrings.currencySymbol,
                ),
                validator: Validators.moneyAmount,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                decoration: InputDecoration(
                  labelText: l.noteOptionalLabel,
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
                    : Text(l.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
