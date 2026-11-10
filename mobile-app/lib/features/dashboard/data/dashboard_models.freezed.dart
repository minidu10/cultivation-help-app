// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardSummary {

 DashboardTotals get totals; List<CropSummary> get crops; List<Reminder> get dueReminders; List<Reminder> get upcomingReminders;
/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardSummaryCopyWith<DashboardSummary> get copyWith => _$DashboardSummaryCopyWithImpl<DashboardSummary>(this as DashboardSummary, _$identity);

  /// Serializes this DashboardSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardSummary&&(identical(other.totals, totals) || other.totals == totals)&&const DeepCollectionEquality().equals(other.crops, crops)&&const DeepCollectionEquality().equals(other.dueReminders, dueReminders)&&const DeepCollectionEquality().equals(other.upcomingReminders, upcomingReminders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totals,const DeepCollectionEquality().hash(crops),const DeepCollectionEquality().hash(dueReminders),const DeepCollectionEquality().hash(upcomingReminders));

@override
String toString() {
  return 'DashboardSummary(totals: $totals, crops: $crops, dueReminders: $dueReminders, upcomingReminders: $upcomingReminders)';
}


}

/// @nodoc
abstract mixin class $DashboardSummaryCopyWith<$Res>  {
  factory $DashboardSummaryCopyWith(DashboardSummary value, $Res Function(DashboardSummary) _then) = _$DashboardSummaryCopyWithImpl;
@useResult
$Res call({
 DashboardTotals totals, List<CropSummary> crops, List<Reminder> dueReminders, List<Reminder> upcomingReminders
});


$DashboardTotalsCopyWith<$Res> get totals;

}
/// @nodoc
class _$DashboardSummaryCopyWithImpl<$Res>
    implements $DashboardSummaryCopyWith<$Res> {
  _$DashboardSummaryCopyWithImpl(this._self, this._then);

  final DashboardSummary _self;
  final $Res Function(DashboardSummary) _then;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totals = null,Object? crops = null,Object? dueReminders = null,Object? upcomingReminders = null,}) {
  return _then(_self.copyWith(
totals: null == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as DashboardTotals,crops: null == crops ? _self.crops : crops // ignore: cast_nullable_to_non_nullable
as List<CropSummary>,dueReminders: null == dueReminders ? _self.dueReminders : dueReminders // ignore: cast_nullable_to_non_nullable
as List<Reminder>,upcomingReminders: null == upcomingReminders ? _self.upcomingReminders : upcomingReminders // ignore: cast_nullable_to_non_nullable
as List<Reminder>,
  ));
}
/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardTotalsCopyWith<$Res> get totals {
  
  return $DashboardTotalsCopyWith<$Res>(_self.totals, (value) {
    return _then(_self.copyWith(totals: value));
  });
}
}


