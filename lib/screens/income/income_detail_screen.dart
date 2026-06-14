import 'package:flutter/material.dart';

import '../../app/locale_controller.dart';
import '../../l10n/app_l10n.dart';
import '../../models/income.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/income_repository.dart';
import '../../utils/formatters.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/confirm_dialog.dart';
import 'income_form_screen.dart';

class IncomeDetailScreen extends StatefulWidget {
  final int incomeId;

  const IncomeDetailScreen({super.key, required this.incomeId});

  @override
  State<IncomeDetailScreen> createState() => _IncomeDetailScreenState();
}

class _IncomeDetailScreenState extends State<IncomeDetailScreen> {
  static const _positive = Color(0xFF16A34A);

  AppL10n get _l => LocaleController.instance.l10n;

  late Future<Income?> _future;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Income?> _load() {
    final user = AuthService.instance.currentUser;
    if (user == null) return Future.value(null);
    return IncomeRepository.instance.getById(
      id: widget.incomeId,
      userId: user.id!,
    );
  }

  Future<void> _edit(Income income) async {
    final navigator = Navigator.of(context);
    final result = await navigator.push<bool>(
      MaterialPageRoute(builder: (_) => IncomeFormScreen(initial: income)),
    );
    if (result == true) {
      setState(() {
        _future = _load();
        _changed = true;
      });
    }
  }

  Future<void> _delete(Income income) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final ok = await showConfirmDialog(
      context,
      title: _l.deleteIncomeTitle,
      message: _l.deleteIncomeMessage,
    );
    if (!ok || !mounted) return;
    try {
      await IncomeRepository.instance.delete(id: income.id!, userId: user.id!);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_l.notDeleted)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l.incomeDetailTitle)),
        body: FutureBuilder<Income?>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final e = snapshot.data;
            if (e == null) {
              return Center(child: Text(l.incomeNotFound));
            }
            final src = CategoryService.instance.incomeByName(e.source);
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
                            backgroundColor: src.color.withValues(alpha: 0.15),
                            foregroundColor: src.color,
                            child: Icon(src.icon, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '+${Formatters.money(e.amount)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: _positive,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                CategoryChip(category: src, dense: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: l.dateLabel,
                        value: Formatters.dateLong(e.date),
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        icon: Icons.notes,
                        label: l.noteLabel,
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
                              label: Text(l.editTooltip),
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
                              label: Text(
                                l.deleteTooltip,
                                style: const TextStyle(color: Colors.red),
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
