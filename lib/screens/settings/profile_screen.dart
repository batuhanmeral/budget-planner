import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/locale_controller.dart';
import '../../services/auth_service.dart';
import '../../utils/formatters.dart';
import '../auth/change_password_screen.dart';

/// Kullanıcı profil ekranı.
///
/// Üstte avatar + username + üyelik tarihi. Altta iki action:
/// - Parolayı değiştir → [ChangePasswordScreen]
/// - Hesabı sil → parola onaylı diyalog → [AuthService.deleteAccount]
///
/// Hesap silme cascade ile tüm verileri (harcamalar + bütçeler) düşürür
/// ve kullanıcıyı login ekranına yönlendirir.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _changePassword() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
    );
  }

  Future<void> _deleteAccount() async {
    final password = await _askPassword();
    if (password == null || !mounted) return;
    try {
      await AuthService.instance.deleteAccount(password);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(LocaleController.instance.l10n.snackAccountDeleted)));
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleController.instance.l10n.deleteAccountErrorSnack)),
      );
    }
  }

  Future<String?> _askPassword() async {
    final ctrl = TextEditingController();
    bool obscure = true;
    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(LocaleController.instance.l10n.deleteAccountAction),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(LocaleController.instance.l10n.deleteAccountDialogMessage,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                obscureText: obscure,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: LocaleController.instance.l10n.passwordConfirmLabel,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setLocal(() => obscure = !obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(LocaleController.instance.l10n.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(ctx).pop(ctrl.text),
              child: Text(LocaleController.instance.l10n.deleteAccountAction),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final user = AuthService.instance.currentUser;
    if (user == null) return const SizedBox.shrink();
    return Scaffold(
      appBar: AppBar(title: Text(l.profileTitle)),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.15),
              foregroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person, size: 36),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              user.username,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (user.createdAt != null)
            Center(
              child: Text(
                l.memberSinceLabel(Formatters.dateLong(user.createdAt!.toLocal())),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l.changePasswordAction),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changePassword,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: Text(
              l.deleteAccountAction,
              style: const TextStyle(color: Colors.red),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.red),
            onTap: _deleteAccount,
          ),
        ],
      ),
    );
  }
}
