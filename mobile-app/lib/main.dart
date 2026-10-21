import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers.dart';
import 'core/session/session_controller.dart';
import 'core/storage/token_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Both stores are read before the first frame so a signed-in farmer opens
  // straight onto the dashboard, with no flash of the login screen.
  final prefs = await SharedPreferences.getInstance();
  final tokens = SecureTokenStore();
  final hasSession = await tokens.readRefreshToken() != null;

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      tokenStoreProvider.overrideWithValue(tokens),
      hasStoredSessionProvider.overrideWithValue(hasSession),
    ],
    child: const AgroMasterApp(),
  ));
}
