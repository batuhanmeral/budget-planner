import 'package:flutter/material.dart';

import '../../app/locale_controller.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../widgets/unsaved_changes_dialog.dart';

/// Profil → "Parolayı değiştir" akışı.
///
/// Mevcut parola onayı + yeni parola + tekrar. [AuthService.changePassword]
/// yeni bir salt + hash üretir. Her parola alanında göster/gizle toggle.
/// [PopScope] kaybolmuş değişiklik koruması.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _new2Ctrl = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureNew2 = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_oldCtrl, _newCtrl, _new2Ctrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _new2Ctrl.dispose();
    super.dispose();
  }

  bool get _isDirty =>
      _oldCtrl.text.isNotEmpty ||
      _newCtrl.text.isNotEmpty ||
      _new2Ctrl.text.isNotEmpty;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await AuthService.instance.changePassword(
        oldPassword: _oldCtrl.text,
        newPassword: _newCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(LocaleController.instance.l10n.passwordUpdatedSnack),
        ),
      );
      Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack(LocaleController.instance.l10n.unexpectedError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final ok = await confirmDiscardChanges(context);
        if (ok && mounted) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l.changePasswordTitle)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _oldCtrl,
                    obscureText: _obscureOld,
                    decoration: InputDecoration(
                      labelText: l.currentPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureOld ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => _obscureOld = !_obscureOld),
                      ),
                    ),
                    validator: Validators.requiredField,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _newCtrl,
                    obscureText: _obscureNew,
                    decoration: InputDecoration(
                      labelText: l.newPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _new2Ctrl,
                    obscureText: _obscureNew2,
                    decoration: InputDecoration(
                      labelText: l.newPasswordRepeatLabel,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew2
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => _obscureNew2 = !_obscureNew2),
                      ),
                    ),
                    validator: (v) =>
                        Validators.passwordMatch(v, _newCtrl.text),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l.update),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
