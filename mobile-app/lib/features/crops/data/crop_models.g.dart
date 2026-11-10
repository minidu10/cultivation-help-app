// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crop_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Crop _$CropFromJson(Map<String, dynamic> json) => _Crop(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  variety: json['variety'] as String?,
  fieldLocation: json['fieldLocation'] as String?,
  fieldSizeAcres: (json['fieldSizeAcres'] as num?)?.toDouble(),
  plantingDate: const DateOnlyConverter().fromJson(
    json['plantingDate'] as String,
  ),
  expectedHarvestDate: const NullableDateOnlyConverter().fromJson(
    json['expectedHarvestDate'] as String?,
  ),
  status:
      $enumDecodeNullable(
        _$CropStatusEnumMap,
        json['status'],
        unknownValue: CropStatus.planted,
      ) ??
      CropStatus.planted,
  aiInsightsEnabled: json['aiInsightsEnabled'] as bool? ?? true,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$CropToJson(_Crop instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'variety': instance.variety,
  'fieldLocation': instance.fieldLocation,
  'fieldSizeAcres': instance.fieldSizeAcres,
  'plantingDate': const DateOnlyConverter().toJson(instance.plantingDate),
  'expectedHarvestDate': const NullableDateOnlyConverter().toJson(
    instance.expectedHarvestDate,
  ),
  'status': _$CropStatusEnumMap[instance.status]!,
  'aiInsightsEnabled': instance.aiInsightsEnabled,
  'notes': instance.notes,
};

const _$CropStatusEnumMap = {
  CropStatus.planted: 'PLANTED',
  CropStatus.growing: 'GROWING',
  CropStatus.readyToHarvest: 'READY_TO_HARVEST',
  CropStatus.harvested: 'HARVESTED',
  CropStatus.failed: 'FAILED',
};

_ProfitLoss _$ProfitLossFromJson(Map<String, dynamic> json) => _ProfitLoss(
  cropId: (json['cropId'] as num).toInt(),
  cropName: json['cropName'] as String,
  totalExpenses: (json['totalExpenses'] as num).toDouble(),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  netProfit: (json['netProfit'] as num).toDouble(),
  result: json['result'] as String,
);

Map<String, dynamic> _$ProfitLossToJson(_ProfitLoss instance) =>
    <String, dynamic>{
      'cropId': instance.cropId,
      'cropName': instance.cropName,
      'totalExpenses': instance.totalExpenses,
      'totalRevenue': instance.totalRevenue,
      'netProfit': instance.netProfit,
      'result': instance.result,
    };

_CropInsight _$CropInsightFromJson(Map<String, dynamic> json) => _CropInsight(
  cropId: (json['cropId'] as num).toInt(),
  insights: json['insights'] as String,
  generatedAt: const NullableLocalDateTimeConverter().fromJson(
    json['generatedAt'] as String?,
  ),
  freshlyGenerated: json['freshlyGenerated'] as bool? ?? false,
);

Map<String, dynamic> _$CropInsightToJson(_CropInsight instance) =>
    <String, dynamic>{
      'cropId': instance.cropId,
      'insights': instance.insights,
      'generatedAt': const NullableLocalDateTimeConverter().toJson(
        instance.generatedAt,
      ),
      'freshlyGenerated': instance.freshlyGenerated,
    };
