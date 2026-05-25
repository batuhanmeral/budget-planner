import 'package:flutter/material.dart';

import '../../app/app_constants.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/category_form_dialog.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';

/// Özel kategorilerin yönetildiği ekran.
///
/// Üstte sabit kategoriler (sadece görüntü), altta kullanıcının özel
/// kategorileri (sil butonlu). FAB ile yeni kategori eklenir.
///
/// [CategoryService] bir [ChangeNotifier] olduğu için [AnimatedBuilder]
/// ile dinlenir; ekleme/silme sonrası liste otomatik yenilenir.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Kategoriler')),
      body: AnimatedBuilder(
        animation: CategoryService.instance,
        builder: (context, _) {
          final customs = CategoryService.instance.customCategories;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            children: [
              const _SectionHeader('Sabit kategoriler'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in AppCategories.all)
                    CategoryChip(category: c),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionHeader('Özel kategoriler'),
              const SizedBox(height: 8),
              if (customs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: EmptyState(
                    icon: Icons.label_outline,
                    title: 'Henüz özel kategori yok',
                    subtitle:
                        'Sağ alttaki + ile kendi kategorinizi oluşturabilirsiniz.',
                  ),
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < customs.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(
                              customs[i].colorInt,
                            ).withValues(alpha: 0.15),
                            foregroundColor: Color(customs[i].colorInt),
                            child: Icon(
                              IconData(
                                customs[i].iconCode,
                                fontFamily: 'MaterialIcons',
                              ),
                            ),
                          ),
                          title: Text(customs[i].name),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              final ok = await showConfirmDialog(
                                context,
                                title: 'Kategoriyi sil',
                                message:
                                    '${customs[i].name} kategorisini silmek istediğinize emin misiniz?\n\n'
                                    'Mevcut harcamalarınız "Diğer" olarak görünmeye devam eder.',
                              );
                              if (!ok || !context.mounted) return;
                              await CategoryService.instance.deleteCustom(
                                id: customs[i].id!,
                                userId: user.id!,
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCategoryFormDialog(context),
        child: const Icon(Icons.add),
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
