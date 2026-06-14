import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../app/app_routes.dart';
import '../../app/locale_controller.dart';
import '../../services/auth_service.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../auth/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _editName() async {
    final l = context.l10n;
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final ctrl = TextEditingController(text: user.fullName ?? '');
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.editNameTitle),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 40,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l.fullNameLabel,
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            child: Text(l.save),
          ),
        ],
      ),
    );
    if (newName == null || !mounted) return;
    try {
      await AuthService.instance.updateFullName(newName);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.snackProfileUpdated)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.notSaved)));
    }
  }

  Future<void> _changeUsername() async {
    final l = context.l10n;
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final ctrl = TextEditingController(text: user.username);
    final formKey = GlobalKey<FormState>();
    final newUsername = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.changeUsernameTitle),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            maxLength: 20,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: l.newUsernameLabel,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: Validators.username,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(ctrl.text.trim());
              }
            },
            child: Text(l.save),
          ),
        ],
      ),
    );
    if (newUsername == null || !mounted) return;
    try {
      await AuthService.instance.changeUsername(newUsername);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.snackUsernameUpdated)));
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.notSaved)));
    }
  }

  Future<void> _changePhoto() async {
    final l = context.l10n;
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    final hasPhoto = user.avatarPath != null && user.avatarPath!.isNotEmpty;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l.photoFromCamera),
              onTap: () => Navigator.of(ctx).pop('camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l.photoFromGallery),
              onTap: () => Navigator.of(ctx).pop('gallery'),
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  l.removePhoto,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () => Navigator.of(ctx).pop('remove'),
              ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;
    if (action == 'remove') {
      await _applyAvatar(null);
      return;
    }
    final source = action == 'camera'
        ? ImageSource.camera
        : ImageSource.gallery;
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 720,
        maxHeight: 720,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final dir = await getApplicationDocumentsDirectory();
      final ext = p.extension(picked.path);
      final dest = p.join(
        dir.path,
        'avatar_${user.id}_${DateTime.now().millisecondsSinceEpoch}$ext',
      );
      await File(picked.path).copy(dest);
      await _applyAvatar(dest);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.notSaved)));
    }
  }

  Future<void> _applyAvatar(String? path) async {
    final l = context.l10n;
    final old = AuthService.instance.currentUser?.avatarPath;
    try {
      await AuthService.instance.updateAvatar(path);
      if (old != null && old.isNotEmpty && old != path) {
        final f = File(old);
        if (await f.exists()) await f.delete();
      }
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.snackProfileUpdated)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.notSaved)));
    }
  }

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleController.instance.l10n.snackAccountDeleted),
        ),
      );
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
        SnackBar(
          content: Text(LocaleController.instance.l10n.deleteAccountErrorSnack),
        ),
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
              Text(LocaleController.instance.l10n.deleteAccountDialogMessage),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                obscureText: obscure,
                autofocus: true,
                decoration: InputDecoration(
                  labelText:
                      LocaleController.instance.l10n.passwordConfirmLabel,
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
            child: GestureDetector(
              onTap: _changePhoto,
              child: Stack(
                children: [
                  _Avatar(avatarPath: user.avatarPath),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.photo_camera,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              (user.fullName != null && user.fullName!.trim().isNotEmpty)
                  ? user.fullName!
                  : user.username,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Center(
            child: Text(
              '@${user.username}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          if (user.createdAt != null)
            Center(
              child: Text(
                l.memberSinceLabel(
                  Formatters.dateLong(user.createdAt!.toLocal()),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: Text(l.editNameAction),
            subtitle: Text(
              (user.fullName != null && user.fullName!.trim().isNotEmpty)
                  ? user.fullName!
                  : l.fullNameNotSet,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _editName,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l.changeUsernameAction),
            subtitle: Text('@${user.username}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changeUsername,
          ),
          const Divider(height: 1),
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

class _Avatar extends StatelessWidget {
  final String? avatarPath;
  const _Avatar({required this.avatarPath});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final hasPhoto = avatarPath != null &&
        avatarPath!.isNotEmpty &&
        File(avatarPath!).existsSync();
    return CircleAvatar(
      radius: 40,
      backgroundColor: primary.withValues(alpha: 0.15),
      foregroundColor: primary,
      backgroundImage: hasPhoto ? FileImage(File(avatarPath!)) : null,
      child: hasPhoto ? null : const Icon(Icons.person, size: 40),
    );
  }
}
