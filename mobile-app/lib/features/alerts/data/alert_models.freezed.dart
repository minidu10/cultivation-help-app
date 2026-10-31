// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeatherAlert {

@JsonKey(unknownEnumValue: AlertType.unknown) AlertType get type;@JsonKey(unknownEnumValue: AlertSeverity.medium) AlertSeverity get severity; int? get cropId; String get cropName; int? get reminderId; String? get reminderTitle;@NullableLocalDateTimeConverter() DateTime? get reminderAt; String get location;@DateOnlyConverter() DateTime get date; int get rainChancePercent; double get rainMm; double get windSpeed; double get maxTempC;@NullableLocalDateTimeConverter() DateTime? get suggestedAt; String get message;
/// Create a copy of WeatherAlert
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeatherAlertCopyWith<WeatherAlert> get copyWith => _$WeatherAlertCopyWithImpl<WeatherAlert>(this as WeatherAlert, _$identity);

  /// Serializes this WeatherAlert to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeatherAlert&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.cropId, cropId) || other.cropId == cropId)&&(identical(other.cropName, cropName) || other.cropName == cropName)&&(identical(other.reminderId, reminderId) || other.reminderId == reminderId)&&(identical(other.reminderTitle, reminderTitle) || other.reminderTitle == reminderTitle)&&(identical(other.reminderAt, reminderAt) || other.reminderAt == reminderAt)&&(identical(other.location, location) || other.location == location)&&(identical(other.date, date) || other.date == date)&&(identical(other.rainChancePercent, rainChancePercent) || other.rainChancePercent == rainChancePercent)&&(identical(other.rainMm, rainMm) || other.rainMm == rainMm)&&(identical(other.windSpeed, windSpeed) || other.windSpeed == windSpeed)&&(identical(other.maxTempC, maxTempC) || other.maxTempC == maxTempC)&&(identical(other.suggestedAt, suggestedAt) || other.suggestedAt == suggestedAt)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,severity,cropId,cropName,reminderId,reminderTitle,reminderAt,location,date,rainChancePercent,rainMm,windSpeed,maxTempC,suggestedAt,message);

@override
String toString() {
  return 'WeatherAlert(type: $type, severity: $severity, cropId: $cropId, cropName: $cropName, reminderId: $reminderId, reminderTitle: $reminderTitle, reminderAt: $reminderAt, location: $location, date: $date, rainChancePercent: $rainChancePercent, rainMm: $rainMm, windSpeed: $windSpeed, maxTempC: $maxTempC, suggestedAt: $suggestedAt, message: $message)';
}


}

