// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'crop_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Crop {

 int get id; String get name; String? get variety; String? get fieldLocation; double? get fieldSizeAcres;@DateOnlyConverter() DateTime get plantingDate;@NullableDateOnlyConverter() DateTime? get expectedHarvestDate;@JsonKey(unknownEnumValue: CropStatus.planted) CropStatus get status; bool get aiInsightsEnabled; String? get notes;
/// Create a copy of Crop
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CropCopyWith<Crop> get copyWith => _$CropCopyWithImpl<Crop>(this as Crop, _$identity);

  /// Serializes this Crop to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Crop&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.variety, variety) || other.variety == variety)&&(identical(other.fieldLocation, fieldLocation) || other.fieldLocation == fieldLocation)&&(identical(other.fieldSizeAcres, fieldSizeAcres) || other.fieldSizeAcres == fieldSizeAcres)&&(identical(other.plantingDate, plantingDate) || other.plantingDate == plantingDate)&&(identical(other.expectedHarvestDate, expectedHarvestDate) || other.expectedHarvestDate == expectedHarvestDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.aiInsightsEnabled, aiInsightsEnabled) || other.aiInsightsEnabled == aiInsightsEnabled)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,variety,fieldLocation,fieldSizeAcres,plantingDate,expectedHarvestDate,status,aiInsightsEnabled,notes);

