import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/format/formatters.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../data/auth_repository.dart';
import '../data/google_identity.dart';
import 'validators.dart';

/// The shared frame of the sign-in screens: brand mark, title, content.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.title, this.subtitle, required this.child, this.showBack = false});

  final String title;
  final String? subtitle;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: showBack ? AppBar() : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const BrandMark(),
                  const SizedBox(height: 28),
                  Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(subtitle!, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                  const SizedBox(height: 24),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Brand.leaf, Brand.lime]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.eco, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(
            context.l10n.appTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      );
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: widget.controller,
        obscureText: _obscured,
        validator: widget.validator,
        onChanged: widget.onChanged,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onSubmitted,
        autofillHints: widget.autofillHints,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            tooltip: _obscured ? context.l10n.showPassword : context.l10n.hidePassword,
            icon: Icon(_obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            onPressed: () => setState(() => _obscured = !_obscured),
          ),
        ),
      );
}

/// Ticks off each rule as the password is typed.
class PasswordChecklist extends StatelessWidget {
  const PasswordChecklist(this.password, {super.key});

  final String password;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rules = PasswordRules(password).describe(context.l10n);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.passwordRulesTitle, style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          for (final (rule, met) in rules)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    met ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 16,
                    color: met ? Brand.profit : theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Text(rule, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Shown only when the server reports Google Sign-In as configured.
class GoogleSignInButton extends ConsumerStatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  ConsumerState<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends ConsumerState<GoogleSignInButton> {
  bool _busy = false;

  Future<void> _signIn(String clientId) async {
    setState(() => _busy = true);
    try {
      final idToken = await ref.read(googleIdentityProvider).idToken(serverClientId: clientId);
      if (idToken == null) return;
      final session = await ref.read(authRepositoryProvider).google(idToken);
      await ref.read(sessionControllerProvider.notifier).signIn(session);
    } on ApiException catch (e) {
      // The server refused the token: its message says why.
      if (mounted) showError(context, e);
    } on Exception {
      // The Google SDK failed (no Play Services, misconfigured client).
      if (mounted) showMessage(context, context.l10n.googleSignInFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(authConfigProvider).valueOrNull;
    final clientId = config?.googleClientId;
    if (config == null || !config.googleEnabled || clientId == null || clientId.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(context.l10n.orDivider)),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _busy ? null : () => _signIn(clientId),
          icon: _busy
              ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.account_circle_outlined),
          label: Text(context.l10n.continueWithGoogle),
        ),
      ],
    );
  }
}

/// A primary button that shows a spinner instead of its label while busy.
class BusyButton extends StatelessWidget {
  const BusyButton({super.key, required this.label, required this.busy, required this.onPressed});

  final String label;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
        onPressed: busy ? null : onPressed,
        child: busy
            ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
            : Text(label),
      );
}

/// An inline error line inside a form, for failures that are not one field's.
class FormError extends StatelessWidget {
  const FormError(this.message, {super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message!, style: TextStyle(color: scheme.onErrorContainer))),
        ],
      ),
    );
  }
}
