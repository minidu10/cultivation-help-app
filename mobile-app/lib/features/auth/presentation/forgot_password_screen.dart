import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/format/formatters.dart';
import '../data/auth_repository.dart';
import 'auth_widgets.dart';
import 'validators.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(authRepositoryProvider);
    try {
      if (!_codeSent) {
        // Same answer whether or not the account exists: the server will not
        // reveal which emails are registered, so neither does the app.
        await repo.forgotPassword(_email.text);
        setState(() => _codeSent = true);
      } else {
        await repo.resetPassword(email: _email.text, code: _code.text, newPassword: _password.text);
        if (mounted) context.go('/login', extra: context.l10n.passwordResetDone);
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthScaffold(
      title: l10n.forgotTitle,
      subtitle: _codeSent ? l10n.codeSentTo(_email.text.trim()) : l10n.forgotEmailHint,
      showBack: true,
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormError(_error),
            TextFormField(
              controller: _email,
              enabled: !_codeSent,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l10n.emailLabel, prefixIcon: const Icon(Icons.mail_outline)),
              validator: (v) => validateEmail(l10n, v),
            ),
            if (_codeSent) ...[
              const SizedBox(height: 14),
              TextFormField(
                controller: _code,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                decoration: InputDecoration(labelText: l10n.codeLabel, prefixIcon: const Icon(Icons.pin_outlined)),
                validator: (v) => (v?.length ?? 0) == 6 ? null : l10n.codeInvalid,
              ),
              const SizedBox(height: 14),
              PasswordField(
                controller: _password,
                label: l10n.newPasswordLabel,
                autofillHints: const [AutofillHints.newPassword],
                onChanged: (_) => setState(() {}),
                validator: (v) => PasswordRules(v ?? '').allMet ? null : l10n.passwordTooWeak,
              ),
              PasswordChecklist(_password.text),
            ],
            const SizedBox(height: 20),
            BusyButton(label: _codeSent ? l10n.resetPassword : l10n.sendResetCode, busy: _busy, onPressed: _submit),
            const SizedBox(height: 8),
            TextButton(onPressed: () => context.go('/login'), child: Text(l10n.backToSignIn)),
          ],
        ),
      ),
    );
  }
}
