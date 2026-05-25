import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_constants.dart';
import '../../models/budget.dart';
import '../../services/auth_service.dart';
import '../../services/budget_repository.dart';
import '../../utils/money_utils.dart';
import '../../utils/validators.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/unsaved_changes_dialog.dart';

class BudgetFormScreen extends StatefulWidget {
  final Budget? initial;
  final List<String> existingCategories;

  const BudgetFormScreen({
    super.key,
    this.initial,
    this.existingCategories = const [],
  });

  @override
  State<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends State<BudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _limitCtrl;
  late AppCategory _category;
  late final String _initialSignature;
  bool _busy = false;
  bool _dirty = false;

  bool get _isEdit => widget.initial != null;

  late List<AppCategory> _selectableCategories;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _limitCtrl = TextEditingController(
      text: initial == null
          ? ''
          : initial.monthlyLimit.toStringAsFixed(2).replaceAll('.', ','),
    );

    if (_isEdit) {
      _category = AppCategories.byName(initial!.category);
      _selectableCategories = [_category];
    } else {
      _selectableCategories = AppCategories.all
          .where((c) => !widget.existingCategories.contains(c.name))
          .toList();
      _category = _selectableCategories.isNotEmpty
          ? _selectableCategories.first
          : AppCategories.diger;
    }

    _initialSignature = _signature();
    _limitCtrl.addListener(_markDirty);
  }

  @override
  void dispose() {
    _limitCtrl.dispose();
    super.dispose();
  }

  String _signature() => '${_limitCtrl.text}|${_category.name}';

  void _markDirty() {
    final next = _signature() != _initialSignature;
    if (next != _dirty) setState(() => _dirty = next);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final limit = parseMoneyInput(_limitCtrl.text);
    if (limit == null) return;

    setState(() => _busy = true);
    try {
      await BudgetRepository.instance.upsert(
        userId: user.id!,
        category: _category.name,
        monthlyLimit: limit,
      );
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
    if (_selectableCategories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Yeni Bütçe')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Tüm kategoriler için bütçe oluşturulmuş. Mevcut bütçelerden birini düzenleyebilirsiniz.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

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
          title: Text(_isEdit ? 'Bütçeyi Düzenle' : 'Yeni Bütçe'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isEdit)
                    Row(
                      children: [
                        const Text('Kategori: '),
                        const SizedBox(width: 8),
                        CategoryChip(category: _category),
                      ],
                    )
                  else
                    DropdownButtonFormField<AppCategory>(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: [
                        for (final c in _selectableCategories)
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
                  TextFormField(
                    controller: _limitCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Aylık limit',
                      prefixIcon: Icon(Icons.payments_outlined),
                      suffixText: AppStrings.currencySymbol,
                    ),
                    validator: Validators.moneyAmount,
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
