import 'package:agromaster/core/api/api_exception.dart';
import 'package:agromaster/core/session/session_controller.dart';
import 'package:agromaster/core/storage/token_store.dart';
import 'package:agromaster/features/auth/data/auth_models.dart';
import 'package:agromaster/features/auth/data/auth_repository.dart';
import 'package:agromaster/features/auth/presentation/login_screen.dart';
import 'package:agromaster/features/auth/presentation/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

const _session = AuthSession(
  token: 'access',
  refreshToken: 'refresh',
  email: 'nimal@example.com',
  fullName: 'Nimal Perera',
  city: 'Polonnaruwa',
);

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
    when(() => repo.config()).thenAnswer((_) async => const AuthConfig());
  });

  group('LoginScreen', () {
    testWidgets('checks the fields before calling the server', (tester) async {
      await pumpScreen(tester, const LoginScreen(), overrides: [authRepositoryProvider.overrideWithValue(repo)]);

      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pump();

      expect(find.text('Required'), findsWidgets);
      verifyNever(() => repo.login(any(), any()));
    });

    testWidgets('a successful sign-in stores the tokens and starts the session', (tester) async {
      when(() => repo.login(any(), any())).thenAnswer((_) async => _session);
      final tokens = MemoryTokenStore();
      final container = await pumpScreen(
        tester,
        const LoginScreen(),
        tokens: tokens,
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'nimal@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'Str0ng!Pass');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      verify(() => repo.login('nimal@example.com', 'Str0ng!Pass')).called(1);
      expect(container.read(sessionControllerProvider).user?.fullName, 'Nimal Perera');
      expect(tokens.refreshToken, 'refresh');
    });

    testWidgets('shows the server\'s reason when sign-in is refused', (tester) async {
      when(() => repo.login(any(), any()))
          .thenThrow(const ApiException('Invalid email or password', statusCode: 401));
      await pumpScreen(tester, const LoginScreen(), overrides: [authRepositoryProvider.overrideWithValue(repo)]);

      await tester.enterText(find.byType(TextFormField).at(0), 'nimal@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email or password'), findsOneWidget);
    });

    testWidgets('says why when the session ran out', (tester) async {
      final container = await pumpScreen(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      );

      container.read(sessionControllerProvider.notifier).expire();
      await tester.pump();

      expect(find.text('Your session has ended. Please sign in again.'), findsOneWidget);
    });
  });

  group('RegisterScreen', () {
    testWidgets('walks through email, code and details, then signs in', (tester) async {
      when(() => repo.sendCode(any())).thenAnswer((_) async {});
      when(() => repo.verifyCode(any(), any())).thenAnswer((_) async {});
      when(() => repo.register(
            fullName: any(named: 'fullName'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            phone: any(named: 'phone'),
            city: any(named: 'city'),
          )).thenAnswer((_) async => _session);
      final container = await pumpScreen(
        tester,
        const RegisterScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
      );

      // Step 1: email.
      await tester.enterText(find.byKey(const Key('register-email')), 'nimal@example.com');
      await tester.tap(find.widgetWithText(FilledButton, 'Send code'));
      await tester.pump();
      expect(find.text('We sent a 6-digit code to nimal@example.com.'), findsOneWidget);
      expect(find.text('Resend in 60s'), findsOneWidget);

      // Step 2: a short code is rejected before the server sees it.
      await tester.enterText(find.byKey(const Key('register-code')), '123');
      await tester.tap(find.widgetWithText(FilledButton, 'Verify'));
      await tester.pump();
      expect(find.text('Enter the 6 digits from the email'), findsOneWidget);
      verifyNever(() => repo.verifyCode(any(), any()));

      await tester.enterText(find.byKey(const Key('register-code')), '123456');
      await tester.tap(find.widgetWithText(FilledButton, 'Verify'));
      await tester.pump();
      verify(() => repo.verifyCode('nimal@example.com', '123456')).called(1);

      // Step 3: a weak password is caught by the checklist rules.
      await tester.enterText(find.byKey(const Key('register-name')), 'Nimal Perera');
      await tester.enterText(find.byKey(const Key('register-password')), 'weak');
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Create account'));
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pump();
      expect(find.text('Password does not meet every rule'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('register-password')), 'Str0ng!Pass');
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();

      expect(container.read(sessionControllerProvider).isSignedIn, isTrue);
    });

    testWidgets('a rejected email stays on the first step with the reason', (tester) async {
      when(() => repo.sendCode(any())).thenThrow(
        const ApiException('This email is already registered. Try logging in instead.', statusCode: 409),
      );
      await pumpScreen(tester, const RegisterScreen(), overrides: [authRepositoryProvider.overrideWithValue(repo)]);

      await tester.enterText(find.byKey(const Key('register-email')), 'taken@example.com');
      await tester.tap(find.widgetWithText(FilledButton, 'Send code'));
      await tester.pump();

      expect(find.text('This email is already registered. Try logging in instead.'), findsOneWidget);
      expect(find.byKey(const Key('register-email')), findsOneWidget);
    });
  });
}
