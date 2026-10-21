import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/format/formatters.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/common.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/google_identity.dart';
import '../../auth/presentation/auth_widgets.dart';
import '../../auth/presentation/validators.dart';
import '../data/user_models.dart';
import '../data/user_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: AsyncView(
        value: ref.watch(userProfileProvider),
        onRetry: () => ref.invalidate(userProfileProvider),
        data: (profile) => _SettingsBody(profile),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody(this.profile);

  final UserProfile profile;

  /// Saves one setting, then mirrors it into the session so the theme and
  /// greeting change immediately.
  Future<void> _update(
    BuildContext context,
    WidgetRef ref, {
    String? fullName,
    String? phone,
    String? city,
    String? themePreference,
    bool? desktopMode,
    bool? reminderEmails,
  }) async {
    try {
      final saved = await ref.read(userRepositoryProvider).update(
            fullName: fullName,
            phone: phone,
            city: city,
            themePreference: themePreference,
            desktopMode: desktopMode,
            reminderEmailsEnabled: reminderEmails,
          );
      await ref.read(sessionControllerProvider.notifier).updateUser((u) => u.copyWith(
            fullName: saved.fullName,
            city: saved.city,
            themePreference: saved.themePreference,
            desktopMode: saved.desktopMode,
          ));
      ref.invalidate(userProfileProvider);
    } on Exception catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final themeChoice = profile.desktopMode ? 'SYSTEM' : profile.themePreference.toUpperCase();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      children: [
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 26,
              child: Text(profile.fullName.isEmpty ? '?' : profile.fullName[0].toUpperCase()),
            ),
            title: Text(profile.fullName, style: theme.textTheme.titleMedium),
            subtitle: Text([profile.email, if (profile.city?.isNotEmpty ?? false) profile.city!].join('\n')),
            trailing: IconButton(
              tooltip: l10n.editProfile,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editProfile(context, ref),
            ),
          ),
        ),
        SectionHeader(l10n.appearanceSection),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(value: 'SYSTEM', label: Text(l10n.themeSystem), icon: const Icon(Icons.brightness_auto)),
            ButtonSegment(value: 'LIGHT', label: Text(l10n.themeLight), icon: const Icon(Icons.light_mode_outlined)),
            ButtonSegment(value: 'DARK', label: Text(l10n.themeDark), icon: const Icon(Icons.dark_mode_outlined)),
          ],
          selected: {themeChoice},
          onSelectionChanged: (choice) {
            final value = choice.first;
            _update(
              context,
              ref,
              desktopMode: value == 'SYSTEM',
              themePreference: value == 'SYSTEM' ? null : value,
            );
          },
        ),
        SectionHeader(l10n.notificationsSection),
        Card(
          child: SwitchListTile(
            value: profile.reminderEmailsEnabled,
            onChanged: (v) => _update(context, ref, reminderEmails: v),
            title: Text(l10n.reminderEmails),
            subtitle: Text(l10n.reminderEmailsHint),
            secondary: const Icon(Icons.mark_email_unread_outlined),
          ),
        ),
        SectionHeader(l10n.accountSection),
        Card(
          child: Column(
            children: [
              if (profile.hasPassword)
                ListTile(
                  leading: const Icon(Icons.password),
                  title: Text(l10n.changePassword),
                  onTap: () => showDialog<void>(context: context, builder: (_) => const _ChangePasswordDialog()),
                ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(l10n.signOut),
                onTap: () => ref.read(sessionControllerProvider.notifier).signOut(),
              ),
              ListTile(
                leading: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
                title: Text(l10n.deleteAccount, style: TextStyle(color: theme.colorScheme.error)),
                onTap: () => showDialog<void>(context: context, builder: (_) => _DeleteAccountDialog(profile)),
              ),
            ],
          ),
        ),
        SectionHeader(l10n.aboutSection),
        Text(l10n.aboutBody, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Future<void> _editProfile(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final name = TextEditingController(text: profile.fullName);
    final phone = TextEditingController(text: profile.phone);
    final city = TextEditingController(text: profile.city);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editProfile),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: InputDecoration(labelText: l10n.fullNameLabel)),
              const SizedBox(height: 12),
              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.phoneLabel),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: city,
                decoration: InputDecoration(labelText: l10n.cityLabel, helperText: l10n.cityHelper),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (saved == true && context.mounted) {
      await _update(context, ref, fullName: name.text.trim(), phone: phone.text.trim(), city: city.text.trim());
      if (context.mounted) showMessage(context, l10n.profileSaved);
    }
    name.dispose();
    phone.dispose();
    city.dispose();
  }
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = await ref
          .read(userRepositoryProvider)
          .changePassword(currentPassword: _current.text, newPassword: _next.text);
      // The server ended every session, this one included, and issued a new pair.
      await ref.read(sessionControllerProvider.notifier).signIn(session);
      if (!mounted) return;
      Navigator.pop(context);
      showMessage(context, context.l10n.passwordChanged);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.changePassword),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormError(_error),
              PasswordField(
                controller: _current,
                label: l10n.currentPasswordLabel,
                validator: (v) => validateRequired(l10n, v),
              ),
              const SizedBox(height: 12),
              PasswordField(
                controller: _next,
                label: l10n.newPasswordLabel,
                onChanged: (_) => setState(() {}),
                validator: (v) => PasswordRules(v ?? '').allMet ? null : l10n.passwordTooWeak,
              ),
              PasswordChecklist(_next.text),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
          onPressed: _busy ? null : _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

/// Deleting needs proof of ownership, not just a session: the password, or
/// for a Google-only account a fresh Google sign-in.
class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog(this.profile);

  final UserProfile profile;

  @override
  ConsumerState<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete({String? googleCredential}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    // Captured up front: the dialog is gone by the time the snackbar shows.
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.accountDeleted;
    try {
      await ref.read(userRepositoryProvider).deleteAccount(
            password: googleCredential == null ? _password.text : null,
            googleCredential: googleCredential,
          );
      if (mounted) Navigator.pop(context);
      await ref.read(sessionControllerProvider.notifier).signOut();
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmWithGoogle() async {
    final config = await ref.read(authConfigProvider.future);
    final clientId = config.googleClientId;
    if (clientId == null || clientId.isEmpty) return;
    try {
      final token = await ref.read(googleIdentityProvider).idToken(serverClientId: clientId);
      if (token != null) await _delete(googleCredential: token);
    } on Exception {
      if (mounted) setState(() => _error = context.l10n.googleSignInFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final usePassword = widget.profile.hasPassword;
    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
      title: Text(l10n.deleteAccountTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.deleteAccountBody),
            const SizedBox(height: 16),
            FormError(_error),
            if (usePassword) PasswordField(controller: _password, label: l10n.deleteAccountPassword),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 40),
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: _busy ? null : (usePassword ? () => _delete() : _confirmWithGoogle),
          child: Text(usePassword ? l10n.deleteForever : l10n.deleteAccountGoogle),
        ),
      ],
    );
  }
}
