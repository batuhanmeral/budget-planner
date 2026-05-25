import 'package:flutter/material.dart';

import '../../app/app_constants.dart';
import '../../app/app_routes.dart';
import '../../app/theme_controller.dart';
import '../../services/auth_service.dart';
import '../../services/expense_repository.dart';
import '../../widgets/confirm_dialog.dart';
import 'categories_screen.dart';
import 'profile_screen.dart';

/// Ayarlar ekranı.
///
/// Bölümler:
/// - Profil linki (kullanıcı bilgileri + hesap işlemleri)
/// - Görünüm: tema seçimi ([RadioGroup] ile Sistem/Aydınlık/Karanlık)
/// - Veri: "Tüm harcamalarımı sil" (onaylı, yalnızca aktif kullanıcı)
/// - Hesap: Çıkış Yap
/// - Hakkında: standart [showAboutDialog]
///
/// "Tüm harcamalarımı sil" bütçeleri korur; hesabı silmek tüm verileri
/// götürür (Profil ekranında).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _deleteAllExpenses() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final ok = await showConfirmDialog(
      context,
      title: 'Tüm harcamaları sil',
      message:
          'Tüm harcamalarınız kalıcı olarak silinecek. Bütçeleriniz korunur. Devam edilsin mi?',
      confirmLabel: 'Hepsini sil',
    );
    if (!ok || !mounted) return;
    try {
      final count = await ExpenseRepository.instance.deleteAllForUser(user.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$count harcama silindi')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silinemedi. Lütfen tekrar deneyin.')),
      );
    }
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.account_balance_wallet,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: const [
        SizedBox(height: 8),
        Text(
          'Günlük harcamalarınızı ve bütçe hedeflerinizi takip etmenize yardımcı olan basit bir uygulama.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Kategoriler'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CategoriesScreen()),
            ),
          ),
          const Divider(height: 1),
          const _SectionHeader('Görünüm'),
          AnimatedBuilder(
            animation: ThemeController.instance,
            builder: (_, _) {
              return RadioGroup<ThemeMode>(
                groupValue: ThemeController.instance.mode,
                onChanged: (v) {
                  if (v != null) ThemeController.instance.setMode(v);
                },
                child: const Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.system,
                      title: Text('Sistem'),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.light,
                      title: Text('Aydınlık'),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.dark,
                      title: Text('Karanlık'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          const _SectionHeader('Veri'),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
            title: const Text(
              'Tüm harcamalarımı sil',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _deleteAllExpenses,
          ),
          const Divider(height: 1),
          const _SectionHeader('Hesap'),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Çıkış Yap'),
            onTap: _logout,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Hakkında'),
            onTap: _showAbout,
          ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
