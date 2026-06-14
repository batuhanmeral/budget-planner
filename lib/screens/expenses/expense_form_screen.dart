import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_constants.dart';
import '../../app/currency_controller.dart';
import '../../app/locale_controller.dart';
import '../../models/expense.dart';
import '../../models/recurring_expense.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/expense_repository.dart';
import '../../services/recurring_expense_repository.dart';
import '../../services/recurring_expense_runner.dart';
import '../../utils/date_utils.dart' as du;
import '../../utils/formatters.dart';
import '../../utils/money_utils.dart';
import '../../utils/validators.dart';
import '../../widgets/unsaved_changes_dialog.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? initial;

  const ExpenseFormScreen({super.key, this.initial});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;

  late AppCategory _category;
  late DateTime _date;
  bool _recurring = false;
  bool _busy = false;
  bool _dirty = false;
  late final String _initialSignature;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    _amountCtrl = TextEditingController(
      text: e == null ? '' : e.amount.toStringAsFixed(2).replaceAll('.', ','),
    );
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _category = e == null
        ? AppCategories.yemek
        : CategoryService.instance.byName(e.category);
    _date = du.stripTime(e?.date ?? DateTime.now());
    _initialSignature = _signature();
    _amountCtrl.addListener(_markDirty);
    _noteCtrl.addListener(_markDirty);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String _signature() =>
      '${_amountCtrl.text}|${_noteCtrl.text}|${_category.name}|${du.formatDateOnly(_date)}|$_recurring';

  void _markDirty() {
    final next = _signature() != _initialSignature;
    if (next != _dirty) setState(() => _dirty = next);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null) return;
    setState(() {
      _date = du.stripTime(picked);
      _markDirty();
    });
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
      if (_isEdit) {
        final updated = widget.initial!.copyWith(
          amount: amount,
          category: _category.name,
          date: _date,
          note: note,
          clearNote: note == null,
        );
        await ExpenseRepository.instance.update(updated);
      } else {
        final expense = Expense(
          userId: user.id!,
          amount: amount,
          category: _category.name,
          date: _date,
          note: note,
        );
        await ExpenseRepository.instance.insert(expense);

        if (_recurring) {
          final ym = du.monthPrefix(_date.year, _date.month);
          await RecurringExpenseRepository.instance.insert(
            RecurringExpense(
              userId: user.id!,
              amount: amount,
              category: _category.name,
              note: note,
              dayOfMonth: _date.day,
              lastInsertedYearMonth: ym,
            ),
          );
          // Geçmiş tarihli şablonsa aradaki ayları bugüne kadar geri doldur.
          await RecurringExpenseRunner.runForUser(user.id!);
        }
      }
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
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final ok = await confirmDiscardChanges(context);
        if (ok && mounted) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? l.editExpenseTitle : l.newExpenseTitle),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: InputDecoration(
                      labelText: l.amountLabel,
                      prefixIcon: Icon(Icons.payments_outlined),
                      suffixText: CurrencyController.instance.symbol,
                    ),
                    validator: Validators.moneyAmount,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AppCategory>(
                    initialValue: _category,
                    decoration: InputDecoration(
                      labelText: l.categoryLabel,
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: [
                      for (final c in CategoryService.instance.all)
                        DropdownMenuItem(
                          value: c,
                          child: Row(
                            children: [
                              Icon(c.icon, color: c.color, size: 20),
                              const SizedBox(width: 8),
                              Text(c.name),
                            ],
                          ),
                        ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _category = v;
                        _markDirty();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l.dateLabel,
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(Formatters.dateLong(_date)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _noteCtrl,
                    decoration: InputDecoration(
                      labelText: l.noteOptionalLabel,
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 3,
                    maxLength: 200,
                    validator: (v) => Validators.maxLength(v, 200),
                  ),
                  if (!_isEdit)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(Icons.repeat),
                      title: Text(l.repeatMonthly),
                      subtitle: Text(
                        _recurring
                            ? l.repeatMonthlyHint(_date.day)
                            : l.repeatMonthlyOffHint,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      value: _recurring,
                      onChanged: (v) => setState(() {
                        _recurring = v;
                        _markDirty();
                      }),
                    ),
                  const SizedBox(height: 16),
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
                        : Text(_isEdit ? l.update : l.save),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