/// @nodoc
abstract mixin class $WeatherAlertCopyWith<$Res>  {
  factory $WeatherAlertCopyWith(WeatherAlert value, $Res Function(WeatherAlert) _then) = _$WeatherAlertCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: AlertType.unknown) AlertType type,@JsonKey(unknownEnumValue: AlertSeverity.medium) AlertSeverity severity, int? cropId, String cropName, int? reminderId, String? reminderTitle,@NullableLocalDateTimeConverter() DateTime? reminderAt, String location,@DateOnlyConverter() DateTime date, int rainChancePercent, double rainMm, double windSpeed, double maxTempC,@NullableLocalDateTimeConverter() DateTime? suggestedAt, String message
});




}
/// @nodoc
class _$WeatherAlertCopyWithImpl<$Res>
    implements $WeatherAlertCopyWith<$Res> {
  _$WeatherAlertCopyWithImpl(this._self, this._then);

  final WeatherAlert _self;
  final $Res Function(WeatherAlert) _then;

/// Create a copy of WeatherAlert
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? severity = null,Object? cropId = freezed,Object? cropName = null,Object? reminderId = freezed,Object? reminderTitle = freezed,Object? reminderAt = freezed,Object? location = null,Object? date = null,Object? rainChancePercent = null,Object? rainMm = null,Object? windSpeed = null,Object? maxTempC = null,Object? suggestedAt = freezed,Object? message = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AlertType,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as AlertSeverity,cropId: freezed == cropId ? _self.cropId : cropId // ignore: cast_nullable_to_non_nullable
as int?,cropName: null == cropName ? _self.cropName : cropName // ignore: cast_nullable_to_non_nullable
as String,reminderId: freezed == reminderId ? _self.reminderId : reminderId // ignore: cast_nullable_to_non_nullable
as int?,reminderTitle: freezed == reminderTitle ? _self.reminderTitle : reminderTitle // ignore: cast_nullable_to_non_nullable
as String?,reminderAt: freezed == reminderAt ? _self.reminderAt : reminderAt // ignore: cast_nullable_to_non_nullable
as DateTime?,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,rainChancePercent: null == rainChancePercent ? _self.rainChancePercent : rainChancePercent // ignore: cast_nullable_to_non_nullable
as int,rainMm: null == rainMm ? _self.rainMm : rainMm // ignore: cast_nullable_to_non_nullable
as double,windSpeed: null == windSpeed ? _self.windSpeed : windSpeed // ignore: cast_nullable_to_non_nullable
as double,maxTempC: null == maxTempC ? _self.maxTempC : maxTempC // ignore: cast_nullable_to_non_nullable
as double,suggestedAt: freezed == suggestedAt ? _self.suggestedAt : suggestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WeatherAlert].
extension WeatherAlertPatterns on WeatherAlert {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeatherAlert value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeatherAlert() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeatherAlert value)  $default,){
final _that = this;
switch (_that) {
case _WeatherAlert():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeatherAlert value)?  $default,){
final _that = this;
switch (_that) {
case _WeatherAlert() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: AlertType.unknown)  AlertType type, @JsonKey(unknownEnumValue: AlertSeverity.medium)  AlertSeverity severity,  int? cropId,  String cropName,  int? reminderId,  String? reminderTitle, @NullableLocalDateTimeConverter()  DateTime? reminderAt,  String location, @DateOnlyConverter()  DateTime date,  int rainChancePercent,  double rainMm,  double windSpeed,  double maxTempC, @NullableLocalDateTimeConverter()  DateTime? suggestedAt,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeatherAlert() when $default != null:
return $default(_that.type,_that.severity,_that.cropId,_that.cropName,_that.reminderId,_that.reminderTitle,_that.reminderAt,_that.location,_that.date,_that.rainChancePercent,_that.rainMm,_that.windSpeed,_that.maxTempC,_that.suggestedAt,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: AlertType.unknown)  AlertType type, @JsonKey(unknownEnumValue: AlertSeverity.medium)  AlertSeverity severity,  int? cropId,  String cropName,  int? reminderId,  String? reminderTitle, @NullableLocalDateTimeConverter()  DateTime? reminderAt,  String location, @DateOnlyConverter()  DateTime date,  int rainChancePercent,  double rainMm,  double windSpeed,  double maxTempC, @NullableLocalDateTimeConverter()  DateTime? suggestedAt,  String message)  $default,) {final _that = this;
switch (_that) {
case _WeatherAlert():
return $default(_that.type,_that.severity,_that.cropId,_that.cropName,_that.reminderId,_that.reminderTitle,_that.reminderAt,_that.location,_that.date,_that.rainChancePercent,_that.rainMm,_that.windSpeed,_that.maxTempC,_that.suggestedAt,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: AlertType.unknown)  AlertType type, @JsonKey(unknownEnumValue: AlertSeverity.medium)  AlertSeverity severity,  int? cropId,  String cropName,  int? reminderId,  String? reminderTitle, @NullableLocalDateTimeConverter()  DateTime? reminderAt,  String location, @DateOnlyConverter()  DateTime date,  int rainChancePercent,  double rainMm,  double windSpeed,  double maxTempC, @NullableLocalDateTimeConverter()  DateTime? suggestedAt,  String message)?  $default,) {final _that = this;
switch (_that) {
case _WeatherAlert() when $default != null:
return $default(_that.type,_that.severity,_that.cropId,_that.cropName,_that.reminderId,_that.reminderTitle,_that.reminderAt,_that.location,_that.date,_that.rainChancePercent,_that.rainMm,_that.windSpeed,_that.maxTempC,_that.suggestedAt,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeatherAlert extends WeatherAlert {
  const _WeatherAlert({@JsonKey(unknownEnumValue: AlertType.unknown) required this.type, @JsonKey(unknownEnumValue: AlertSeverity.medium) this.severity = AlertSeverity.medium, this.cropId, this.cropName = '', this.reminderId, this.reminderTitle, @NullableLocalDateTimeConverter() this.reminderAt, this.location = '', @DateOnlyConverter() required this.date, this.rainChancePercent = 0, this.rainMm = 0, this.windSpeed = 0, this.maxTempC = 0, @NullableLocalDateTimeConverter() this.suggestedAt, this.message = ''}): super._();
  factory _WeatherAlert.fromJson(Map<String, dynamic> json) => _$WeatherAlertFromJson(json);

@override@JsonKey(unknownEnumValue: AlertType.unknown) final  AlertType type;
@override@JsonKey(unknownEnumValue: AlertSeverity.medium) final  AlertSeverity severity;
@override final  int? cropId;
@override@JsonKey() final  String cropName;
@override final  int? reminderId;
@override final  String? reminderTitle;
@override@NullableLocalDateTimeConverter() final  DateTime? reminderAt;
@override@JsonKey() final  String location;
@override@DateOnlyConverter() final  DateTime date;
@override@JsonKey() final  int rainChancePercent;
@override@JsonKey() final  double rainMm;
@override@JsonKey() final  double windSpeed;
@override@JsonKey() final  double maxTempC;
@override@NullableLocalDateTimeConverter() final  DateTime? suggestedAt;
@override@JsonKey() final  String message;

/// Create a copy of WeatherAlert
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeatherAlertCopyWith<_WeatherAlert> get copyWith => __$WeatherAlertCopyWithImpl<_WeatherAlert>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeatherAlertToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeatherAlert&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.cropId, cropId) || other.cropId == cropId)&&(identical(other.cropName, cropName) || other.cropName == cropName)&&(identical(other.reminderId, reminderId) || other.reminderId == reminderId)&&(identical(other.reminderTitle, reminderTitle) || other.reminderTitle == reminderTitle)&&(identical(other.reminderAt, reminderAt) || other.reminderAt == reminderAt)&&(identical(other.location, location) || other.location == location)&&(identical(other.date, date) || other.date == date)&&(identical(other.rainChancePercent, rainChancePercent) || other.rainChancePercent == rainChancePercent)&&(identical(other.rainMm, rainMm) || other.rainMm == rainMm)&&(identical(other.windSpeed, windSpeed) || other.windSpeed == windSpeed)&&(identical(other.maxTempC, maxTempC) || other.maxTempC == maxTempC)&&(identical(other.suggestedAt, suggestedAt) || other.suggestedAt == suggestedAt)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,severity,cropId,cropName,reminderId,reminderTitle,reminderAt,location,date,rainChancePercent,rainMm,windSpeed,maxTempC,suggestedAt,message);

@override
String toString() {
  return 'WeatherAlert(type: $type, severity: $severity, cropId: $cropId, cropName: $cropName, reminderId: $reminderId, reminderTitle: $reminderTitle, reminderAt: $reminderAt, location: $location, date: $date, rainChancePercent: $rainChancePercent, rainMm: $rainMm, windSpeed: $windSpeed, maxTempC: $maxTempC, suggestedAt: $suggestedAt, message: $message)';
}


}

