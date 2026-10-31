import 'package:agromaster/core/json/converters.dart';
import 'package:agromaster/features/advisor/data/advisor_repository.dart';
import 'package:agromaster/features/crops/data/crop_models.dart';
import 'package:agromaster/features/crops/data/crop_repository.dart';
import 'package:agromaster/features/dashboard/data/dashboard_models.dart';
import 'package:agromaster/features/expenses/data/expense_repository.dart';
import 'package:agromaster/features/reminders/data/reminder_models.dart';
import 'package:agromaster/features/reminders/data/reminder_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parsing what the backend sends', () {
    test('dashboard summary', () {
      final summary = DashboardSummary.fromJson({
        'totals': {'totalRevenue': 2000, 'totalExpenses': 1800.5, 'netProfit': 199.5, 'activeCrops': 1, 'totalCrops': 2},
        'crops': [
          {
            'cropId': 7,
            'cropName': 'Paddy',
            'status': 'READY_TO_HARVEST',
            'aiInsightsEnabled': true,
            'totalExpenses': 1500.5,
            'totalRevenue': 2000,
            'netProfit': 499.5,
            'result': 'PROFIT',
          },
        ],
        'dueReminders': [
          {'id': 1, 'cropId': 7, 'title': 'Urea', 'type': 'PEST_CONTROL', 'reminderAt': '2026-05-10T07:00:00'},
        ],
        'upcomingReminders': <Object>[],
      });

      expect(summary.totals.totalRevenue, 2000.0);
      expect(summary.crops.single.status, CropStatus.readyToHarvest);
      expect(summary.dueReminders.single.type, ReminderType.pestControl);
    });

    test('an unknown status from a newer server degrades instead of crashing', () {
      final crop = Crop.fromJson({'id': 1, 'name': 'Tea', 'plantingDate': '2026-01-01', 'status': 'DORMANT'});

      expect(crop.status, CropStatus.planted);
    });

    test('reminder times stay in farm-local time', () {
      final r = Reminder.fromJson({'id': 1, 'cropId': 2, 'title': 't', 'reminderAt': '2026-05-10T07:00:00'});

      expect(r.reminderAt.hour, 7);
      expect(r.reminderAt.isUtc, isFalse);
      expect(formatLocalDateTime(r.reminderAt), '2026-05-10T07:00:00');
    });
  });

  group('request bodies', () {
    test('a partial crop update sends only the changed fields', () {
      expect(const CropInput(status: CropStatus.harvested).toJson(), {'status': 'HARVESTED'});
    });

    test('dates go out as plain dates', () {
      final body = ExpenseInput(amount: 4500, expenseDate: DateTime(2026, 5, 3)).toJson();

      expect(body, {'amount': 4500.0, 'expenseDate': '2026-05-03'});
    });

    test('reminder times go out without a zone', () {
      final body = ReminderInput(reminderAt: DateTime(2026, 5, 10, 7, 30)).toJson();

      expect(body['reminderAt'], '2026-05-10T07:30:00');
    });
  });

  group('advisor context', () {
    Crop crop(String name, CropStatus status, {String? variety}) =>
        Crop(id: name.hashCode, name: name, variety: variety, plantingDate: DateTime(2026, 4, 1), status: status);

    test('describes crops the farmer is growing, active ones first', () {
      final text = AdvisorRepository.describeCrops([
        crop('Big Onion', CropStatus.failed),
        crop('Paddy', CropStatus.growing, variety: 'BG 300'),
      ]);

      expect(text.split('\n').first, startsWith('Paddy, variety BG 300, growing'));
      expect(text, contains('Big Onion'));
    });

    test('stays under the server\'s context limit', () {
      final many = [for (var i = 0; i < 200; i++) crop('Crop number $i', CropStatus.growing)];

      expect(AdvisorRepository.describeCrops(many).length, lessThanOrEqualTo(1900));
    });
  });
}
