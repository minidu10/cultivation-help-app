import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/json/converters.dart';

part 'harvest_models.freezed.dart';
part 'harvest_models.g.dart';

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum QuantityUnit {
  kg,
  tonne,
  bushel,
  pound,
  liter;

  String get wire => _$QuantityUnitEnumMap[this]!;
}

@freezed
abstract class Harvest with _$Harvest {
  const factory Harvest({
    required int id,
    @DateOnlyConverter() required DateTime harvestDate,
    required double quantity,
    @JsonKey(unknownEnumValue: QuantityUnit.kg) required QuantityUnit unit,
    required double pricePerUnit,
    required double totalRevenue,
    String? buyerName,
    String? notes,
  }) = _Harvest;

  factory Harvest.fromJson(Map<String, dynamic> json) => _$HarvestFromJson(json);
}
