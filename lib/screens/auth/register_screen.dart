import 'package:flutter/material.dart';

import '../../app/app_constants.dart';
import '../../app/app_routes.dart';
import '../../app/locale_controller.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../widgets/unsaved_changes_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _password2Ctrl = TextEditingController();
  final _answerCtrl = TextEditingController();

  String _question = SecurityQuestions.list.first;
  bool _obscure = true;
  bool _obscure2 = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _fullNameCtrl,
      _usernameCtrl,
      _passwordCtrl,
      _password2Ctrl,
      _answerCtrl,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _password2Ctrl.dispose();
    _answerCtrl.dispose();
    super.dispose();
  }

  bool get _isDirty =>
      _fullNameCtrl.text.isNotEmpty ||
      _usernameCtrl.text.isNotEmpty ||
      _passwordCtrl.text.isNotEmpty ||
      _password2Ctrl.text.isNotEmpty ||
      _answerCtrl.text.isNotEmpty;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await AuthService.instance.register(
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text,
        securityQuestion: _question,
        securityAnswer: _answerCtrl.text,
        fullName: _fullNameCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError(LocaleController.instance.l10n.unexpectedError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
        appBar: AppBar(title: Text(l.registerTitle)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _fullNameCtrl,
                    decoration: InputDecoration(
                      labelText: l.fullNameLabel,
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: Validators.fullName,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: InputDecoration(
                      labelText: l.usernameLabel,
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.next,
                    validator: Validators.username,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: l.passwordLabel,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password2Ctrl,
                    obscureText: _obscure2,
                    decoration: InputDecoration(
                      labelText: l.passwordRepeatLabel,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure2 ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure2 = !_obscure2),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        Validators.passwordMatch(v, _passwordCtrl.text),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l.securityQuestionLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _question,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.help_outline),
                    ),
                    items: [
                      for (final q in SecurityQuestions.list)
                        DropdownMenuItem(value: q, child: Text(q)),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _question = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _answerCtrl,
                    decoration: InputDecoration(
                      labelText: l.securityAnswerLabel,
                      prefixIcon: Icon(Icons.edit_outlined),
                    ),
                    textInputAction: TextInputAction.done,
                    validator: Validators.securityAnswer,
                  ),
                  const SizedBox(height: 24),
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
                        : Text(l.registerButton),
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