/// @nodoc
abstract mixin class _$WeatherAlertCopyWith<$Res> implements $WeatherAlertCopyWith<$Res> {
  factory _$WeatherAlertCopyWith(_WeatherAlert value, $Res Function(_WeatherAlert) _then) = __$WeatherAlertCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: AlertType.unknown) AlertType type,@JsonKey(unknownEnumValue: AlertSeverity.medium) AlertSeverity severity, int? cropId, String cropName, int? reminderId, String? reminderTitle,@NullableLocalDateTimeConverter() DateTime? reminderAt, String location,@DateOnlyConverter() DateTime date, int rainChancePercent, double rainMm, double windSpeed, double maxTempC,@NullableLocalDateTimeConverter() DateTime? suggestedAt, String message
});




}
/// @nodoc
class __$WeatherAlertCopyWithImpl<$Res>
    implements _$WeatherAlertCopyWith<$Res> {
  __$WeatherAlertCopyWithImpl(this._self, this._then);

  final _WeatherAlert _self;
  final $Res Function(_WeatherAlert) _then;

/// Create a copy of WeatherAlert
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? severity = null,Object? cropId = freezed,Object? cropName = null,Object? reminderId = freezed,Object? reminderTitle = freezed,Object? reminderAt = freezed,Object? location = null,Object? date = null,Object? rainChancePercent = null,Object? rainMm = null,Object? windSpeed = null,Object? maxTempC = null,Object? suggestedAt = freezed,Object? message = null,}) {
  return _then(_WeatherAlert(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AlertType,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as AlertSeverity,cropId: freezed == cropId ? _self.cropId : cropId // ignore: cast_nullable_to_non_nullable
as int?,cropName: null == cropName ? _self.cropName : cropName // ignore: cast_nullable_to_non_nullable
as String,reminderId: freezed == reminderId ? _self.reminderId : reminderId // ignore: cast_nullable_to_non_nullable
as int?,reminderTitle: freezed == reminderTitle ? _self.reminderTitle : reminderTitle // ignore: cast_nullable_to_non_nullable
as String?,reminderAt: freezed == reminderAt ? _self.reminderAt : reminderAt // ignore: cast_nullable_to_non_nullable
as DateTime?,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,rainChancePercent: null == rainChancePercent ? _self.rainChancePercent : rainChancePercent // ignore: cast_nullable_to_non_nullable
as int,rainMm: null == rainMm ? _self.rainMm : rainMm // ignore: cast_nullable_to_non_nullable
as double,windSpeed: null == windSpeed ? _self.windSpeed : windSpeed // ignore: cast_nullable_to_non_nullable
as double,maxTempC: null == maxTempC ? _self.maxTempC : maxTempC // ignore: cast_nullable_to_non_nullable
as double,suggestedAt: freezed == suggestedAt ? _self.suggestedAt : suggestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
