import 'package:agromaster/core/api/api_exception.dart';
import 'package:agromaster/core/offline/connection_status.dart';
import 'package:agromaster/core/offline/offline_banner.dart';
import 'package:agromaster/core/offline/outbox.dart';
import 'package:agromaster/core/session/session_controller.dart';
import 'package:agromaster/features/auth/data/auth_models.dart';
import 'package:agromaster/features/expenses/data/expense_models.dart';
import 'package:agromaster/features/expenses/data/expense_repository.dart';
import 'package:agromaster/features/expenses/presentation/expenses_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

/// Opens the add-expense sheet from a button, as the crop page does.
class _Opener extends StatelessWidget {
  const _Opener();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => const ExpenseSheet(cropId: 7),
            ),
            child: const Text('open'),
          ),
        ),
      );
}

void main() {
  setUpAll(() => registerFallbackValue(const ExpenseInput()));

  testWidgets('an expense saved with no signal is queued, not lost', (tester) async {
    final repo = MockExpenseRepository();
    when(() => repo.add(any(), any())).thenThrow(
      const ApiException('Cannot reach AgroMaster.', offline: true),
    );
    final container = await pumpScreen(tester, const _Opener(), overrides: [
      expenseRepositoryProvider.overrideWithValue(repo),
    ]);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('expense-description')), 'Urea 50kg');
    await tester.enterText(find.byKey(const Key('expense-amount')), '4500');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final queued = container.read(outboxProvider).pending.single;
    expect(queued.cropId, 7);
    expect(queued.kind, OutboxKind.expense);
    expect(queued.body['clientRef'], queued.clientRef);
    expect(queued.label, startsWith('Urea 50kg'));
    expect(find.text('Saved on this phone. It will be sent when you are back online.'), findsOneWidget);
  });

  testWidgets('every new expense carries a client reference, online too', (tester) async {
    final repo = MockExpenseRepository();
    when(() => repo.add(any(), any())).thenAnswer((_) async =>
        Expense(id: 1, category: ExpenseCategory.fertilizer, description: 'Urea', amount: 4500, expenseDate: DateTime(2026)));
    await pumpScreen(tester, const _Opener(), overrides: [expenseRepositoryProvider.overrideWithValue(repo)]);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('expense-description')), 'Urea');
    await tester.enterText(find.byKey(const Key('expense-amount')), '4500');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final sent = verify(() => repo.add(7, captureAny())).captured.single as ExpenseInput;
    expect(sent.clientRef, isNotNull);
  });

  testWidgets('a server refusal is shown, not queued', (tester) async {
    final repo = MockExpenseRepository();
    when(() => repo.add(any(), any())).thenThrow(const ApiException('Amount must be greater than zero', statusCode: 400));
    final container = await pumpScreen(tester, const _Opener(), overrides: [
      expenseRepositoryProvider.overrideWithValue(repo),
    ]);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('expense-description')), 'Urea');
    await tester.enterText(find.byKey(const Key('expense-amount')), '4500');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Amount must be greater than zero'), findsOneWidget);
    expect(container.read(outboxProvider).pending, isEmpty);
  });

  group('offline banner', () {
    Future<ProviderContainer> signedIn(WidgetTester tester) async {
      final container = await pumpScreen(tester, const OfflineFrame(child: Scaffold(body: Text('page'))));
      await container.read(sessionControllerProvider.notifier).signIn(
            const AuthSession(token: 'a', refreshToken: 'r', email: 'n@example.com', fullName: 'Nimal'),
          );
      await tester.pump();
      return container;
    }

    testWidgets('says so when the app is offline', (tester) async {
      final container = await signedIn(tester);

      container.read(connectionStatusProvider.notifier).offline();
      await tester.pump();

      expect(find.text('You are offline. Showing what was last saved.'), findsOneWidget);
      expect(find.text('page'), findsOneWidget);
    });

    testWidgets('counts what is waiting and offers to send it', (tester) async {
      final container = await signedIn(tester);

      for (final ref in ['a', 'b']) {
        await container.read(outboxProvider.notifier).enqueue(OutboxEntry(
              clientRef: ref, kind: OutboxKind.expense, cropId: 7, body: const {}, label: ref,
              createdAt: DateTime(2026),
            ));
      }
      await tester.pump();

      expect(find.textContaining('2 records waiting to send'), findsOneWidget);
      expect(find.text('Send now'), findsOneWidget);
    });

    testWidgets('is hidden when all is well', (tester) async {
      await signedIn(tester);

      expect(find.textContaining('offline'), findsNothing);
      expect(find.textContaining('waiting'), findsNothing);
    });
  });
}
