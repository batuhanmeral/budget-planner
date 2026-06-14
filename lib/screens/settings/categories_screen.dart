import 'package:flutter/material.dart';

import '../../app/app_constants.dart';
import '../../app/locale_controller.dart';
import '../../models/custom_category.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/category_form_dialog.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  Future<void> _addCategory(BuildContext context) async {
    final l = context.l10n;
    final kind = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.south_west),
              title: Text(l.expenseWord),
              onTap: () => Navigator.of(ctx).pop(CategoryService.kindExpense),
            ),
            ListTile(
              leading: const Icon(Icons.north_east),
              title: Text(l.incomeWord),
              onTap: () => Navigator.of(ctx).pop(CategoryService.kindIncome),
            ),
          ],
        ),
      ),
    );
    if (kind == null || !context.mounted) return;
    await showCategoryFormDialog(context, kind: kind);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final user = AuthService.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: Text(l.categoriesTitle)),
      body: AnimatedBuilder(
        animation: CategoryService.instance,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            children: [
              _SectionHeader(l.sectionFixedCategories),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in AppCategories.all) CategoryChip(category: c),
                ],
              ),
              const SizedBox(height: 24),
              _SectionHeader(l.sectionCustomCategories),
              const SizedBox(height: 8),
              _CustomList(
                items: CategoryService.instance.customCategories,
                userId: user.id!,
                emptyTitle: l.emptyCustomCategoriesTitle,
                emptySubtitle: l.emptyCustomCategoriesSubtitle,
              ),
              const SizedBox(height: 32),
              _SectionHeader(l.sectionFixedIncomeSources),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in IncomeSources.all) CategoryChip(category: c),
                ],
              ),
              const SizedBox(height: 24),
              _SectionHeader(l.sectionCustomIncomeSources),
              const SizedBox(height: 8),
              _CustomList(
                items: CategoryService.instance.customIncomeCategories,
                userId: user.id!,
                emptyTitle: l.emptyCustomIncomeSourcesTitle,
                emptySubtitle: l.emptyCustomIncomeSourcesSubtitle,
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addCategory(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CustomList extends StatelessWidget {
  final List<CustomCategory> items;
  final int userId;
  final String emptyTitle;
  final String emptySubtitle;

  const _CustomList({
    required this.items,
    required this.userId,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: EmptyState(
          icon: Icons.label_outline,
          title: emptyTitle,
          subtitle: emptySubtitle,
        ),
      );
    }
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(
                  items[i].colorInt,
                ).withValues(alpha: 0.15),
                foregroundColor: Color(items[i].colorInt),
                child: Icon(
                  IconData(items[i].iconCode, fontFamily: 'MaterialIcons'),
                ),
              ),
              title: Text(items[i].name),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () async {
                  final ok = await showConfirmDialog(
                    context,
                    title: l.deleteCategoryTitle,
                    message: l.deleteCategoryMessage(items[i].name),
                  );
                  if (!ok || !context.mounted) return;
                  await CategoryService.instance.deleteCustom(
                    id: items[i].id!,
                    userId: userId,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 1,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
