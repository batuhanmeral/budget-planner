import 'package:flutter/material.dart';

import '../app/locale_controller.dart';
import '../services/auth_service.dart';
import '../services/category_service.dart';
import '../utils/validators.dart';

Future<bool> showCategoryFormDialog(
  BuildContext context, {
  String kind = CategoryService.kindExpense,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => _CategoryFormDialog(kind: kind),
  );
  return result ?? false;
}

class _CategoryFormDialog extends StatefulWidget {
  final String kind;
  const _CategoryFormDialog({required this.kind});

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  IconData _icon = CategoryIcons.list.first;
  Color _color = CategoryColors.list.first;
  bool _busy = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    setState(() => _busy = true);
    try {
      final exists = await CategoryService.instance.nameExists(
        userId: user.id!,
        name: _nameCtrl.text,
        kind: widget.kind,
      );
      if (exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.errCategoryExists)));
        return;
      }
      await CategoryService.instance.addCustom(
        userId: user.id!,
        name: _nameCtrl.text,
        icon: _icon,
        color: _color,
        kind: widget.kind,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.errCategoryNotAdded)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.newCategoryTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_icon, color: _color, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _nameCtrl.text.trim().isEmpty
                              ? context.l10n.preview
                              : _nameCtrl.text.trim(),
                          style: TextStyle(
                            color: _color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: context.l10n.categoryNameLabel,
                    prefixIcon: const Icon(Icons.label_outline),
                  ),
                  maxLength: 20,
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    final r = Validators.requiredField(v);
                    if (r != null) return r;
                    return Validators.maxLength(v, 20);
                  },
                ),
                const SizedBox(height: 8),
                _SectionLabel(context.l10n.iconLabel),
                const SizedBox(height: 8),
                _IconGrid(
                  value: _icon,
                  color: _color,
                  onChanged: (v) => setState(() => _icon = v),
                ),
                const SizedBox(height: 16),
                _SectionLabel(context.l10n.colorLabel),
                const SizedBox(height: 8),
                _ColorGrid(
                  value: _color,
                  onChanged: (v) => setState(() => _color = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.l10n.add),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}

class _IconGrid extends StatelessWidget {
  final IconData value;
  final Color color;
  final ValueChanged<IconData> onChanged;

  const _IconGrid({
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: CategoryIcons.list.length,
        itemBuilder: (_, i) {
          final icon = CategoryIcons.list[i];
          final selected = icon.codePoint == value.codePoint;
          return InkWell(
            onTap: () => onChanged(icon),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: selected ? color.withValues(alpha: 0.18) : null,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? color : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Icon(icon, color: selected ? color : null),
            ),
          );
        },
      ),
    );
  }
}

class _ColorGrid extends StatelessWidget {
  final Color value;
  final ValueChanged<Color> onChanged;

  const _ColorGrid({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in CategoryColors.list)
          GestureDetector(
            onTap: () => onChanged(c),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: c.toARGB32() == value.toARGB32()
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
