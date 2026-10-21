import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/json/converters.dart';

part 'crop_models.freezed.dart';
part 'crop_models.g.dart';

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum CropStatus {
  planted,
  growing,
  readyToHarvest,
  harvested,
  failed;

  /// Still in the ground and not written off; matches the server's definition.
  bool get isActive => this != harvested && this != failed;

  String get wire => _$CropStatusEnumMap[this]!;
}

@freezed
abstract class Crop with _$Crop {
  const factory Crop({
    required int id,
    required String name,
    String? variety,
    String? fieldLocation,
    double? fieldSizeAcres,
    @DateOnlyConverter() required DateTime plantingDate,
    @NullableDateOnlyConverter() DateTime? expectedHarvestDate,
    @JsonKey(unknownEnumValue: CropStatus.planted) @Default(CropStatus.planted) CropStatus status,
    @Default(true) bool aiInsightsEnabled,
    String? notes,
  }) = _Crop;

  factory Crop.fromJson(Map<String, dynamic> json) => _$CropFromJson(json);
}

@freezed
abstract class ProfitLoss with _$ProfitLoss {
  const factory ProfitLoss({
    required int cropId,
    required String cropName,
    required double totalExpenses,
    required double totalRevenue,
    required double netProfit,
    required String result,
  }) = _ProfitLoss;

  const ProfitLoss._();

  factory ProfitLoss.fromJson(Map<String, dynamic> json) => _$ProfitLossFromJson(json);

  bool get isProfit => result == 'PROFIT';
}

@freezed
abstract class CropInsight with _$CropInsight {
  const factory CropInsight({
    required int cropId,
    required String insights,
    @NullableLocalDateTimeConverter() DateTime? generatedAt,
    @Default(false) bool freshlyGenerated,
  }) = _CropInsight;

  factory CropInsight.fromJson(Map<String, dynamic> json) => _$CropInsightFromJson(json);
}
