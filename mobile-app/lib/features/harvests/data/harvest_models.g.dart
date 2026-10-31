// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'harvest_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Harvest _$HarvestFromJson(Map<String, dynamic> json) => _Harvest(
  id: (json['id'] as num).toInt(),
  harvestDate: const DateOnlyConverter().fromJson(
    json['harvestDate'] as String,
  ),
  quantity: (json['quantity'] as num).toDouble(),
  unit: $enumDecode(
    _$QuantityUnitEnumMap,
    json['unit'],
    unknownValue: QuantityUnit.kg,
  ),
  pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  buyerName: json['buyerName'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$HarvestToJson(_Harvest instance) => <String, dynamic>{
  'id': instance.id,
  'harvestDate': const DateOnlyConverter().toJson(instance.harvestDate),
  'quantity': instance.quantity,
  'unit': _$QuantityUnitEnumMap[instance.unit]!,
  'pricePerUnit': instance.pricePerUnit,
  'totalRevenue': instance.totalRevenue,
  'buyerName': instance.buyerName,
  'notes': instance.notes,
};

const _$QuantityUnitEnumMap = {
  QuantityUnit.kg: 'KG',
  QuantityUnit.tonne: 'TONNE',
  QuantityUnit.bushel: 'BUSHEL',
  QuantityUnit.pound: 'POUND',
  QuantityUnit.liter: 'LITER',
};
