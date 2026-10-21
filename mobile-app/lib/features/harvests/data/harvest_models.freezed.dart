// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'harvest_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Harvest {

 int get id;@DateOnlyConverter() DateTime get harvestDate; double get quantity;@JsonKey(unknownEnumValue: QuantityUnit.kg) QuantityUnit get unit; double get pricePerUnit; double get totalRevenue; String? get buyerName; String? get notes;
/// Create a copy of Harvest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HarvestCopyWith<Harvest> get copyWith => _$HarvestCopyWithImpl<Harvest>(this as Harvest, _$identity);

  /// Serializes this Harvest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Harvest&&(identical(other.id, id) || other.id == id)&&(identical(other.harvestDate, harvestDate) || other.harvestDate == harvestDate)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.pricePerUnit, pricePerUnit) || other.pricePerUnit == pricePerUnit)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.buyerName, buyerName) || other.buyerName == buyerName)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,harvestDate,quantity,unit,pricePerUnit,totalRevenue,buyerName,notes);

@override
String toString() {
  return 'Harvest(id: $id, harvestDate: $harvestDate, quantity: $quantity, unit: $unit, pricePerUnit: $pricePerUnit, totalRevenue: $totalRevenue, buyerName: $buyerName, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $HarvestCopyWith<$Res>  {
  factory $HarvestCopyWith(Harvest value, $Res Function(Harvest) _then) = _$HarvestCopyWithImpl;
@useResult
$Res call({
 int id,@DateOnlyConverter() DateTime harvestDate, double quantity,@JsonKey(unknownEnumValue: QuantityUnit.kg) QuantityUnit unit, double pricePerUnit, double totalRevenue, String? buyerName, String? notes
});




}
/// @nodoc
class _$HarvestCopyWithImpl<$Res>
    implements $HarvestCopyWith<$Res> {
  _$HarvestCopyWithImpl(this._self, this._then);

  final Harvest _self;
  final $Res Function(Harvest) _then;

/// Create a copy of Harvest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? harvestDate = null,Object? quantity = null,Object? unit = null,Object? pricePerUnit = null,Object? totalRevenue = null,Object? buyerName = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,harvestDate: null == harvestDate ? _self.harvestDate : harvestDate // ignore: cast_nullable_to_non_nullable
as DateTime,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as QuantityUnit,pricePerUnit: null == pricePerUnit ? _self.pricePerUnit : pricePerUnit // ignore: cast_nullable_to_non_nullable
as double,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,buyerName: freezed == buyerName ? _self.buyerName : buyerName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Harvest].
extension HarvestPatterns on Harvest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Harvest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Harvest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Harvest value)  $default,){
final _that = this;
switch (_that) {
case _Harvest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Harvest value)?  $default,){
final _that = this;
switch (_that) {
case _Harvest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @DateOnlyConverter()  DateTime harvestDate,  double quantity, @JsonKey(unknownEnumValue: QuantityUnit.kg)  QuantityUnit unit,  double pricePerUnit,  double totalRevenue,  String? buyerName,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Harvest() when $default != null:
return $default(_that.id,_that.harvestDate,_that.quantity,_that.unit,_that.pricePerUnit,_that.totalRevenue,_that.buyerName,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @DateOnlyConverter()  DateTime harvestDate,  double quantity, @JsonKey(unknownEnumValue: QuantityUnit.kg)  QuantityUnit unit,  double pricePerUnit,  double totalRevenue,  String? buyerName,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _Harvest():
return $default(_that.id,_that.harvestDate,_that.quantity,_that.unit,_that.pricePerUnit,_that.totalRevenue,_that.buyerName,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @DateOnlyConverter()  DateTime harvestDate,  double quantity, @JsonKey(unknownEnumValue: QuantityUnit.kg)  QuantityUnit unit,  double pricePerUnit,  double totalRevenue,  String? buyerName,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _Harvest() when $default != null:
return $default(_that.id,_that.harvestDate,_that.quantity,_that.unit,_that.pricePerUnit,_that.totalRevenue,_that.buyerName,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Harvest implements Harvest {
  const _Harvest({required this.id, @DateOnlyConverter() required this.harvestDate, required this.quantity, @JsonKey(unknownEnumValue: QuantityUnit.kg) required this.unit, required this.pricePerUnit, required this.totalRevenue, this.buyerName, this.notes});
  factory _Harvest.fromJson(Map<String, dynamic> json) => _$HarvestFromJson(json);

@override final  int id;
@override@DateOnlyConverter() final  DateTime harvestDate;
@override final  double quantity;
@override@JsonKey(unknownEnumValue: QuantityUnit.kg) final  QuantityUnit unit;
@override final  double pricePerUnit;
@override final  double totalRevenue;
@override final  String? buyerName;
@override final  String? notes;

/// Create a copy of Harvest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HarvestCopyWith<_Harvest> get copyWith => __$HarvestCopyWithImpl<_Harvest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HarvestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Harvest&&(identical(other.id, id) || other.id == id)&&(identical(other.harvestDate, harvestDate) || other.harvestDate == harvestDate)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.pricePerUnit, pricePerUnit) || other.pricePerUnit == pricePerUnit)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.buyerName, buyerName) || other.buyerName == buyerName)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,harvestDate,quantity,unit,pricePerUnit,totalRevenue,buyerName,notes);

@override
String toString() {
  return 'Harvest(id: $id, harvestDate: $harvestDate, quantity: $quantity, unit: $unit, pricePerUnit: $pricePerUnit, totalRevenue: $totalRevenue, buyerName: $buyerName, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$HarvestCopyWith<$Res> implements $HarvestCopyWith<$Res> {
  factory _$HarvestCopyWith(_Harvest value, $Res Function(_Harvest) _then) = __$HarvestCopyWithImpl;
@override @useResult
$Res call({
 int id,@DateOnlyConverter() DateTime harvestDate, double quantity,@JsonKey(unknownEnumValue: QuantityUnit.kg) QuantityUnit unit, double pricePerUnit, double totalRevenue, String? buyerName, String? notes
});




}
/// @nodoc
class __$HarvestCopyWithImpl<$Res>
    implements _$HarvestCopyWith<$Res> {
  __$HarvestCopyWithImpl(this._self, this._then);

  final _Harvest _self;
  final $Res Function(_Harvest) _then;

/// Create a copy of Harvest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? harvestDate = null,Object? quantity = null,Object? unit = null,Object? pricePerUnit = null,Object? totalRevenue = null,Object? buyerName = freezed,Object? notes = freezed,}) {
  return _then(_Harvest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,harvestDate: null == harvestDate ? _self.harvestDate : harvestDate // ignore: cast_nullable_to_non_nullable
as DateTime,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as QuantityUnit,pricePerUnit: null == pricePerUnit ? _self.pricePerUnit : pricePerUnit // ignore: cast_nullable_to_non_nullable
as double,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,buyerName: freezed == buyerName ? _self.buyerName : buyerName // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
