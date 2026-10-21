import 'package:agromaster/core/providers.dart';
import 'package:agromaster/core/session/session_controller.dart';
import 'package:agromaster/core/storage/token_store.dart';
import 'package:agromaster/core/theme/app_theme.dart';
import 'package:agromaster/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pumps [child] with the app's theme and strings and a fresh provider scope.
/// Storage is in memory, so no test touches the keystore or disk.
Future<ProviderContainer> pumpScreen(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  MemoryTokenStore? tokens,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
    tokenStoreProvider.overrideWithValue(tokens ?? MemoryTokenStore()),
    hasStoredSessionProvider.overrideWithValue(false),
    ...overrides,
  ]);
  addTearDown(container.dispose);

  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  ));
  await tester.pump();
  return container;
}
