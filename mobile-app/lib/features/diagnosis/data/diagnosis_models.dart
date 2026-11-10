import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/json/converters.dart';

part 'diagnosis_models.freezed.dart';
part 'diagnosis_models.g.dart';

@JsonEnum()
enum DiagnosisSeverity { none, low, moderate, severe }

/// The crop doctor's answer for one photo.
///
/// [id] is null for a photo that was not of a plant: it is answered, so the
/// app can ask for a better one, but not kept in the crop's history.
@freezed
abstract class Diagnosis with _$Diagnosis {
  const factory Diagnosis({
    int? id,
    required int cropId,
    @Default(true) bool isPlant,
    @Default('') String cropGuess,
    @Default('') String condition,
    @Default(0) double confidence,
    @JsonKey(unknownEnumValue: DiagnosisSeverity.moderate) @Default(DiagnosisSeverity.moderate) DiagnosisSeverity severity,
    @Default(false) bool seeExpert,
    @Default([]) List<String> symptoms,
    @Default([]) List<String> treatmentOrganic,
    @Default([]) List<String> treatmentChemical,
    @Default([]) List<String> prevention,
    String? note,
    @NullableLocalDateTimeConverter() DateTime? createdAt,
    String? thumbnailUrl,
  }) = _Diagnosis;

  factory Diagnosis.fromJson(Map<String, dynamic> json) => _$DiagnosisFromJson(json);
}
