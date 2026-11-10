import 'package:freezed_annotation/freezed_annotation.dart';

import '../../crops/data/crop_models.dart';
import '../../reminders/data/reminder_models.dart';

part 'dashboard_models.freezed.dart';
part 'dashboard_models.g.dart';

/// GET /api/dashboard/summary: everything the home screen shows, in one call.
@freezed
abstract class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    required DashboardTotals totals,
    @Default([]) List<CropSummary> crops,
    @Default([]) List<Reminder> dueReminders,
    @Default([]) List<Reminder> upcomingReminders,
  }) = _DashboardSummary;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) => _$DashboardSummaryFromJson(json);
}

@freezed
abstract class DashboardTotals with _$DashboardTotals {
  const factory DashboardTotals({
    @Default(0) double totalRevenue,
    @Default(0) double totalExpenses,
    @Default(0) double netProfit,
    @Default(0) int activeCrops,
    @Default(0) int totalCrops,
  }) = _DashboardTotals;

  factory DashboardTotals.fromJson(Map<String, dynamic> json) => _$DashboardTotalsFromJson(json);
}

@freezed
abstract class CropSummary with _$CropSummary {
  const factory CropSummary({
    required int cropId,
    required String cropName,
    String? variety,
    @JsonKey(unknownEnumValue: CropStatus.planted) @Default(CropStatus.planted) CropStatus status,
    String? fieldLocation,
    @Default(true) bool aiInsightsEnabled,
    @Default(0) double totalExpenses,
    @Default(0) double totalRevenue,
    @Default(0) double netProfit,
    @Default('PROFIT') String result,
  }) = _CropSummary;

  factory CropSummary.fromJson(Map<String, dynamic> json) => _$CropSummaryFromJson(json);
}
