import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/advisor/presentation/advisor_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/crops/presentation/crop_detail_screen.dart';
import '../../features/crops/presentation/crop_form_screen.dart';
import '../../features/crops/presentation/crops_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../session/session_controller.dart';

const _publicPaths = {'/login', '/register', '/forgot-password'};

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // GoRouter re-runs its redirect whenever this fires: on sign in, sign out
  // and session expiry, the user lands on the right side of the wall.
  final sessionChanges = ValueNotifier<int>(0);
  ref
    ..listen(sessionControllerProvider, (_, _) => sessionChanges.value++)
    ..onDispose(sessionChanges.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    refreshListenable: sessionChanges,
    redirect: (context, state) {
      final signedIn = ref.read(sessionControllerProvider).isSignedIn;
      final public = _publicPaths.contains(state.matchedLocation);
      if (!signedIn && !public) return '/login';
      if (signedIn && public) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(notice: state.extra as String?),
      ),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (context, state) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/crops', builder: (context, state) => const CropsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/advisor', builder: (context, state) => const AdvisorScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/more', builder: (context, state) => const SettingsScreen()),
          ]),
        ],
      ),
      // Full-screen pages pushed above the tab bar.
      GoRoute(
        path: '/crops/new',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const CropFormScreen(),
      ),
      GoRoute(
        path: '/crops/:id',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => CropDetailScreen(cropId: int.parse(state.pathParameters['id']!)),
        routes: [
          GoRoute(
            path: 'edit',
            parentNavigatorKey: _rootKey,
            builder: (context, state) => CropFormScreen(cropId: int.parse(state.pathParameters['id']!)),
          ),
        ],
      ),
    ],
  );
});
