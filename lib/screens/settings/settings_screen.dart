import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/locale_controller.dart';
import '../../app/theme_controller.dart';
import '../../services/auth_service.dart';
import '../../services/expense_repository.dart';
import '../../widgets/confirm_dialog.dart';
import '../recurring/recurring_list_screen.dart';
import 'categories_screen.dart';
import 'profile_screen.dart';

/// Ayarlar ekranı.
///
/// Bölümler: Profil, Kategoriler, Tekrarlayan; Görünüm (tema), Dil
/// (TR/EN), Veri (tüm harcamaları sil), Hesap (çıkış), Hakkında.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _deleteAllExpenses() async {
    final l = context.l10n;
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final ok = await showConfirmDialog(
      context,
      title: l.deleteAllExpensesTitle,
      message: l.deleteAllExpensesMessage,
      confirmLabel: l.delete,
      cancelLabel: l.cancel,
    );
    if (!ok || !mounted) return;
    try {
      final count = await ExpenseRepository.instance.deleteAllForUser(user.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.snackExpensesDeleted(count))));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.notDeleted)));
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
    final l = context.l10n;
    showAboutDialog(
      context: context,
      applicationName: l.appName,
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.account_balance_wallet,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        const SizedBox(height: 8),
        Text(l.aboutBody),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l.profileAction),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: Text(l.categoriesAction),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CategoriesScreen()),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: Text(l.recurringAction),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RecurringListScreen()),
            ),
          ),
          const Divider(height: 1),
          _SectionHeader(l.sectionAppearance),
          AnimatedBuilder(
            animation: ThemeController.instance,
            builder: (_, _) {
              return RadioGroup<ThemeMode>(
                groupValue: ThemeController.instance.mode,
                onChanged: (v) {
                  if (v != null) ThemeController.instance.setMode(v);
                },
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.system,
                      title: Text(l.themeSystem),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.light,
                      title: Text(l.themeLight),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.dark,
                      title: Text(l.themeDark),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          _SectionHeader(l.sectionLanguage),
          AnimatedBuilder(
            animation: LocaleController.instance,
            builder: (_, _) {
              return RadioGroup<String>(
                groupValue: LocaleController.instance.locale.languageCode,
                onChanged: (v) {
                  if (v != null) {
                    LocaleController.instance.setLocale(Locale(v));
                  }
                },
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: 'tr',
                      title: Text(l.langTurkish),
                    ),
                    RadioListTile<String>(
                      value: 'en',
                      title: Text(l.langEnglish),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          _SectionHeader(l.sectionData),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
            title: Text(
              l.deleteAllExpensesAction,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: _deleteAllExpenses,
          ),
          const Divider(height: 1),
          _SectionHeader(l.sectionAccount),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l.logoutAction),
            onTap: _logout,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.aboutAction),
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
