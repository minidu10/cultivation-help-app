// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diagnosis_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Diagnosis {

 int? get id; int get cropId; bool get isPlant; String get cropGuess; String get condition; double get confidence;@JsonKey(unknownEnumValue: DiagnosisSeverity.moderate) DiagnosisSeverity get severity; bool get seeExpert; List<String> get symptoms; List<String> get treatmentOrganic; List<String> get treatmentChemical; List<String> get prevention; String? get note;@NullableLocalDateTimeConverter() DateTime? get createdAt; String? get thumbnailUrl;
/// Create a copy of Diagnosis
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiagnosisCopyWith<Diagnosis> get copyWith => _$DiagnosisCopyWithImpl<Diagnosis>(this as Diagnosis, _$identity);

  /// Serializes this Diagnosis to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Diagnosis&&(identical(other.id, id) || other.id == id)&&(identical(other.cropId, cropId) || other.cropId == cropId)&&(identical(other.isPlant, isPlant) || other.isPlant == isPlant)&&(identical(other.cropGuess, cropGuess) || other.cropGuess == cropGuess)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.seeExpert, seeExpert) || other.seeExpert == seeExpert)&&const DeepCollectionEquality().equals(other.symptoms, symptoms)&&const DeepCollectionEquality().equals(other.treatmentOrganic, treatmentOrganic)&&const DeepCollectionEquality().equals(other.treatmentChemical, treatmentChemical)&&const DeepCollectionEquality().equals(other.prevention, prevention)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cropId,isPlant,cropGuess,condition,confidence,severity,seeExpert,const DeepCollectionEquality().hash(symptoms),const DeepCollectionEquality().hash(treatmentOrganic),const DeepCollectionEquality().hash(treatmentChemical),const DeepCollectionEquality().hash(prevention),note,createdAt,thumbnailUrl);

@override
String toString() {
  return 'Diagnosis(id: $id, cropId: $cropId, isPlant: $isPlant, cropGuess: $cropGuess, condition: $condition, confidence: $confidence, severity: $severity, seeExpert: $seeExpert, symptoms: $symptoms, treatmentOrganic: $treatmentOrganic, treatmentChemical: $treatmentChemical, prevention: $prevention, note: $note, createdAt: $createdAt, thumbnailUrl: $thumbnailUrl)';
}


}

