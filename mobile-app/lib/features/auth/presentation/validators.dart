import '../../../l10n/app_localizations.dart';

final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(AppLocalizations l10n, String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return l10n.requiredField;
  return _email.hasMatch(v) ? null : l10n.invalidEmail;
}

String? validateRequired(AppLocalizations l10n, String? value) =>
    (value?.trim().isEmpty ?? true) ? l10n.requiredField : null;

/// The server's PasswordPolicy, mirrored so the checklist can tick live.
/// The server still enforces it; this only saves a round trip.
class PasswordRules {
  const PasswordRules(this.password);

  final String password;

  bool get length => password.length >= 8;
  bool get upper => password.contains(RegExp('[A-Z]'));
  bool get lower => password.contains(RegExp('[a-z]'));
  bool get digit => password.contains(RegExp('[0-9]'));
  bool get symbol => password.contains(RegExp('[^A-Za-z0-9]'));

  bool get allMet => length && upper && lower && digit && symbol;

  List<(String, bool)> describe(AppLocalizations l10n) => [
        (l10n.ruleLength, length),
        (l10n.ruleUpper, upper),
        (l10n.ruleLower, lower),
        (l10n.ruleDigit, digit),
        (l10n.ruleSymbol, symbol),
      ];
}
