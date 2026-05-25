import 'package:flutter/material.dart';

import '../../models/expense.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/expense_repository.dart';
import '../../utils/formatters.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/confirm_dialog.dart';
import 'expense_form_screen.dart';

/// Tek bir harcamayı tüm detaylarıyla gösteren ekran.
///
/// Üstte büyük tutar + kategori avatar, sonra tarih ve not satırları,
/// altta Düzenle / Sil butonları.
///
/// `pop(true)` ile parent listeye "yeniden yükle" sinyali döner.
/// `_changed` bayrağı düzenleme sonrasında işaretlenir; sistem geri
/// tuşunda bile parent reload edilebilsin diye [PopScope] override eder.
class ExpenseDetailScreen extends StatefulWidget {
  final int expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  late Future<Expense?> _future;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Expense?> _load() {
    final user = AuthService.instance.currentUser;
    if (user == null) return Future.value(null);
    return ExpenseRepository.instance.getById(
      id: widget.expenseId,
      userId: user.id!,
    );
  }

  Future<void> _edit(Expense expense) async {
    final navigator = Navigator.of(context);
    final result = await navigator.push<bool>(
      MaterialPageRoute(builder: (_) => ExpenseFormScreen(initial: expense)),
    );
    if (result == true) {
      setState(() {
        _future = _load();
        _changed = true;
      });
    }
  }

  Future<void> _delete(Expense expense) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final ok = await showConfirmDialog(
      context,
      title: 'Harcamayı sil',
      message: 'Bu harcamayı silmek istediğinize emin misiniz?',
    );
    if (!ok || !mounted) return;
    try {
      await ExpenseRepository.instance.delete(
        id: expense.id!,
        userId: user.id!,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silinemedi. Lütfen tekrar deneyin.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Harcama Detayı')),
        body: FutureBuilder<Expense?>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final e = snapshot.data;
            if (e == null) {
              return const Center(
                child: Text('Bu harcama bulunamadı veya silinmiş.'),
              );
            }
            final cat = CategoryService.instance.byName(e.category);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: cat.color.withValues(alpha: 0.15),
                            foregroundColor: cat.color,
                            child: Icon(cat.icon, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Formatters.money(e.amount),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                CategoryChip(category: cat, dense: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Tarih',
                        value: Formatters.dateLong(e.date),
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        icon: Icons.notes,
                        label: 'Açıklama',
                        value: (e.note == null || e.note!.trim().isEmpty)
                            ? '—'
                            : e.note!,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Düzenle'),
                              onPressed: () => _edit(e),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              label: const Text(
                                'Sil',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () => _delete(e),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