/// @nodoc
abstract mixin class $DiagnosisCopyWith<$Res>  {
  factory $DiagnosisCopyWith(Diagnosis value, $Res Function(Diagnosis) _then) = _$DiagnosisCopyWithImpl;
@useResult
$Res call({
 int? id, int cropId, bool isPlant, String cropGuess, String condition, double confidence,@JsonKey(unknownEnumValue: DiagnosisSeverity.moderate) DiagnosisSeverity severity, bool seeExpert, List<String> symptoms, List<String> treatmentOrganic, List<String> treatmentChemical, List<String> prevention, String? note,@NullableLocalDateTimeConverter() DateTime? createdAt, String? thumbnailUrl
});




}
/// @nodoc
class _$DiagnosisCopyWithImpl<$Res>
    implements $DiagnosisCopyWith<$Res> {
  _$DiagnosisCopyWithImpl(this._self, this._then);

  final Diagnosis _self;
  final $Res Function(Diagnosis) _then;

/// Create a copy of Diagnosis
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? cropId = null,Object? isPlant = null,Object? cropGuess = null,Object? condition = null,Object? confidence = null,Object? severity = null,Object? seeExpert = null,Object? symptoms = null,Object? treatmentOrganic = null,Object? treatmentChemical = null,Object? prevention = null,Object? note = freezed,Object? createdAt = freezed,Object? thumbnailUrl = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,cropId: null == cropId ? _self.cropId : cropId // ignore: cast_nullable_to_non_nullable
as int,isPlant: null == isPlant ? _self.isPlant : isPlant // ignore: cast_nullable_to_non_nullable
as bool,cropGuess: null == cropGuess ? _self.cropGuess : cropGuess // ignore: cast_nullable_to_non_nullable
as String,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as DiagnosisSeverity,seeExpert: null == seeExpert ? _self.seeExpert : seeExpert // ignore: cast_nullable_to_non_nullable
as bool,symptoms: null == symptoms ? _self.symptoms : symptoms // ignore: cast_nullable_to_non_nullable
as List<String>,treatmentOrganic: null == treatmentOrganic ? _self.treatmentOrganic : treatmentOrganic // ignore: cast_nullable_to_non_nullable
as List<String>,treatmentChemical: null == treatmentChemical ? _self.treatmentChemical : treatmentChemical // ignore: cast_nullable_to_non_nullable
as List<String>,prevention: null == prevention ? _self.prevention : prevention // ignore: cast_nullable_to_non_nullable
as List<String>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Diagnosis].
extension DiagnosisPatterns on Diagnosis {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Diagnosis value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Diagnosis() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Diagnosis value)  $default,){
final _that = this;
switch (_that) {
case _Diagnosis():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Diagnosis value)?  $default,){
final _that = this;
switch (_that) {
case _Diagnosis() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int cropId,  bool isPlant,  String cropGuess,  String condition,  double confidence, @JsonKey(unknownEnumValue: DiagnosisSeverity.moderate)  DiagnosisSeverity severity,  bool seeExpert,  List<String> symptoms,  List<String> treatmentOrganic,  List<String> treatmentChemical,  List<String> prevention,  String? note, @NullableLocalDateTimeConverter()  DateTime? createdAt,  String? thumbnailUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Diagnosis() when $default != null:
return $default(_that.id,_that.cropId,_that.isPlant,_that.cropGuess,_that.condition,_that.confidence,_that.severity,_that.seeExpert,_that.symptoms,_that.treatmentOrganic,_that.treatmentChemical,_that.prevention,_that.note,_that.createdAt,_that.thumbnailUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int cropId,  bool isPlant,  String cropGuess,  String condition,  double confidence, @JsonKey(unknownEnumValue: DiagnosisSeverity.moderate)  DiagnosisSeverity severity,  bool seeExpert,  List<String> symptoms,  List<String> treatmentOrganic,  List<String> treatmentChemical,  List<String> prevention,  String? note, @NullableLocalDateTimeConverter()  DateTime? createdAt,  String? thumbnailUrl)  $default,) {final _that = this;
switch (_that) {
case _Diagnosis():
return $default(_that.id,_that.cropId,_that.isPlant,_that.cropGuess,_that.condition,_that.confidence,_that.severity,_that.seeExpert,_that.symptoms,_that.treatmentOrganic,_that.treatmentChemical,_that.prevention,_that.note,_that.createdAt,_that.thumbnailUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int cropId,  bool isPlant,  String cropGuess,  String condition,  double confidence, @JsonKey(unknownEnumValue: DiagnosisSeverity.moderate)  DiagnosisSeverity severity,  bool seeExpert,  List<String> symptoms,  List<String> treatmentOrganic,  List<String> treatmentChemical,  List<String> prevention,  String? note, @NullableLocalDateTimeConverter()  DateTime? createdAt,  String? thumbnailUrl)?  $default,) {final _that = this;
switch (_that) {
case _Diagnosis() when $default != null:
return $default(_that.id,_that.cropId,_that.isPlant,_that.cropGuess,_that.condition,_that.confidence,_that.severity,_that.seeExpert,_that.symptoms,_that.treatmentOrganic,_that.treatmentChemical,_that.prevention,_that.note,_that.createdAt,_that.thumbnailUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Diagnosis implements Diagnosis {
  const _Diagnosis({this.id, required this.cropId, this.isPlant = true, this.cropGuess = '', this.condition = '', this.confidence = 0, @JsonKey(unknownEnumValue: DiagnosisSeverity.moderate) this.severity = DiagnosisSeverity.moderate, this.seeExpert = false, final  List<String> symptoms = const [], final  List<String> treatmentOrganic = const [], final  List<String> treatmentChemical = const [], final  List<String> prevention = const [], this.note, @NullableLocalDateTimeConverter() this.createdAt, this.thumbnailUrl}): _symptoms = symptoms,_treatmentOrganic = treatmentOrganic,_treatmentChemical = treatmentChemical,_prevention = prevention;
  factory _Diagnosis.fromJson(Map<String, dynamic> json) => _$DiagnosisFromJson(json);

@override final  int? id;
@override final  int cropId;
@override@JsonKey() final  bool isPlant;
@override@JsonKey() final  String cropGuess;
@override@JsonKey() final  String condition;
@override@JsonKey() final  double confidence;
@override@JsonKey(unknownEnumValue: DiagnosisSeverity.moderate) final  DiagnosisSeverity severity;
@override@JsonKey() final  bool seeExpert;
 final  List<String> _symptoms;
@override@JsonKey() List<String> get symptoms {
  if (_symptoms is EqualUnmodifiableListView) return _symptoms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_symptoms);
}

 final  List<String> _treatmentOrganic;
@override@JsonKey() List<String> get treatmentOrganic {
  if (_treatmentOrganic is EqualUnmodifiableListView) return _treatmentOrganic;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_treatmentOrganic);
}

 final  List<String> _treatmentChemical;
@override@JsonKey() List<String> get treatmentChemical {
  if (_treatmentChemical is EqualUnmodifiableListView) return _treatmentChemical;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_treatmentChemical);
}

 final  List<String> _prevention;
@override@JsonKey() List<String> get prevention {
  if (_prevention is EqualUnmodifiableListView) return _prevention;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_prevention);
}

@override final  String? note;
@override@NullableLocalDateTimeConverter() final  DateTime? createdAt;
@override final  String? thumbnailUrl;

/// Create a copy of Diagnosis
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiagnosisCopyWith<_Diagnosis> get copyWith => __$DiagnosisCopyWithImpl<_Diagnosis>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiagnosisToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Diagnosis&&(identical(other.id, id) || other.id == id)&&(identical(other.cropId, cropId) || other.cropId == cropId)&&(identical(other.isPlant, isPlant) || other.isPlant == isPlant)&&(identical(other.cropGuess, cropGuess) || other.cropGuess == cropGuess)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.seeExpert, seeExpert) || other.seeExpert == seeExpert)&&const DeepCollectionEquality().equals(other._symptoms, _symptoms)&&const DeepCollectionEquality().equals(other._treatmentOrganic, _treatmentOrganic)&&const DeepCollectionEquality().equals(other._treatmentChemical, _treatmentChemical)&&const DeepCollectionEquality().equals(other._prevention, _prevention)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cropId,isPlant,cropGuess,condition,confidence,severity,seeExpert,const DeepCollectionEquality().hash(_symptoms),const DeepCollectionEquality().hash(_treatmentOrganic),const DeepCollectionEquality().hash(_treatmentChemical),const DeepCollectionEquality().hash(_prevention),note,createdAt,thumbnailUrl);

