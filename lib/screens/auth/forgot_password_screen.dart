import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/locale_controller.dart';
import '../../l10n/app_l10n.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';

/// "Parolamı Unuttum" akışı — üç adımlı wizard.
///
/// 1. Kullanıcı adı → DB'den güvenlik sorusunu çek
/// 2. Sorunun cevabını gir → minimum validasyon
/// 3. Yeni parolayı belirle → sıfırla, login'e dön
///
/// Yanlış cevap girilirse 2. adımdan generic hata ile devam edilir
/// (kullanıcı adı veya cevap doğru mu sızıntı yapılmaz).
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

enum _Step { username, answer, newPassword }

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  _Step _step = _Step.username;
  bool _busy = false;

  final _usernameCtrl = TextEditingController();
  final _answerCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _newPassword2Ctrl = TextEditingController();
  String? _question;
  bool _obscure = true;
  bool _obscure2 = true;

  /// Tüm metotlardan erişim için kısayol — `build` dışındaki helper'lar
  /// `context.l10n`'a doğrudan erişebilsin.
  AppL10n get _l => LocaleController.instance.l10n;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _answerCtrl.dispose();
    _newPasswordCtrl.dispose();
    _newPassword2Ctrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _loadQuestion() async {
    final username = _usernameCtrl.text.trim();
    if (Validators.requiredField(username) != null) {
      _snack(_l.vRequired);
      return;
    }
    setState(() => _busy = true);
    try {
      final q = await AuthService.instance.getSecurityQuestion(username);
      if (!mounted) return;
      setState(() {
        _question = q;
        _step = _Step.answer;
      });
    } on AuthException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack(_l.unexpectedError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _proceedToPassword() {
    if (Validators.securityAnswer(_answerCtrl.text) != null) {
      _snack(_l.vAnswerMin);
      return;
    }
    setState(() => _step = _Step.newPassword);
  }

  Future<void> _resetPassword() async {
    if (Validators.password(_newPasswordCtrl.text) != null) {
      _snack(_l.vPasswordMin);
      return;
    }
    if (_newPasswordCtrl.text != _newPassword2Ctrl.text) {
      _snack(_l.vPasswordsNotMatching);
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthService.instance.resetPasswordViaSecurityAnswer(
        username: _usernameCtrl.text.trim(),
        answer: _answerCtrl.text,
        newPassword: _newPasswordCtrl.text,
      );
      if (!mounted) return;
      _snack(_l.pleaseLogin);
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    } on AuthException catch (e) {
      _snack(e.message);
      setState(() => _step = _Step.answer);
    } catch (_) {
      _snack(_l.unexpectedError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_l.forgotPasswordTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: switch (_step) {
            _Step.username => _buildUsernameStep(),
            _Step.answer => _buildAnswerStep(),
            _Step.newPassword => _buildPasswordStep(),
          },
        ),
      ),
    );
  }

  Widget _buildUsernameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_l.forgotPasswordIntro),
        const SizedBox(height: 16),
        TextFormField(
          controller: _usernameCtrl,
          decoration: InputDecoration(
              labelText: _l.usernameLabel,
            prefixIcon: Icon(Icons.person_outline),
          ),
          autocorrect: false,
          enableSuggestions: false,
          onFieldSubmitted: (_) => _loadQuestion(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _busy ? null : _loadQuestion,
          child: _busy ? const _Spinner() : Text(_l.next),
        ),
      ],
    );
  }

  Widget _buildAnswerStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_question ?? '', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        TextFormField(
          controller: _answerCtrl,
          decoration: InputDecoration(
              labelText: _l.securityAnswerLabel,
            prefixIcon: Icon(Icons.edit_outlined),
          ),
          autocorrect: false,
          enableSuggestions: false,
          onFieldSubmitted: (_) => _proceedToPassword(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _busy ? null : _proceedToPassword,
          child: Text(_l.next),
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_l.setNewPasswordPrompt),
        const SizedBox(height: 16),
        TextFormField(
          controller: _newPasswordCtrl,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: _l.newPasswordLabel,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _newPassword2Ctrl,
          obscureText: _obscure2,
          decoration: InputDecoration(
            labelText: _l.newPasswordRepeatLabel,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscure2 ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscure2 = !_obscure2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _busy ? null : _resetPassword,
          child: _busy ? const _Spinner() : Text(_l.resetPasswordButton),
        ),
      ],
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
  );
}