/// Adds pattern-matching-related methods to [DashboardSummary].
extension DashboardSummaryPatterns on DashboardSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardSummary value)  $default,){
final _that = this;
switch (_that) {
case _DashboardSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DashboardTotals totals,  List<CropSummary> crops,  List<Reminder> dueReminders,  List<Reminder> upcomingReminders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
return $default(_that.totals,_that.crops,_that.dueReminders,_that.upcomingReminders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DashboardTotals totals,  List<CropSummary> crops,  List<Reminder> dueReminders,  List<Reminder> upcomingReminders)  $default,) {final _that = this;
switch (_that) {
case _DashboardSummary():
return $default(_that.totals,_that.crops,_that.dueReminders,_that.upcomingReminders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DashboardTotals totals,  List<CropSummary> crops,  List<Reminder> dueReminders,  List<Reminder> upcomingReminders)?  $default,) {final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
return $default(_that.totals,_that.crops,_that.dueReminders,_that.upcomingReminders);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardSummary implements DashboardSummary {
  const _DashboardSummary({required this.totals, final  List<CropSummary> crops = const [], final  List<Reminder> dueReminders = const [], final  List<Reminder> upcomingReminders = const []}): _crops = crops,_dueReminders = dueReminders,_upcomingReminders = upcomingReminders;
  factory _DashboardSummary.fromJson(Map<String, dynamic> json) => _$DashboardSummaryFromJson(json);

@override final  DashboardTotals totals;
 final  List<CropSummary> _crops;
@override@JsonKey() List<CropSummary> get crops {
  if (_crops is EqualUnmodifiableListView) return _crops;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_crops);
}

 final  List<Reminder> _dueReminders;
@override@JsonKey() List<Reminder> get dueReminders {
  if (_dueReminders is EqualUnmodifiableListView) return _dueReminders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dueReminders);
}

 final  List<Reminder> _upcomingReminders;
@override@JsonKey() List<Reminder> get upcomingReminders {
  if (_upcomingReminders is EqualUnmodifiableListView) return _upcomingReminders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_upcomingReminders);
}


/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardSummaryCopyWith<_DashboardSummary> get copyWith => __$DashboardSummaryCopyWithImpl<_DashboardSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardSummary&&(identical(other.totals, totals) || other.totals == totals)&&const DeepCollectionEquality().equals(other._crops, _crops)&&const DeepCollectionEquality().equals(other._dueReminders, _dueReminders)&&const DeepCollectionEquality().equals(other._upcomingReminders, _upcomingReminders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totals,const DeepCollectionEquality().hash(_crops),const DeepCollectionEquality().hash(_dueReminders),const DeepCollectionEquality().hash(_upcomingReminders));

@override
String toString() {
  return 'DashboardSummary(totals: $totals, crops: $crops, dueReminders: $dueReminders, upcomingReminders: $upcomingReminders)';
}


}

/// @nodoc
abstract mixin class _$DashboardSummaryCopyWith<$Res> implements $DashboardSummaryCopyWith<$Res> {
  factory _$DashboardSummaryCopyWith(_DashboardSummary value, $Res Function(_DashboardSummary) _then) = __$DashboardSummaryCopyWithImpl;
@override @useResult
$Res call({
 DashboardTotals totals, List<CropSummary> crops, List<Reminder> dueReminders, List<Reminder> upcomingReminders
});


@override $DashboardTotalsCopyWith<$Res> get totals;

}
/// @nodoc
class __$DashboardSummaryCopyWithImpl<$Res>
    implements _$DashboardSummaryCopyWith<$Res> {
  __$DashboardSummaryCopyWithImpl(this._self, this._then);

  final _DashboardSummary _self;
  final $Res Function(_DashboardSummary) _then;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totals = null,Object? crops = null,Object? dueReminders = null,Object? upcomingReminders = null,}) {
  return _then(_DashboardSummary(
totals: null == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as DashboardTotals,crops: null == crops ? _self._crops : crops // ignore: cast_nullable_to_non_nullable
as List<CropSummary>,dueReminders: null == dueReminders ? _self._dueReminders : dueReminders // ignore: cast_nullable_to_non_nullable
as List<Reminder>,upcomingReminders: null == upcomingReminders ? _self._upcomingReminders : upcomingReminders // ignore: cast_nullable_to_non_nullable
as List<Reminder>,
  ));
}

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardTotalsCopyWith<$Res> get totals {
  
  return $DashboardTotalsCopyWith<$Res>(_self.totals, (value) {
    return _then(_self.copyWith(totals: value));
  });
}
}