@override
String toString() {
  return 'Crop(id: $id, name: $name, variety: $variety, fieldLocation: $fieldLocation, fieldSizeAcres: $fieldSizeAcres, plantingDate: $plantingDate, expectedHarvestDate: $expectedHarvestDate, status: $status, aiInsightsEnabled: $aiInsightsEnabled, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $CropCopyWith<$Res>  {
  factory $CropCopyWith(Crop value, $Res Function(Crop) _then) = _$CropCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? variety, String? fieldLocation, double? fieldSizeAcres,@DateOnlyConverter() DateTime plantingDate,@NullableDateOnlyConverter() DateTime? expectedHarvestDate,@JsonKey(unknownEnumValue: CropStatus.planted) CropStatus status, bool aiInsightsEnabled, String? notes
});




}
/// @nodoc
class _$CropCopyWithImpl<$Res>
    implements $CropCopyWith<$Res> {
  _$CropCopyWithImpl(this._self, this._then);

  final Crop _self;
  final $Res Function(Crop) _then;

/// Create a copy of Crop
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? variety = freezed,Object? fieldLocation = freezed,Object? fieldSizeAcres = freezed,Object? plantingDate = null,Object? expectedHarvestDate = freezed,Object? status = null,Object? aiInsightsEnabled = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,variety: freezed == variety ? _self.variety : variety // ignore: cast_nullable_to_non_nullable
as String?,fieldLocation: freezed == fieldLocation ? _self.fieldLocation : fieldLocation // ignore: cast_nullable_to_non_nullable
as String?,fieldSizeAcres: freezed == fieldSizeAcres ? _self.fieldSizeAcres : fieldSizeAcres // ignore: cast_nullable_to_non_nullable
as double?,plantingDate: null == plantingDate ? _self.plantingDate : plantingDate // ignore: cast_nullable_to_non_nullable
as DateTime,expectedHarvestDate: freezed == expectedHarvestDate ? _self.expectedHarvestDate : expectedHarvestDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CropStatus,aiInsightsEnabled: null == aiInsightsEnabled ? _self.aiInsightsEnabled : aiInsightsEnabled // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Crop].
extension CropPatterns on Crop {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Crop value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Crop() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Crop value)  $default,){
final _that = this;
switch (_that) {
case _Crop():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Crop value)?  $default,){
final _that = this;
switch (_that) {
case _Crop() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? variety,  String? fieldLocation,  double? fieldSizeAcres, @DateOnlyConverter()  DateTime plantingDate, @NullableDateOnlyConverter()  DateTime? expectedHarvestDate, @JsonKey(unknownEnumValue: CropStatus.planted)  CropStatus status,  bool aiInsightsEnabled,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Crop() when $default != null:
return $default(_that.id,_that.name,_that.variety,_that.fieldLocation,_that.fieldSizeAcres,_that.plantingDate,_that.expectedHarvestDate,_that.status,_that.aiInsightsEnabled,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? variety,  String? fieldLocation,  double? fieldSizeAcres, @DateOnlyConverter()  DateTime plantingDate, @NullableDateOnlyConverter()  DateTime? expectedHarvestDate, @JsonKey(unknownEnumValue: CropStatus.planted)  CropStatus status,  bool aiInsightsEnabled,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _Crop():
return $default(_that.id,_that.name,_that.variety,_that.fieldLocation,_that.fieldSizeAcres,_that.plantingDate,_that.expectedHarvestDate,_that.status,_that.aiInsightsEnabled,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? variety,  String? fieldLocation,  double? fieldSizeAcres, @DateOnlyConverter()  DateTime plantingDate, @NullableDateOnlyConverter()  DateTime? expectedHarvestDate, @JsonKey(unknownEnumValue: CropStatus.planted)  CropStatus status,  bool aiInsightsEnabled,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _Crop() when $default != null:
return $default(_that.id,_that.name,_that.variety,_that.fieldLocation,_that.fieldSizeAcres,_that.plantingDate,_that.expectedHarvestDate,_that.status,_that.aiInsightsEnabled,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Crop implements Crop {
  const _Crop({required this.id, required this.name, this.variety, this.fieldLocation, this.fieldSizeAcres, @DateOnlyConverter() required this.plantingDate, @NullableDateOnlyConverter() this.expectedHarvestDate, @JsonKey(unknownEnumValue: CropStatus.planted) this.status = CropStatus.planted, this.aiInsightsEnabled = true, this.notes});
  factory _Crop.fromJson(Map<String, dynamic> json) => _$CropFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? variety;
@override final  String? fieldLocation;
@override final  double? fieldSizeAcres;
@override@DateOnlyConverter() final  DateTime plantingDate;
@override@NullableDateOnlyConverter() final  DateTime? expectedHarvestDate;
@override@JsonKey(unknownEnumValue: CropStatus.planted) final  CropStatus status;
@override@JsonKey() final  bool aiInsightsEnabled;
@override final  String? notes;

/// Create a copy of Crop
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CropCopyWith<_Crop> get copyWith => __$CropCopyWithImpl<_Crop>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CropToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Crop&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.variety, variety) || other.variety == variety)&&(identical(other.fieldLocation, fieldLocation) || other.fieldLocation == fieldLocation)&&(identical(other.fieldSizeAcres, fieldSizeAcres) || other.fieldSizeAcres == fieldSizeAcres)&&(identical(other.plantingDate, plantingDate) || other.plantingDate == plantingDate)&&(identical(other.expectedHarvestDate, expectedHarvestDate) || other.expectedHarvestDate == expectedHarvestDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.aiInsightsEnabled, aiInsightsEnabled) || other.aiInsightsEnabled == aiInsightsEnabled)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,variety,fieldLocation,fieldSizeAcres,plantingDate,expectedHarvestDate,status,aiInsightsEnabled,notes);

@override
String toString() {
  return 'Crop(id: $id, name: $name, variety: $variety, fieldLocation: $fieldLocation, fieldSizeAcres: $fieldSizeAcres, plantingDate: $plantingDate, expectedHarvestDate: $expectedHarvestDate, status: $status, aiInsightsEnabled: $aiInsightsEnabled, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$CropCopyWith<$Res> implements $CropCopyWith<$Res> {
  factory _$CropCopyWith(_Crop value, $Res Function(_Crop) _then) = __$CropCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? variety, String? fieldLocation, double? fieldSizeAcres,@DateOnlyConverter() DateTime plantingDate,@NullableDateOnlyConverter() DateTime? expectedHarvestDate,@JsonKey(unknownEnumValue: CropStatus.planted) CropStatus status, bool aiInsightsEnabled, String? notes
});




}
/// @nodoc
class __$CropCopyWithImpl<$Res>
    implements _$CropCopyWith<$Res> {
  __$CropCopyWithImpl(this._self, this._then);

  final _Crop _self;
  final $Res Function(_Crop) _then;

/// Create a copy of Crop
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? variety = freezed,Object? fieldLocation = freezed,Object? fieldSizeAcres = freezed,Object? plantingDate = null,Object? expectedHarvestDate = freezed,Object? status = null,Object? aiInsightsEnabled = null,Object? notes = freezed,}) {
  return _then(_Crop(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,variety: freezed == variety ? _self.variety : variety // ignore: cast_nullable_to_non_nullable
as String?,fieldLocation: freezed == fieldLocation ? _self.fieldLocation : fieldLocation // ignore: cast_nullable_to_non_nullable
as String?,fieldSizeAcres: freezed == fieldSizeAcres ? _self.fieldSizeAcres : fieldSizeAcres // ignore: cast_nullable_to_non_nullable
as double?,plantingDate: null == plantingDate ? _self.plantingDate : plantingDate // ignore: cast_nullable_to_non_nullable
as DateTime,expectedHarvestDate: freezed == expectedHarvestDate ? _self.expectedHarvestDate : expectedHarvestDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CropStatus,aiInsightsEnabled: null == aiInsightsEnabled ? _self.aiInsightsEnabled : aiInsightsEnabled // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProfitLoss {

 int get cropId; String get cropName; double get totalExpenses; double get totalRevenue; double get netProfit; String get result;
/// Create a copy of ProfitLoss
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfitLossCopyWith<ProfitLoss> get copyWith => _$ProfitLossCopyWithImpl<ProfitLoss>(this as ProfitLoss, _$identity);

  /// Serializes this ProfitLoss to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfitLoss&&(identical(other.cropId, cropId) || other.cropId == cropId)&&(identical(other.cropName, cropName) || other.cropName == cropName)&&(identical(other.totalExpenses, totalExpenses) || other.totalExpenses == totalExpenses)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.netProfit, netProfit) || other.netProfit == netProfit)&&(identical(other.result, result) || other.result == result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cropId,cropName,totalExpenses,totalRevenue,netProfit,result);

@override
String toString() {
  return 'ProfitLoss(cropId: $cropId, cropName: $cropName, totalExpenses: $totalExpenses, totalRevenue: $totalRevenue, netProfit: $netProfit, result: $result)';
}


}

/// @nodoc
abstract mixin class $ProfitLossCopyWith<$Res>  {
  factory $ProfitLossCopyWith(ProfitLoss value, $Res Function(ProfitLoss) _then) = _$ProfitLossCopyWithImpl;
@useResult
$Res call({
 int cropId, String cropName, double totalExpenses, double totalRevenue, double netProfit, String result
});




}
/// @nodoc
class _$ProfitLossCopyWithImpl<$Res>
    implements $ProfitLossCopyWith<$Res> {
  _$ProfitLossCopyWithImpl(this._self, this._then);

  final ProfitLoss _self;
  final $Res Function(ProfitLoss) _then;

/// Create a copy of ProfitLoss
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cropId = null,Object? cropName = null,Object? totalExpenses = null,Object? totalRevenue = null,Object? netProfit = null,Object? result = null,}) {
  return _then(_self.copyWith(
cropId: null == cropId ? _self.cropId : cropId // ignore: cast_nullable_to_non_nullable
as int,cropName: null == cropName ? _self.cropName : cropName // ignore: cast_nullable_to_non_nullable
as String,totalExpenses: null == totalExpenses ? _self.totalExpenses : totalExpenses // ignore: cast_nullable_to_non_nullable
as double,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,netProfit: null == netProfit ? _self.netProfit : netProfit // ignore: cast_nullable_to_non_nullable
as double,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfitLoss].
extension ProfitLossPatterns on ProfitLoss {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfitLoss value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfitLoss() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfitLoss value)  $default,){
final _that = this;
switch (_that) {
case _ProfitLoss():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfitLoss value)?  $default,){
final _that = this;
switch (_that) {
case _ProfitLoss() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int cropId,  String cropName,  double totalExpenses,  double totalRevenue,  double netProfit,  String result)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfitLoss() when $default != null:
return $default(_that.cropId,_that.cropName,_that.totalExpenses,_that.totalRevenue,_that.netProfit,_that.result);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int cropId,  String cropName,  double totalExpenses,  double totalRevenue,  double netProfit,  String result)  $default,) {final _that = this;
switch (_that) {
case _ProfitLoss():
return $default(_that.cropId,_that.cropName,_that.totalExpenses,_that.totalRevenue,_that.netProfit,_that.result);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int cropId,  String cropName,  double totalExpenses,  double totalRevenue,  double netProfit,  String result)?  $default,) {final _that = this;
switch (_that) {
case _ProfitLoss() when $default != null:
return $default(_that.cropId,_that.cropName,_that.totalExpenses,_that.totalRevenue,_that.netProfit,_that.result);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfitLoss extends ProfitLoss {
  const _ProfitLoss({required this.cropId, required this.cropName, required this.totalExpenses, required this.totalRevenue, required this.netProfit, required this.result}): super._();
  factory _ProfitLoss.fromJson(Map<String, dynamic> json) => _$ProfitLossFromJson(json);

@override final  int cropId;
@override final  String cropName;
@override final  double totalExpenses;
@override final  double totalRevenue;
@override final  double netProfit;
@override final  String result;

/// Create a copy of ProfitLoss
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfitLossCopyWith<_ProfitLoss> get copyWith => __$ProfitLossCopyWithImpl<_ProfitLoss>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfitLossToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfitLoss&&(identical(other.cropId, cropId) || other.cropId == cropId)&&(identical(other.cropName, cropName) || other.cropName == cropName)&&(identical(other.totalExpenses, totalExpenses) || other.totalExpenses == totalExpenses)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.netProfit, netProfit) || other.netProfit == netProfit)&&(identical(other.result, result) || other.result == result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cropId,cropName,totalExpenses,totalRevenue,netProfit,result);

@override
String toString() {
  return 'ProfitLoss(cropId: $cropId, cropName: $cropName, totalExpenses: $totalExpenses, totalRevenue: $totalRevenue, netProfit: $netProfit, result: $result)';
}


}

/// @nodoc
abstract mixin class _$ProfitLossCopyWith<$Res> implements $ProfitLossCopyWith<$Res> {
  factory _$ProfitLossCopyWith(_ProfitLoss value, $Res Function(_ProfitLoss) _then) = __$ProfitLossCopyWithImpl;
@override @useResult
$Res call({
 int cropId, String cropName, double totalExpenses, double totalRevenue, double netProfit, String result
});




}
/// @nodoc
class __$ProfitLossCopyWithImpl<$Res>
    implements _$ProfitLossCopyWith<$Res> {
  __$ProfitLossCopyWithImpl(this._self, this._then);

  final _ProfitLoss _self;
  final $Res Function(_ProfitLoss) _then;

/// Create a copy of ProfitLoss
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cropId = null,Object? cropName = null,Object? totalExpenses = null,Object? totalRevenue = null,Object? netProfit = null,Object? result = null,}) {
  return _then(_ProfitLoss(
cropId: null == cropId ? _self.cropId : cropId // ignore: cast_nullable_to_non_nullable
as int,cropName: null == cropName ? _self.cropName : cropName // ignore: cast_nullable_to_non_nullable
as String,totalExpenses: null == totalExpenses ? _self.totalExpenses : totalExpenses // ignore: cast_nullable_to_non_nullable
as double,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,netProfit: null == netProfit ? _self.netProfit : netProfit // ignore: cast_nullable_to_non_nullable
as double,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CropInsight {

 int get cropId; String get insights;@NullableLocalDateTimeConverter() DateTime? get generatedAt; bool get freshlyGenerated;
/// Create a copy of CropInsight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CropInsightCopyWith<CropInsight> get copyWith => _$CropInsightCopyWithImpl<CropInsight>(this as CropInsight, _$identity);

  /// Serializes this CropInsight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CropInsight&&(identical(other.cropId, cropId) || other.cropId == cropId)&&(identical(other.insights, insights) || other.insights == insights)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.freshlyGenerated, freshlyGenerated) || other.freshlyGenerated == freshlyGenerated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cropId,insights,generatedAt,freshlyGenerated);

@override
String toString() {
  return 'CropInsight(cropId: $cropId, insights: $insights, generatedAt: $generatedAt, freshlyGenerated: $freshlyGenerated)';
}


}

/// @nodoc
abstract mixin class $CropInsightCopyWith<$Res>  {
  factory $CropInsightCopyWith(CropInsight value, $Res Function(CropInsight) _then) = _$CropInsightCopyWithImpl;
@useResult
$Res call({
 int cropId, String insights,@NullableLocalDateTimeConverter() DateTime? generatedAt, bool freshlyGenerated
});




}
/// @nodoc
class _$CropInsightCopyWithImpl<$Res>
    implements $CropInsightCopyWith<$Res> {
  _$CropInsightCopyWithImpl(this._self, this._then);

  final CropInsight _self;
  final $Res Function(CropInsight) _then;

/// Create a copy of CropInsight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cropId = null,Object? insights = null,Object? generatedAt = freezed,Object? freshlyGenerated = null,}) {
  return _then(_self.copyWith(
cropId: null == cropId ? _self.cropId : cropId // ignore: cast_nullable_to_non_nullable
as int,insights: null == insights ? _self.insights : insights // ignore: cast_nullable_to_non_nullable
as String,generatedAt: freezed == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,freshlyGenerated: null == freshlyGenerated ? _self.freshlyGenerated : freshlyGenerated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CropInsight].
extension CropInsightPatterns on CropInsight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CropInsight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CropInsight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CropInsight value)  $default,){
final _that = this;
switch (_that) {
case _CropInsight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CropInsight value)?  $default,){
final _that = this;
switch (_that) {
case _CropInsight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int cropId,  String insights, @NullableLocalDateTimeConverter()  DateTime? generatedAt,  bool freshlyGenerated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CropInsight() when $default != null:
return $default(_that.cropId,_that.insights,_that.generatedAt,_that.freshlyGenerated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int cropId,  String insights, @NullableLocalDateTimeConverter()  DateTime? generatedAt,  bool freshlyGenerated)  $default,) {final _that = this;
switch (_that) {
case _CropInsight():
return $default(_that.cropId,_that.insights,_that.generatedAt,_that.freshlyGenerated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int cropId,  String insights, @NullableLocalDateTimeConverter()  DateTime? generatedAt,  bool freshlyGenerated)?  $default,) {final _that = this;
switch (_that) {
case _CropInsight() when $default != null:
return $default(_that.cropId,_that.insights,_that.generatedAt,_that.freshlyGenerated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CropInsight implements CropInsight {
  const _CropInsight({required this.cropId, required this.insights, @NullableLocalDateTimeConverter() this.generatedAt, this.freshlyGenerated = false});
  factory _CropInsight.fromJson(Map<String, dynamic> json) => _$CropInsightFromJson(json);

@override final  int cropId;
@override final  String insights;
@override@NullableLocalDateTimeConverter() final  DateTime? generatedAt;
@override@JsonKey() final  bool freshlyGenerated;

/// Create a copy of CropInsight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CropInsightCopyWith<_CropInsight> get copyWith => __$CropInsightCopyWithImpl<_CropInsight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CropInsightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CropInsight&&(identical(other.cropId, cropId) || other.cropId == cropId)&&(identical(other.insights, insights) || other.insights == insights)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt)&&(identical(other.freshlyGenerated, freshlyGenerated) || other.freshlyGenerated == freshlyGenerated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cropId,insights,generatedAt,freshlyGenerated);

@override
String toString() {
  return 'CropInsight(cropId: $cropId, insights: $insights, generatedAt: $generatedAt, freshlyGenerated: $freshlyGenerated)';
}


}

/// @nodoc
abstract mixin class _$CropInsightCopyWith<$Res> implements $CropInsightCopyWith<$Res> {
  factory _$CropInsightCopyWith(_CropInsight value, $Res Function(_CropInsight) _then) = __$CropInsightCopyWithImpl;
@override @useResult
$Res call({
 int cropId, String insights,@NullableLocalDateTimeConverter() DateTime? generatedAt, bool freshlyGenerated
});




}
/// @nodoc
class __$CropInsightCopyWithImpl<$Res>
    implements _$CropInsightCopyWith<$Res> {
  __$CropInsightCopyWithImpl(this._self, this._then);

  final _CropInsight _self;
  final $Res Function(_CropInsight) _then;

/// Create a copy of CropInsight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cropId = null,Object? insights = null,Object? generatedAt = freezed,Object? freshlyGenerated = null,}) {
  return _then(_CropInsight(
cropId: null == cropId ? _self.cropId : cropId // ignore: cast_nullable_to_non_nullable
as int,insights: null == insights ? _self.insights : insights // ignore: cast_nullable_to_non_nullable
as String,generatedAt: freezed == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,freshlyGenerated: null == freshlyGenerated ? _self.freshlyGenerated : freshlyGenerated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
