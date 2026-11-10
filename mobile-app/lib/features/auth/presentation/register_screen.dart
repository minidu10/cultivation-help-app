import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/format/formatters.dart';
import '../../../core/session/session_controller.dart';
import '../data/auth_repository.dart';
import 'auth_widgets.dart';
import 'validators.dart';

enum _Step { email, code, details }

/// Sign-up in three steps, matching the web app: confirm the email with a
/// code first, then create the account. Each step only appears once the one
/// before it has succeeded on the server.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  static const _resendSeconds = 60;

  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _password = TextEditingController();

  _Step _step = _Step.email;
  bool _busy = false;
  String? _error;
  int _resendIn = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in [_email, _code, _name, _phone, _city, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _resendIn = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _resendIn <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendIn = 0);
        return;
      }
      setState(() => _resendIn--);
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendCode() => _run(() async {
        await ref.read(authRepositoryProvider).sendCode(_email.text);
        setState(() => _step = _Step.code);
        _startCountdown();
      });

  Future<void> _resend() async {
    setState(() => _error = null);
    try {
      await ref.read(authRepositoryProvider).sendCode(_email.text);
      _startCountdown();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _verify() => _run(() async {
        await ref.read(authRepositoryProvider).verifyCode(_email.text, _code.text);
        setState(() => _step = _Step.details);
      });

  Future<void> _register() => _run(() async {
        final session = await ref.read(authRepositoryProvider).register(
              fullName: _name.text,
              email: _email.text,
              password: _password.text,
              phone: _phone.text.isEmpty ? null : _phone.text,
              city: _city.text.isEmpty ? null : _city.text,
            );
        await ref.read(sessionControllerProvider.notifier).signIn(session);
      });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthScaffold(
      title: l10n.registerTitle,
      showBack: true,
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepIndicator(current: _step),
            const SizedBox(height: 20),
            FormError(_error),
            ...switch (_step) {
              _Step.email => _emailStep(context),
              _Step.code => _codeStep(context),
              _Step.details => _detailsStep(context),
            },
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(l10n.haveAccount),
                TextButton(onPressed: () => context.go('/login'), child: Text(l10n.signIn)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _emailStep(BuildContext context) {
    final l10n = context.l10n;
    return [
      Text(l10n.registerEmailHint),
      const SizedBox(height: 16),
      TextFormField(
        key: const Key('register-email'),
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        decoration: InputDecoration(labelText: l10n.emailLabel, prefixIcon: const Icon(Icons.mail_outline)),
        validator: (v) => validateEmail(l10n, v),
        onFieldSubmitted: (_) => _sendCode(),
      ),
      const SizedBox(height: 20),
      BusyButton(label: l10n.sendCode, busy: _busy, onPressed: _sendCode),
      const GoogleSignInButton(),
    ];
  }

  List<Widget> _codeStep(BuildContext context) {
    final l10n = context.l10n;
    return [
      Text(l10n.codeSentTo(_email.text.trim())),
      const SizedBox(height: 16),
      TextFormField(
        key: const Key('register-code'),
        controller: _code,
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
        style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.w700),
        textAlign: TextAlign.center,
        decoration: InputDecoration(labelText: l10n.codeLabel),
        validator: (v) => (v?.length ?? 0) == 6 ? null : l10n.codeInvalid,
        onFieldSubmitted: (_) => _verify(),
      ),
      const SizedBox(height: 20),
      BusyButton(label: l10n.verify, busy: _busy, onPressed: _verify),
      const SizedBox(height: 8),
      // Wraps rather than overflowing on narrow phones, large text, or the
      // longer Sinhala and Tamil labels.
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => setState(() {
              _step = _Step.email;
              _code.clear();
              _error = null;
            }),
            child: Text(l10n.changeEmail),
          ),
          TextButton(
            onPressed: _resendIn > 0 ? null : _resend,
            child: Text(_resendIn > 0 ? l10n.resendIn(_resendIn) : l10n.resendCode),
          ),
        ],
      ),
    ];
  }

  List<Widget> _detailsStep(BuildContext context) {
    final l10n = context.l10n;
    return [
      TextFormField(
        key: const Key('register-name'),
        controller: _name,
        textCapitalization: TextCapitalization.words,
        autofillHints: const [AutofillHints.name],
        decoration: InputDecoration(labelText: l10n.fullNameLabel, prefixIcon: const Icon(Icons.person_outline)),
        validator: (v) => validateRequired(l10n, v),
      ),
      const SizedBox(height: 14),
      TextFormField(
        controller: _phone,
        keyboardType: TextInputType.phone,
        autofillHints: const [AutofillHints.telephoneNumber],
        decoration: InputDecoration(labelText: l10n.phoneLabel, prefixIcon: const Icon(Icons.phone_outlined)),
      ),
      const SizedBox(height: 14),
      TextFormField(
        controller: _city,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: l10n.cityLabel,
          helperText: l10n.cityHelper,
          prefixIcon: const Icon(Icons.location_on_outlined),
        ),
      ),
      const SizedBox(height: 14),
      PasswordField(
        key: const Key('register-password'),
        controller: _password,
        label: l10n.passwordLabel,
        autofillHints: const [AutofillHints.newPassword],
        onChanged: (_) => setState(() {}),
        validator: (v) => PasswordRules(v ?? '').allMet ? null : l10n.passwordTooWeak,
      ),
      PasswordChecklist(_password.text),
      const SizedBox(height: 20),
      BusyButton(label: l10n.createAccount, busy: _busy, onPressed: _register),
    ];
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current});

  final _Step current;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final labels = [l10n.registerStepEmail, l10n.registerStepCode, l10n.registerStepDetails];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= current.index ? scheme.primary : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: i <= current.index ? scheme.primary : scheme.onSurfaceVariant,
                        fontWeight: i == current.index ? FontWeight.w700 : FontWeight.w400,
                      ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
