// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagnosis_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Diagnosis _$DiagnosisFromJson(Map<String, dynamic> json) => _Diagnosis(
  id: (json['id'] as num?)?.toInt(),
  cropId: (json['cropId'] as num).toInt(),
  isPlant: json['isPlant'] as bool? ?? true,
  cropGuess: json['cropGuess'] as String? ?? '',
  condition: json['condition'] as String? ?? '',
  confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
  severity:
      $enumDecodeNullable(
        _$DiagnosisSeverityEnumMap,
        json['severity'],
        unknownValue: DiagnosisSeverity.moderate,
      ) ??
      DiagnosisSeverity.moderate,
  seeExpert: json['seeExpert'] as bool? ?? false,
  symptoms:
      (json['symptoms'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  treatmentOrganic:
      (json['treatmentOrganic'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  treatmentChemical:
      (json['treatmentChemical'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  prevention:
      (json['prevention'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  note: json['note'] as String?,
  createdAt: const NullableLocalDateTimeConverter().fromJson(
    json['createdAt'] as String?,
  ),
  thumbnailUrl: json['thumbnailUrl'] as String?,
);

Map<String, dynamic> _$DiagnosisToJson(_Diagnosis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cropId': instance.cropId,
      'isPlant': instance.isPlant,
      'cropGuess': instance.cropGuess,
      'condition': instance.condition,
      'confidence': instance.confidence,
      'severity': _$DiagnosisSeverityEnumMap[instance.severity]!,
      'seeExpert': instance.seeExpert,
      'symptoms': instance.symptoms,
      'treatmentOrganic': instance.treatmentOrganic,
      'treatmentChemical': instance.treatmentChemical,
      'prevention': instance.prevention,
      'note': instance.note,
      'createdAt': const NullableLocalDateTimeConverter().toJson(
        instance.createdAt,
      ),
      'thumbnailUrl': instance.thumbnailUrl,
    };

const _$DiagnosisSeverityEnumMap = {
  DiagnosisSeverity.none: 'none',
  DiagnosisSeverity.low: 'low',
  DiagnosisSeverity.moderate: 'moderate',
  DiagnosisSeverity.severe: 'severe',
};
