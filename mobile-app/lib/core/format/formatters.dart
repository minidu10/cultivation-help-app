import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String get localeName => Localizations.localeOf(this).toLanguageTag();
}

/// "Rs. 16,500" or "Rs. 1,800.5": rupees with grouping and at most two
/// decimals, never a trailing ".00" on whole amounts.
String formatMoney(BuildContext context, num amount) =>
    context.l10n.money(formatNumber(context, amount));

String formatNumber(BuildContext context, num value) =>
    NumberFormat('#,##0.##', context.localeName).format(value);

String formatDate(BuildContext context, DateTime date) =>
    DateFormat.yMMMd(context.localeName).format(date);

String formatDateTime(BuildContext context, DateTime value) =>
    '${DateFormat.MMMd(context.localeName).format(value)} · ${DateFormat.jm(context.localeName).format(value)}';
