// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardSummary _$DashboardSummaryFromJson(Map<String, dynamic> json) =>
    _DashboardSummary(
      totals: DashboardTotals.fromJson(json['totals'] as Map<String, dynamic>),
      crops:
          (json['crops'] as List<dynamic>?)
              ?.map((e) => CropSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      dueReminders:
          (json['dueReminders'] as List<dynamic>?)
              ?.map((e) => Reminder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      upcomingReminders:
          (json['upcomingReminders'] as List<dynamic>?)
              ?.map((e) => Reminder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DashboardSummaryToJson(_DashboardSummary instance) =>
    <String, dynamic>{
      'totals': instance.totals,
      'crops': instance.crops,
      'dueReminders': instance.dueReminders,
      'upcomingReminders': instance.upcomingReminders,
    };

_DashboardTotals _$DashboardTotalsFromJson(Map<String, dynamic> json) =>
    _DashboardTotals(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0,
      activeCrops: (json['activeCrops'] as num?)?.toInt() ?? 0,
      totalCrops: (json['totalCrops'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DashboardTotalsToJson(_DashboardTotals instance) =>
    <String, dynamic>{
      'totalRevenue': instance.totalRevenue,
      'totalExpenses': instance.totalExpenses,
      'netProfit': instance.netProfit,
      'activeCrops': instance.activeCrops,
      'totalCrops': instance.totalCrops,
    };

_CropSummary _$CropSummaryFromJson(Map<String, dynamic> json) => _CropSummary(
  cropId: (json['cropId'] as num).toInt(),
  cropName: json['cropName'] as String,
  variety: json['variety'] as String?,
  status:
      $enumDecodeNullable(
        _$CropStatusEnumMap,
        json['status'],
        unknownValue: CropStatus.planted,
      ) ??
      CropStatus.planted,
  fieldLocation: json['fieldLocation'] as String?,
  aiInsightsEnabled: json['aiInsightsEnabled'] as bool? ?? true,
  totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0,
  totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
  netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0,
  result: json['result'] as String? ?? 'PROFIT',
);

Map<String, dynamic> _$CropSummaryToJson(_CropSummary instance) =>
    <String, dynamic>{
      'cropId': instance.cropId,
      'cropName': instance.cropName,
      'variety': instance.variety,
      'status': _$CropStatusEnumMap[instance.status]!,
      'fieldLocation': instance.fieldLocation,
      'aiInsightsEnabled': instance.aiInsightsEnabled,
      'totalExpenses': instance.totalExpenses,
      'totalRevenue': instance.totalRevenue,
      'netProfit': instance.netProfit,
      'result': instance.result,
    };

const _$CropStatusEnumMap = {
  CropStatus.planted: 'PLANTED',
  CropStatus.growing: 'GROWING',
  CropStatus.readyToHarvest: 'READY_TO_HARVEST',
  CropStatus.harvested: 'HARVESTED',
  CropStatus.failed: 'FAILED',
};
