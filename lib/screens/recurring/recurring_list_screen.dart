import 'package:flutter/material.dart';

import '../../models/recurring_expense.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/recurring_expense_repository.dart';
import '../../utils/formatters.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import 'recurring_form_screen.dart';

/// Tekrarlayan harcama şablonlarının yönetildiği ekran.
///
/// Her satır: tutar + kategori chip + "Her ayın X. günü" + aktif switch.
/// Tıklanırsa düzenleme formuna gider; sağdaki menüden silinir.
/// FAB ile yeni şablon eklenir.
///
/// Aktif/Pasif switch UI'dan direkt repository.update çağırır — kullanıcı
/// formu açmadan hızlı kontrol sağlar.
class RecurringListScreen extends StatefulWidget {
  const RecurringListScreen({super.key});

  @override
  State<RecurringListScreen> createState() => _RecurringListScreenState();
}

class _RecurringListScreenState extends State<RecurringListScreen> {
  late Future<List<RecurringExpense>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<RecurringExpense>> _load() {
    final user = AuthService.instance.currentUser;
    if (user == null) return Future.value([]);
    return RecurringExpenseRepository.instance.getAllForUser(user.id!);
  }

  void _reload() {
    setState(() => _future = _load());
  }

  Future<void> _openForm({RecurringExpense? initial}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => RecurringFormScreen(initial: initial)),
    );
    if (saved == true) _reload();
  }

  Future<void> _toggleActive(RecurringExpense r, bool value) async {
    try {
      await RecurringExpenseRepository.instance.update(
        r.copyWith(active: value),
      );
      _reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güncellenemedi')),
      );
    }
  }

  Future<void> _delete(RecurringExpense r) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final ok = await showConfirmDialog(
      context,
      title: 'Tekrarlayanı sil',
      message:
          'Bu tekrarlayan harcama şablonunu silmek istediğinize emin misiniz?\n\n'
          'Önceden eklenmiş harcamalarınız etkilenmez.',
    );
    if (!ok || !mounted) return;
    try {
      await RecurringExpenseRepository.instance.delete(
        id: r.id!,
        userId: user.id!,
      );
      _reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silinemedi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tekrarlayan Harcamalar')),
      body: FutureBuilder<List<RecurringExpense>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? const <RecurringExpense>[];
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.repeat,
              title: 'Henüz tekrarlayan harcama yok',
              subtitle:
                  'Kira, internet gibi her ay aynı tutarda olan harcamalarınızı buraya ekleyin.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
            itemCount: items.length,
            itemBuilder: (_, i) => _RecurringTile(
              recurring: items[i],
              onTap: () => _openForm(initial: items[i]),
              onToggle: (v) => _toggleActive(items[i], v),
              onDelete: () => _delete(items[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RecurringTile extends StatelessWidget {
  final RecurringExpense recurring;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _RecurringTile({
    required this.recurring,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cat = CategoryService.instance.byName(recurring.category);
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: cat.color.withValues(alpha: 0.15),
          foregroundColor: cat.color,
          child: Icon(cat.icon),
        ),
        title: Text(
          Formatters.money(recurring.amount),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                CategoryChip(category: cat, dense: true),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Her ayın ${recurring.dayOfMonth}. günü',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            if (recurring.note != null && recurring.note!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                recurring.note!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(value: recurring.active, onChanged: onToggle),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
