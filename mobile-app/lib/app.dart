import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/session/session_controller.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class AgroMasterApp extends ConsumerWidget {
  const AgroMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The theme is the farmer's saved choice, which also applies on the web.
    final themeMode = ref.watch(sessionControllerProvider.select((s) => s.user?.themeMode)) ?? ThemeMode.system;

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
