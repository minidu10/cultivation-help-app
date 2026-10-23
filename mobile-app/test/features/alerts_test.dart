import 'package:agromaster/features/alerts/data/alert_models.dart';
import 'package:agromaster/features/alerts/data/alert_repository.dart';
import 'package:agromaster/features/alerts/presentation/alerts_section.dart';
import 'package:agromaster/features/reminders/data/reminder_models.dart';
import 'package:agromaster/features/reminders/data/reminder_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';

class MockReminderRepository extends Mock implements ReminderRepository {}

final _washoff = WeatherAlert(
  type: AlertType.rainWashoff,
  severity: AlertSeverity.high,
  cropId: 7,
  cropName: 'Paddy',
  reminderId: 42,
  reminderTitle: 'Apply urea',
  location: 'Polonnaruwa, LK',
  date: DateTime(2026, 10, 24),
  rainChancePercent: 85,
  suggestedAt: DateTime(2026, 10, 25, 9),
);

final _heat = WeatherAlert(
  type: AlertType.heatStress,
  cropName: 'Paddy, Chilli',
  location: 'Polonnaruwa, LK',
  date: DateTime(2026, 10, 25),
  maxTempC: 36.4,
);

Widget _section() => const Scaffold(body: SingleChildScrollView(child: AlertsSection()));

void main() {
  setUpAll(() => registerFallbackValue(const ReminderInput()));

  testWidgets('writes each alert from its figures', (tester) async {
    await pumpScreen(tester, _section(), overrides: [
      weatherAlertsProvider.overrideWith((ref) async => [_washoff, _heat]),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('Weather alerts for your plans'), findsOneWidget);
    expect(find.text('Rain may wash it off'), findsOneWidget);
    expect(find.textContaining('(85% chance). "Apply urea" for Paddy may wash off'), findsOneWidget);
    expect(find.text('Heat stress'), findsOneWidget);
    expect(find.textContaining('Up to 36°C at Polonnaruwa, LK'), findsOneWidget);
  });

  testWidgets('only a task with a better time gets the move button', (tester) async {
    await pumpScreen(tester, _section(), overrides: [
      weatherAlertsProvider.overrideWith((ref) async => [_washoff, _heat]),
    ]);
    await tester.pumpAndSettle();

    expect(find.textContaining('Move to'), findsOneWidget);
    expect(find.textContaining('Move to Sun, Oct 25'), findsOneWidget);
  });

  testWidgets('moving reschedules the reminder to the suggested time', (tester) async {
    final reminders = MockReminderRepository();
    when(() => reminders.update(any(), any(), any())).thenAnswer((_) async =>
        Reminder(id: 42, cropId: 7, title: 'Apply urea', reminderAt: DateTime(2026, 10, 25, 9)));
    await pumpScreen(tester, _section(), overrides: [
      weatherAlertsProvider.overrideWith((ref) async => [_washoff]),
      reminderRepositoryProvider.overrideWithValue(reminders),
    ]);
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Move to'));
    await tester.pumpAndSettle();

    final input = verify(() => reminders.update(7, 42, captureAny())).captured.single as ReminderInput;
    expect(input.toJson(), {'reminderAt': '2026-10-25T09:00:00'});
    expect(find.textContaining('Rescheduled to'), findsOneWidget);
  });

  testWidgets('nothing shows when there are no alerts', (tester) async {
    await pumpScreen(tester, _section(), overrides: [
      weatherAlertsProvider.overrideWith((ref) async => <WeatherAlert>[]),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('Weather alerts for your plans'), findsNothing);
  });

  testWidgets('an unreachable forecast hides the section instead of showing an error', (tester) async {
    await pumpScreen(tester, _section(), overrides: [
      weatherAlertsProvider.overrideWith((ref) async => throw Exception('offline')),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('Weather alerts for your plans'), findsNothing);
    expect(find.text('Try again'), findsNothing);
  });

  test('an alert type from a newer server falls back to its message', () {
    final alert = WeatherAlert.fromJson({
      'type': 'FROST',
      'date': '2026-10-25',
      'message': 'Frost likely tonight.',
    });

    expect(alert.type, AlertType.unknown);
    expect(alert.canReschedule, isFalse);
  });
}
