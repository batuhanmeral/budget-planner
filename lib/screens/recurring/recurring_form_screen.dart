import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_constants.dart';
import '../../models/recurring_expense.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/recurring_expense_repository.dart';
import '../../utils/money_utils.dart';
import '../../utils/validators.dart';
import '../../widgets/unsaved_changes_dialog.dart';

/// Tekrarlayan harcama şablonu ekleme/düzenleme formu.
///
/// Alanlar: tutar (TR virgül), kategori (dropdown), ayın günü
/// (1-31 slider/input), aktif toggle, opsiyonel not.
///
/// Ayın günü için NumberField yerine [Slider] kullanıyoruz — kullanıcı
/// için daha hızlı seçim. 31'i seçince "30/31 olmayan aylarda son güne
/// kaydırılır" notu gösterilir.
class RecurringFormScreen extends StatefulWidget {
  final RecurringExpense? initial;
  const RecurringFormScreen({super.key, this.initial});

  @override
  State<RecurringFormScreen> createState() => _RecurringFormScreenState();
}

class _RecurringFormScreenState extends State<RecurringFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;

  late AppCategory _category;
  late int _dayOfMonth;
  late bool _active;
  late final String _initialSignature;
  bool _dirty = false;
  bool _busy = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    _amountCtrl = TextEditingController(
      text: r == null
          ? ''
          : r.amount.toStringAsFixed(2).replaceAll('.', ','),
    );
    _noteCtrl = TextEditingController(text: r?.note ?? '');
    _category = r == null
        ? AppCategories.fatura
        : CategoryService.instance.byName(r.category);
    _dayOfMonth = r?.dayOfMonth ?? 1;
    _active = r?.active ?? true;
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
      '${_amountCtrl.text}|${_noteCtrl.text}|${_category.name}|$_dayOfMonth|$_active';

  void _markDirty() {
    final next = _signature() != _initialSignature;
    if (next != _dirty) setState(() => _dirty = next);
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
          note: note,
          clearNote: note == null,
          dayOfMonth: _dayOfMonth,
          active: _active,
        );
        await RecurringExpenseRepository.instance.update(updated);
      } else {
        final draft = RecurringExpense(
          userId: user.id!,
          amount: amount,
          category: _category.name,
          note: note,
          dayOfMonth: _dayOfMonth,
          active: _active,
        );
        await RecurringExpenseRepository.instance.insert(draft);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kaydedilemedi. Lütfen tekrar deneyin.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text(_isEdit ? 'Tekrarlayanı Düzenle' : 'Yeni Tekrarlayan'),
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
                    decoration: const InputDecoration(
                      labelText: 'Tutar',
                      prefixIcon: Icon(Icons.payments_outlined),
                      suffixText: AppStrings.currencySymbol,
                    ),
                    validator: Validators.moneyAmount,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AppCategory>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 20),
                      const SizedBox(width: 8),
                      const Text('Her ayın'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_dayOfMonth.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('günü'),
                    ],
                  ),
                  Slider(
                    value: _dayOfMonth.toDouble(),
                    min: 1,
                    max: 31,
                    divisions: 30,
                    label: '$_dayOfMonth',
                    onChanged: (v) => setState(() {
                      _dayOfMonth = v.round();
                      _markDirty();
                    }),
                  ),
                  if (_dayOfMonth > 28)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '30/31 günü olmayan aylarda son güne kaydırılır.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama (opsiyonel)',
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 2,
                    maxLength: 200,
                    validator: (v) => Validators.maxLength(v, 200),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Aktif'),
                    subtitle: Text(
                      _active
                          ? 'Her ay otomatik eklenir'
                          : 'Pasif — otomatik eklenmez',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    value: _active,
                    onChanged: (v) => setState(() {
                      _active = v;
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
                        : Text(_isEdit ? 'Güncelle' : 'Kaydet'),
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