/// @nodoc
mixin _$DashboardTotals {

 double get totalRevenue; double get totalExpenses; double get netProfit; int get activeCrops; int get totalCrops;
/// Create a copy of DashboardTotals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardTotalsCopyWith<DashboardTotals> get copyWith => _$DashboardTotalsCopyWithImpl<DashboardTotals>(this as DashboardTotals, _$identity);

  /// Serializes this DashboardTotals to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardTotals&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalExpenses, totalExpenses) || other.totalExpenses == totalExpenses)&&(identical(other.netProfit, netProfit) || other.netProfit == netProfit)&&(identical(other.activeCrops, activeCrops) || other.activeCrops == activeCrops)&&(identical(other.totalCrops, totalCrops) || other.totalCrops == totalCrops));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalRevenue,totalExpenses,netProfit,activeCrops,totalCrops);

@override
String toString() {
  return 'DashboardTotals(totalRevenue: $totalRevenue, totalExpenses: $totalExpenses, netProfit: $netProfit, activeCrops: $activeCrops, totalCrops: $totalCrops)';
}


}

/// @nodoc
abstract mixin class $DashboardTotalsCopyWith<$Res>  {
  factory $DashboardTotalsCopyWith(DashboardTotals value, $Res Function(DashboardTotals) _then) = _$DashboardTotalsCopyWithImpl;
@useResult
$Res call({
 double totalRevenue, double totalExpenses, double netProfit, int activeCrops, int totalCrops
});




}
/// @nodoc
class _$DashboardTotalsCopyWithImpl<$Res>
    implements $DashboardTotalsCopyWith<$Res> {
  _$DashboardTotalsCopyWithImpl(this._self, this._then);

  final DashboardTotals _self;
  final $Res Function(DashboardTotals) _then;

/// Create a copy of DashboardTotals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalRevenue = null,Object? totalExpenses = null,Object? netProfit = null,Object? activeCrops = null,Object? totalCrops = null,}) {
  return _then(_self.copyWith(
totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalExpenses: null == totalExpenses ? _self.totalExpenses : totalExpenses // ignore: cast_nullable_to_non_nullable
as double,netProfit: null == netProfit ? _self.netProfit : netProfit // ignore: cast_nullable_to_non_nullable
as double,activeCrops: null == activeCrops ? _self.activeCrops : activeCrops // ignore: cast_nullable_to_non_nullable
as int,totalCrops: null == totalCrops ? _self.totalCrops : totalCrops // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardTotals].
extension DashboardTotalsPatterns on DashboardTotals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardTotals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardTotals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardTotals value)  $default,){
final _that = this;
switch (_that) {
case _DashboardTotals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardTotals value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardTotals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalRevenue,  double totalExpenses,  double netProfit,  int activeCrops,  int totalCrops)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardTotals() when $default != null:
return $default(_that.totalRevenue,_that.totalExpenses,_that.netProfit,_that.activeCrops,_that.totalCrops);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalRevenue,  double totalExpenses,  double netProfit,  int activeCrops,  int totalCrops)  $default,) {final _that = this;
switch (_that) {
case _DashboardTotals():
return $default(_that.totalRevenue,_that.totalExpenses,_that.netProfit,_that.activeCrops,_that.totalCrops);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalRevenue,  double totalExpenses,  double netProfit,  int activeCrops,  int totalCrops)?  $default,) {final _that = this;
switch (_that) {
case _DashboardTotals() when $default != null:
return $default(_that.totalRevenue,_that.totalExpenses,_that.netProfit,_that.activeCrops,_that.totalCrops);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardTotals implements DashboardTotals {
  const _DashboardTotals({this.totalRevenue = 0, this.totalExpenses = 0, this.netProfit = 0, this.activeCrops = 0, this.totalCrops = 0});
  factory _DashboardTotals.fromJson(Map<String, dynamic> json) => _$DashboardTotalsFromJson(json);

@override@JsonKey() final  double totalRevenue;
@override@JsonKey() final  double totalExpenses;
@override@JsonKey() final  double netProfit;
@override@JsonKey() final  int activeCrops;
@override@JsonKey() final  int totalCrops;

/// Create a copy of DashboardTotals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardTotalsCopyWith<_DashboardTotals> get copyWith => __$DashboardTotalsCopyWithImpl<_DashboardTotals>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardTotalsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardTotals&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalExpenses, totalExpenses) || other.totalExpenses == totalExpenses)&&(identical(other.netProfit, netProfit) || other.netProfit == netProfit)&&(identical(other.activeCrops, activeCrops) || other.activeCrops == activeCrops)&&(identical(other.totalCrops, totalCrops) || other.totalCrops == totalCrops));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalRevenue,totalExpenses,netProfit,activeCrops,totalCrops);

@override
String toString() {
  return 'DashboardTotals(totalRevenue: $totalRevenue, totalExpenses: $totalExpenses, netProfit: $netProfit, activeCrops: $activeCrops, totalCrops: $totalCrops)';
}


}

/// @nodoc
abstract mixin class _$DashboardTotalsCopyWith<$Res> implements $DashboardTotalsCopyWith<$Res> {
  factory _$DashboardTotalsCopyWith(_DashboardTotals value, $Res Function(_DashboardTotals) _then) = __$DashboardTotalsCopyWithImpl;
@override @useResult
$Res call({
 double totalRevenue, double totalExpenses, double netProfit, int activeCrops, int totalCrops
});




}
/// @nodoc
class __$DashboardTotalsCopyWithImpl<$Res>
    implements _$DashboardTotalsCopyWith<$Res> {
  __$DashboardTotalsCopyWithImpl(this._self, this._then);

  final _DashboardTotals _self;
  final $Res Function(_DashboardTotals) _then;

/// Create a copy of DashboardTotals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalRevenue = null,Object? totalExpenses = null,Object? netProfit = null,Object? activeCrops = null,Object? totalCrops = null,}) {
  return _then(_DashboardTotals(
totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalExpenses: null == totalExpenses ? _self.totalExpenses : totalExpenses // ignore: cast_nullable_to_non_nullable
as double,netProfit: null == netProfit ? _self.netProfit : netProfit // ignore: cast_nullable_to_non_nullable
as double,activeCrops: null == activeCrops ? _self.activeCrops : activeCrops // ignore: cast_nullable_to_non_nullable
as int,totalCrops: null == totalCrops ? _self.totalCrops : totalCrops // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CropSummary {

 int get cropId; String get cropName; String? get variety;@JsonKey(unknownEnumValue: CropStatus.planted) CropStatus get status; String? get fieldLocation; bool get aiInsightsEnabled; double get totalExpenses; double get totalRevenue; double get netProfit; String get result;
/// Create a copy of CropSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CropSummaryCopyWith<CropSummary> get copyWith => _$CropSummaryCopyWithImpl<CropSummary>(this as CropSummary, _$identity);

  /// Serializes this CropSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CropSummary&&(identical(other.cropId, cropId) || other.cropId == cropId)&&(identical(other.cropName, cropName) || other.cropName == cropName)&&(identical(other.variety, variety) || other.variety == variety)&&(identical(other.status, status) || other.status == status)&&(identical(other.fieldLocation, fieldLocation) || other.fieldLocation == fieldLocation)&&(identical(other.aiInsightsEnabled, aiInsightsEnabled) || other.aiInsightsEnabled == aiInsightsEnabled)&&(identical(other.totalExpenses, totalExpenses) || other.totalExpenses == totalExpenses)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.netProfit, netProfit) || other.netProfit == netProfit)&&(identical(other.result, result) || other.result == result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cropId,cropName,variety,status,fieldLocation,aiInsightsEnabled,totalExpenses,totalRevenue,netProfit,result);

@override
String toString() {
  return 'CropSummary(cropId: $cropId, cropName: $cropName, variety: $variety, status: $status, fieldLocation: $fieldLocation, aiInsightsEnabled: $aiInsightsEnabled, totalExpenses: $totalExpenses, totalRevenue: $totalRevenue, netProfit: $netProfit, result: $result)';
}


}

/// @nodoc
abstract mixin class $CropSummaryCopyWith<$Res>  {
  factory $CropSummaryCopyWith(CropSummary value, $Res Function(CropSummary) _then) = _$CropSummaryCopyWithImpl;
@useResult
$Res call({
 int cropId, String cropName, String? variety,@JsonKey(unknownEnumValue: CropStatus.planted) CropStatus status, String? fieldLocation, bool aiInsightsEnabled, double totalExpenses, double totalRevenue, double netProfit, String result
});




}
/// @nodoc
class _$CropSummaryCopyWithImpl<$Res>
    implements $CropSummaryCopyWith<$Res> {
  _$CropSummaryCopyWithImpl(this._self, this._then);

  final CropSummary _self;
  final $Res Function(CropSummary) _then;

/// Create a copy of CropSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cropId = null,Object? cropName = null,Object? variety = freezed,Object? status = null,Object? fieldLocation = freezed,Object? aiInsightsEnabled = null,Object? totalExpenses = null,Object? totalRevenue = null,Object? netProfit = null,Object? result = null,}) {
  return _then(_self.copyWith(
cropId: null == cropId ? _self.cropId : cropId // ignore: cast_nullable_to_non_nullable
as int,cropName: null == cropName ? _self.cropName : cropName // ignore: cast_nullable_to_non_nullable
as String,variety: freezed == variety ? _self.variety : variety // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CropStatus,fieldLocation: freezed == fieldLocation ? _self.fieldLocation : fieldLocation // ignore: cast_nullable_to_non_nullable
as String?,aiInsightsEnabled: null == aiInsightsEnabled ? _self.aiInsightsEnabled : aiInsightsEnabled // ignore: cast_nullable_to_non_nullable
as bool,totalExpenses: null == totalExpenses ? _self.totalExpenses : totalExpenses // ignore: cast_nullable_to_non_nullable
as double,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,netProfit: null == netProfit ? _self.netProfit : netProfit // ignore: cast_nullable_to_non_nullable
as double,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CropSummary].
extension CropSummaryPatterns on CropSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CropSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CropSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CropSummary value)  $default,){
final _that = this;
switch (_that) {
case _CropSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CropSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CropSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int cropId,  String cropName,  String? variety, @JsonKey(unknownEnumValue: CropStatus.planted)  CropStatus status,  String? fieldLocation,  bool aiInsightsEnabled,  double totalExpenses,  double totalRevenue,  double netProfit,  String result)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CropSummary() when $default != null:
return $default(_that.cropId,_that.cropName,_that.variety,_that.status,_that.fieldLocation,_that.aiInsightsEnabled,_that.totalExpenses,_that.totalRevenue,_that.netProfit,_that.result);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int cropId,  String cropName,  String? variety, @JsonKey(unknownEnumValue: CropStatus.planted)  CropStatus status,  String? fieldLocation,  bool aiInsightsEnabled,  double totalExpenses,  double totalRevenue,  double netProfit,  String result)  $default,) {final _that = this;
switch (_that) {
case _CropSummary():
return $default(_that.cropId,_that.cropName,_that.variety,_that.status,_that.fieldLocation,_that.aiInsightsEnabled,_that.totalExpenses,_that.totalRevenue,_that.netProfit,_that.result);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int cropId,  String cropName,  String? variety, @JsonKey(unknownEnumValue: CropStatus.planted)  CropStatus status,  String? fieldLocation,  bool aiInsightsEnabled,  double totalExpenses,  double totalRevenue,  double netProfit,  String result)?  $default,) {final _that = this;
switch (_that) {
case _CropSummary() when $default != null:
return $default(_that.cropId,_that.cropName,_that.variety,_that.status,_that.fieldLocation,_that.aiInsightsEnabled,_that.totalExpenses,_that.totalRevenue,_that.netProfit,_that.result);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CropSummary implements CropSummary {
  const _CropSummary({required this.cropId, required this.cropName, this.variety, @JsonKey(unknownEnumValue: CropStatus.planted) this.status = CropStatus.planted, this.fieldLocation, this.aiInsightsEnabled = true, this.totalExpenses = 0, this.totalRevenue = 0, this.netProfit = 0, this.result = 'PROFIT'});
  factory _CropSummary.fromJson(Map<String, dynamic> json) => _$CropSummaryFromJson(json);

@override final  int cropId;
@override final  String cropName;
@override final  String? variety;
@override@JsonKey(unknownEnumValue: CropStatus.planted) final  CropStatus status;
@override final  String? fieldLocation;
@override@JsonKey() final  bool aiInsightsEnabled;
@override@JsonKey() final  double totalExpenses;
@override@JsonKey() final  double totalRevenue;
@override@JsonKey() final  double netProfit;
@override@JsonKey() final  String result;

/// Create a copy of CropSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CropSummaryCopyWith<_CropSummary> get copyWith => __$CropSummaryCopyWithImpl<_CropSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CropSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CropSummary&&(identical(other.cropId, cropId) || other.cropId == cropId)&&(identical(other.cropName, cropName) || other.cropName == cropName)&&(identical(other.variety, variety) || other.variety == variety)&&(identical(other.status, status) || other.status == status)&&(identical(other.fieldLocation, fieldLocation) || other.fieldLocation == fieldLocation)&&(identical(other.aiInsightsEnabled, aiInsightsEnabled) || other.aiInsightsEnabled == aiInsightsEnabled)&&(identical(other.totalExpenses, totalExpenses) || other.totalExpenses == totalExpenses)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.netProfit, netProfit) || other.netProfit == netProfit)&&(identical(other.result, result) || other.result == result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cropId,cropName,variety,status,fieldLocation,aiInsightsEnabled,totalExpenses,totalRevenue,netProfit,result);

@override
String toString() {
  return 'CropSummary(cropId: $cropId, cropName: $cropName, variety: $variety, status: $status, fieldLocation: $fieldLocation, aiInsightsEnabled: $aiInsightsEnabled, totalExpenses: $totalExpenses, totalRevenue: $totalRevenue, netProfit: $netProfit, result: $result)';
}


}

/// @nodoc
abstract mixin class _$CropSummaryCopyWith<$Res> implements $CropSummaryCopyWith<$Res> {
  factory _$CropSummaryCopyWith(_CropSummary value, $Res Function(_CropSummary) _then) = __$CropSummaryCopyWithImpl;
@override @useResult
$Res call({
 int cropId, String cropName, String? variety,@JsonKey(unknownEnumValue: CropStatus.planted) CropStatus status, String? fieldLocation, bool aiInsightsEnabled, double totalExpenses, double totalRevenue, double netProfit, String result
});




}
/// @nodoc
class __$CropSummaryCopyWithImpl<$Res>
    implements _$CropSummaryCopyWith<$Res> {
  __$CropSummaryCopyWithImpl(this._self, this._then);

  final _CropSummary _self;
  final $Res Function(_CropSummary) _then;

/// Create a copy of CropSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cropId = null,Object? cropName = null,Object? variety = freezed,Object? status = null,Object? fieldLocation = freezed,Object? aiInsightsEnabled = null,Object? totalExpenses = null,Object? totalRevenue = null,Object? netProfit = null,Object? result = null,}) {
  return _then(_CropSummary(
cropId: null == cropId ? _self.cropId : cropId // ignore: cast_nullable_to_non_nullable
as int,cropName: null == cropName ? _self.cropName : cropName // ignore: cast_nullable_to_non_nullable
as String,variety: freezed == variety ? _self.variety : variety // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CropStatus,fieldLocation: freezed == fieldLocation ? _self.fieldLocation : fieldLocation // ignore: cast_nullable_to_non_nullable
as String?,aiInsightsEnabled: null == aiInsightsEnabled ? _self.aiInsightsEnabled : aiInsightsEnabled // ignore: cast_nullable_to_non_nullable
as bool,totalExpenses: null == totalExpenses ? _self.totalExpenses : totalExpenses // ignore: cast_nullable_to_non_nullable
as double,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,netProfit: null == netProfit ? _self.netProfit : netProfit // ignore: cast_nullable_to_non_nullable
as double,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