@override
String toString() {
  return 'Diagnosis(id: $id, cropId: $cropId, isPlant: $isPlant, cropGuess: $cropGuess, condition: $condition, confidence: $confidence, severity: $severity, seeExpert: $seeExpert, symptoms: $symptoms, treatmentOrganic: $treatmentOrganic, treatmentChemical: $treatmentChemical, prevention: $prevention, note: $note, createdAt: $createdAt, thumbnailUrl: $thumbnailUrl)';
}


}

/// @nodoc
abstract mixin class _$DiagnosisCopyWith<$Res> implements $DiagnosisCopyWith<$Res> {
  factory _$DiagnosisCopyWith(_Diagnosis value, $Res Function(_Diagnosis) _then) = __$DiagnosisCopyWithImpl;
@override @useResult
$Res call({
 int? id, int cropId, bool isPlant, String cropGuess, String condition, double confidence,@JsonKey(unknownEnumValue: DiagnosisSeverity.moderate) DiagnosisSeverity severity, bool seeExpert, List<String> symptoms, List<String> treatmentOrganic, List<String> treatmentChemical, List<String> prevention, String? note,@NullableLocalDateTimeConverter() DateTime? createdAt, String? thumbnailUrl
});




}
/// @nodoc
class __$DiagnosisCopyWithImpl<$Res>
    implements _$DiagnosisCopyWith<$Res> {
  __$DiagnosisCopyWithImpl(this._self, this._then);

  final _Diagnosis _self;
  final $Res Function(_Diagnosis) _then;

/// Create a copy of Diagnosis
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? cropId = null,Object? isPlant = null,Object? cropGuess = null,Object? condition = null,Object? confidence = null,Object? severity = null,Object? seeExpert = null,Object? symptoms = null,Object? treatmentOrganic = null,Object? treatmentChemical = null,Object? prevention = null,Object? note = freezed,Object? createdAt = freezed,Object? thumbnailUrl = freezed,}) {
  return _then(_Diagnosis(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,cropId: null == cropId ? _self.cropId : cropId // ignore: cast_nullable_to_non_nullable
as int,isPlant: null == isPlant ? _self.isPlant : isPlant // ignore: cast_nullable_to_non_nullable
as bool,cropGuess: null == cropGuess ? _self.cropGuess : cropGuess // ignore: cast_nullable_to_non_nullable
as String,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as DiagnosisSeverity,seeExpert: null == seeExpert ? _self.seeExpert : seeExpert // ignore: cast_nullable_to_non_nullable
as bool,symptoms: null == symptoms ? _self._symptoms : symptoms // ignore: cast_nullable_to_non_nullable
as List<String>,treatmentOrganic: null == treatmentOrganic ? _self._treatmentOrganic : treatmentOrganic // ignore: cast_nullable_to_non_nullable
as List<String>,treatmentChemical: null == treatmentChemical ? _self._treatmentChemical : treatmentChemical // ignore: cast_nullable_to_non_nullable
as List<String>,prevention: null == prevention ? _self._prevention : prevention // ignore: cast_nullable_to_non_nullable
as List<String>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
