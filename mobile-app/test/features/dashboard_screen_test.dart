import 'package:agromaster/core/session/session_controller.dart';
import 'package:agromaster/features/alerts/data/alert_models.dart';
import 'package:agromaster/features/alerts/data/alert_repository.dart';
import 'package:agromaster/features/auth/data/auth_models.dart';
import 'package:agromaster/features/dashboard/data/dashboard_models.dart';
import 'package:agromaster/features/dashboard/data/dashboard_repository.dart';
import 'package:agromaster/features/dashboard/presentation/dashboard_screen.dart';
import 'package:agromaster/features/reminders/data/reminder_models.dart';
import 'package:agromaster/features/weather/data/weather_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

final _summary = DashboardSummary(
  totals: const DashboardTotals(totalRevenue: 2000, totalExpenses: 1800.5, netProfit: 199.5, activeCrops: 1, totalCrops: 2),
  crops: const [
    CropSummary(cropId: 1, cropName: 'Paddy', totalExpenses: 1500.5, totalRevenue: 2000, netProfit: 499.5),
    CropSummary(cropId: 2, cropName: 'Onion', totalExpenses: 300, netProfit: -300, result: 'LOSS'),
  ],
  dueReminders: [
    Reminder(id: 9, cropId: 1, title: 'Apply urea', type: ReminderType.fertilizer, reminderAt: DateTime(2026, 5, 10, 7)),
  ],
);

void main() {
  testWidgets('greets the farmer and shows the server\'s totals', (tester) async {
    final container = await pumpScreen(
      tester,
      const DashboardScreen(),
      overrides: [
        dashboardProvider.overrideWith((ref) async => _summary),
        farmWeatherProvider.overrideWith((ref) async => throw Exception('offline')),
        weatherAlertsProvider.overrideWith((ref) async => <WeatherAlert>[]),
      ],
    );
    await container.read(sessionControllerProvider.notifier).signIn(
          const AuthSession(token: 'a', refreshToken: 'r', email: 'n@example.com', fullName: 'Nimal Perera'),
        );
    await tester.pumpAndSettle();

    expect(find.text('Ayubowan, Nimal'), findsOneWidget);
    expect(find.text('Rs. 2,000'), findsOneWidget);
    expect(find.text('Rs. 1,800.5'), findsOneWidget);
    expect(find.text('Rs. 199.5'), findsOneWidget);
    expect(find.text('2 total'), findsOneWidget);
    expect(find.text('Apply urea'), findsOneWidget);
  });

  testWidgets('weather failing does not take the rest of the dashboard down', (tester) async {
    await pumpScreen(
      tester,
      const DashboardScreen(),
      overrides: [
        dashboardProvider.overrideWith((ref) async => _summary),
        farmWeatherProvider.overrideWith((ref) async => throw Exception('offline')),
        weatherAlertsProvider.overrideWith((ref) async => <WeatherAlert>[]),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Weather is unavailable right now.'), findsOneWidget);
    expect(find.text('Rs. 2,000'), findsOneWidget);
  });
}
