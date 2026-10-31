// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CurrentWeather {

 String? get location; String? get description; double? get temperatureC; double? get feelsLikeC; int? get humidity; double? get windSpeed; double? get rainMm; String? get iconUrl;
/// Create a copy of CurrentWeather
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentWeatherCopyWith<CurrentWeather> get copyWith => _$CurrentWeatherCopyWithImpl<CurrentWeather>(this as CurrentWeather, _$identity);

  /// Serializes this CurrentWeather to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentWeather&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC)&&(identical(other.feelsLikeC, feelsLikeC) || other.feelsLikeC == feelsLikeC)&&(identical(other.humidity, humidity) || other.humidity == humidity)&&(identical(other.windSpeed, windSpeed) || other.windSpeed == windSpeed)&&(identical(other.rainMm, rainMm) || other.rainMm == rainMm)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,location,description,temperatureC,feelsLikeC,humidity,windSpeed,rainMm,iconUrl);

@override
String toString() {
  return 'CurrentWeather(location: $location, description: $description, temperatureC: $temperatureC, feelsLikeC: $feelsLikeC, humidity: $humidity, windSpeed: $windSpeed, rainMm: $rainMm, iconUrl: $iconUrl)';
}


}

/// @nodoc
abstract mixin class $CurrentWeatherCopyWith<$Res>  {
  factory $CurrentWeatherCopyWith(CurrentWeather value, $Res Function(CurrentWeather) _then) = _$CurrentWeatherCopyWithImpl;
@useResult
$Res call({
 String? location, String? description, double? temperatureC, double? feelsLikeC, int? humidity, double? windSpeed, double? rainMm, String? iconUrl
});




}
/// @nodoc
class _$CurrentWeatherCopyWithImpl<$Res>
    implements $CurrentWeatherCopyWith<$Res> {
  _$CurrentWeatherCopyWithImpl(this._self, this._then);

  final CurrentWeather _self;
  final $Res Function(CurrentWeather) _then;

/// Create a copy of CurrentWeather
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? location = freezed,Object? description = freezed,Object? temperatureC = freezed,Object? feelsLikeC = freezed,Object? humidity = freezed,Object? windSpeed = freezed,Object? rainMm = freezed,Object? iconUrl = freezed,}) {
  return _then(_self.copyWith(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as double?,feelsLikeC: freezed == feelsLikeC ? _self.feelsLikeC : feelsLikeC // ignore: cast_nullable_to_non_nullable
as double?,humidity: freezed == humidity ? _self.humidity : humidity // ignore: cast_nullable_to_non_nullable
as int?,windSpeed: freezed == windSpeed ? _self.windSpeed : windSpeed // ignore: cast_nullable_to_non_nullable
as double?,rainMm: freezed == rainMm ? _self.rainMm : rainMm // ignore: cast_nullable_to_non_nullable
as double?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CurrentWeather].
extension CurrentWeatherPatterns on CurrentWeather {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrentWeather value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrentWeather() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrentWeather value)  $default,){
final _that = this;
switch (_that) {
case _CurrentWeather():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrentWeather value)?  $default,){
final _that = this;
switch (_that) {
case _CurrentWeather() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? location,  String? description,  double? temperatureC,  double? feelsLikeC,  int? humidity,  double? windSpeed,  double? rainMm,  String? iconUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrentWeather() when $default != null:
return $default(_that.location,_that.description,_that.temperatureC,_that.feelsLikeC,_that.humidity,_that.windSpeed,_that.rainMm,_that.iconUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? location,  String? description,  double? temperatureC,  double? feelsLikeC,  int? humidity,  double? windSpeed,  double? rainMm,  String? iconUrl)  $default,) {final _that = this;
switch (_that) {
case _CurrentWeather():
return $default(_that.location,_that.description,_that.temperatureC,_that.feelsLikeC,_that.humidity,_that.windSpeed,_that.rainMm,_that.iconUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? location,  String? description,  double? temperatureC,  double? feelsLikeC,  int? humidity,  double? windSpeed,  double? rainMm,  String? iconUrl)?  $default,) {final _that = this;
switch (_that) {
case _CurrentWeather() when $default != null:
return $default(_that.location,_that.description,_that.temperatureC,_that.feelsLikeC,_that.humidity,_that.windSpeed,_that.rainMm,_that.iconUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CurrentWeather implements CurrentWeather {
  const _CurrentWeather({this.location, this.description, this.temperatureC, this.feelsLikeC, this.humidity, this.windSpeed, this.rainMm, this.iconUrl});
  factory _CurrentWeather.fromJson(Map<String, dynamic> json) => _$CurrentWeatherFromJson(json);

@override final  String? location;
@override final  String? description;
@override final  double? temperatureC;
@override final  double? feelsLikeC;
@override final  int? humidity;
@override final  double? windSpeed;
@override final  double? rainMm;
@override final  String? iconUrl;

/// Create a copy of CurrentWeather
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrentWeatherCopyWith<_CurrentWeather> get copyWith => __$CurrentWeatherCopyWithImpl<_CurrentWeather>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurrentWeatherToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrentWeather&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC)&&(identical(other.feelsLikeC, feelsLikeC) || other.feelsLikeC == feelsLikeC)&&(identical(other.humidity, humidity) || other.humidity == humidity)&&(identical(other.windSpeed, windSpeed) || other.windSpeed == windSpeed)&&(identical(other.rainMm, rainMm) || other.rainMm == rainMm)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,location,description,temperatureC,feelsLikeC,humidity,windSpeed,rainMm,iconUrl);

@override
String toString() {
  return 'CurrentWeather(location: $location, description: $description, temperatureC: $temperatureC, feelsLikeC: $feelsLikeC, humidity: $humidity, windSpeed: $windSpeed, rainMm: $rainMm, iconUrl: $iconUrl)';
}


}

/// @nodoc
abstract mixin class _$CurrentWeatherCopyWith<$Res> implements $CurrentWeatherCopyWith<$Res> {
  factory _$CurrentWeatherCopyWith(_CurrentWeather value, $Res Function(_CurrentWeather) _then) = __$CurrentWeatherCopyWithImpl;
@override @useResult
$Res call({
 String? location, String? description, double? temperatureC, double? feelsLikeC, int? humidity, double? windSpeed, double? rainMm, String? iconUrl
});




}
/// @nodoc
class __$CurrentWeatherCopyWithImpl<$Res>
    implements _$CurrentWeatherCopyWith<$Res> {
  __$CurrentWeatherCopyWithImpl(this._self, this._then);

  final _CurrentWeather _self;
  final $Res Function(_CurrentWeather) _then;

/// Create a copy of CurrentWeather
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? location = freezed,Object? description = freezed,Object? temperatureC = freezed,Object? feelsLikeC = freezed,Object? humidity = freezed,Object? windSpeed = freezed,Object? rainMm = freezed,Object? iconUrl = freezed,}) {
  return _then(_CurrentWeather(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as double?,feelsLikeC: freezed == feelsLikeC ? _self.feelsLikeC : feelsLikeC // ignore: cast_nullable_to_non_nullable
as double?,humidity: freezed == humidity ? _self.humidity : humidity // ignore: cast_nullable_to_non_nullable
as int?,windSpeed: freezed == windSpeed ? _self.windSpeed : windSpeed // ignore: cast_nullable_to_non_nullable
as double?,rainMm: freezed == rainMm ? _self.rainMm : rainMm // ignore: cast_nullable_to_non_nullable
as double?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DailyForecast {

 String? get location; List<ForecastDay> get days;
/// Create a copy of DailyForecast
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyForecastCopyWith<DailyForecast> get copyWith => _$DailyForecastCopyWithImpl<DailyForecast>(this as DailyForecast, _$identity);

  /// Serializes this DailyForecast to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyForecast&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.days, days));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,location,const DeepCollectionEquality().hash(days));

@override
String toString() {
  return 'DailyForecast(location: $location, days: $days)';
}


}

/// @nodoc
abstract mixin class $DailyForecastCopyWith<$Res>  {
  factory $DailyForecastCopyWith(DailyForecast value, $Res Function(DailyForecast) _then) = _$DailyForecastCopyWithImpl;
@useResult
$Res call({
 String? location, List<ForecastDay> days
});




}
/// @nodoc
class _$DailyForecastCopyWithImpl<$Res>
    implements $DailyForecastCopyWith<$Res> {
  _$DailyForecastCopyWithImpl(this._self, this._then);

  final DailyForecast _self;
  final $Res Function(DailyForecast) _then;

/// Create a copy of DailyForecast
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? location = freezed,Object? days = null,}) {
  return _then(_self.copyWith(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<ForecastDay>,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyForecast].
extension DailyForecastPatterns on DailyForecast {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyForecast value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyForecast() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyForecast value)  $default,){
final _that = this;
switch (_that) {
case _DailyForecast():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyForecast value)?  $default,){
final _that = this;
switch (_that) {
case _DailyForecast() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? location,  List<ForecastDay> days)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyForecast() when $default != null:
return $default(_that.location,_that.days);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? location,  List<ForecastDay> days)  $default,) {final _that = this;
switch (_that) {
case _DailyForecast():
return $default(_that.location,_that.days);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? location,  List<ForecastDay> days)?  $default,) {final _that = this;
switch (_that) {
case _DailyForecast() when $default != null:
return $default(_that.location,_that.days);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyForecast implements DailyForecast {
  const _DailyForecast({this.location, final  List<ForecastDay> days = const []}): _days = days;
  factory _DailyForecast.fromJson(Map<String, dynamic> json) => _$DailyForecastFromJson(json);

@override final  String? location;
 final  List<ForecastDay> _days;
@override@JsonKey() List<ForecastDay> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}


/// Create a copy of DailyForecast
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyForecastCopyWith<_DailyForecast> get copyWith => __$DailyForecastCopyWithImpl<_DailyForecast>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyForecastToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyForecast&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other._days, _days));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,location,const DeepCollectionEquality().hash(_days));

@override
String toString() {
  return 'DailyForecast(location: $location, days: $days)';
}


}

/// @nodoc
abstract mixin class _$DailyForecastCopyWith<$Res> implements $DailyForecastCopyWith<$Res> {
  factory _$DailyForecastCopyWith(_DailyForecast value, $Res Function(_DailyForecast) _then) = __$DailyForecastCopyWithImpl;
@override @useResult
$Res call({
 String? location, List<ForecastDay> days
});




}
/// @nodoc
class __$DailyForecastCopyWithImpl<$Res>
    implements _$DailyForecastCopyWith<$Res> {
  __$DailyForecastCopyWithImpl(this._self, this._then);

  final _DailyForecast _self;
  final $Res Function(_DailyForecast) _then;

/// Create a copy of DailyForecast
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? location = freezed,Object? days = null,}) {
  return _then(_DailyForecast(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<ForecastDay>,
  ));
}


}


/// @nodoc
mixin _$ForecastDay {

@DateOnlyConverter() DateTime get date; double get minTempC; double get maxTempC; double get rainMm; int get rainChancePercent; double get maxWindSpeed; String? get description; String? get iconUrl;
/// Create a copy of ForecastDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForecastDayCopyWith<ForecastDay> get copyWith => _$ForecastDayCopyWithImpl<ForecastDay>(this as ForecastDay, _$identity);

  /// Serializes this ForecastDay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForecastDay&&(identical(other.date, date) || other.date == date)&&(identical(other.minTempC, minTempC) || other.minTempC == minTempC)&&(identical(other.maxTempC, maxTempC) || other.maxTempC == maxTempC)&&(identical(other.rainMm, rainMm) || other.rainMm == rainMm)&&(identical(other.rainChancePercent, rainChancePercent) || other.rainChancePercent == rainChancePercent)&&(identical(other.maxWindSpeed, maxWindSpeed) || other.maxWindSpeed == maxWindSpeed)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,minTempC,maxTempC,rainMm,rainChancePercent,maxWindSpeed,description,iconUrl);

@override
String toString() {
  return 'ForecastDay(date: $date, minTempC: $minTempC, maxTempC: $maxTempC, rainMm: $rainMm, rainChancePercent: $rainChancePercent, maxWindSpeed: $maxWindSpeed, description: $description, iconUrl: $iconUrl)';
}


}

/// @nodoc
abstract mixin class $ForecastDayCopyWith<$Res>  {
  factory $ForecastDayCopyWith(ForecastDay value, $Res Function(ForecastDay) _then) = _$ForecastDayCopyWithImpl;
@useResult
$Res call({
@DateOnlyConverter() DateTime date, double minTempC, double maxTempC, double rainMm, int rainChancePercent, double maxWindSpeed, String? description, String? iconUrl
});




}
/// @nodoc
class _$ForecastDayCopyWithImpl<$Res>
    implements $ForecastDayCopyWith<$Res> {
  _$ForecastDayCopyWithImpl(this._self, this._then);

  final ForecastDay _self;
  final $Res Function(ForecastDay) _then;

/// Create a copy of ForecastDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? minTempC = null,Object? maxTempC = null,Object? rainMm = null,Object? rainChancePercent = null,Object? maxWindSpeed = null,Object? description = freezed,Object? iconUrl = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,minTempC: null == minTempC ? _self.minTempC : minTempC // ignore: cast_nullable_to_non_nullable
as double,maxTempC: null == maxTempC ? _self.maxTempC : maxTempC // ignore: cast_nullable_to_non_nullable
as double,rainMm: null == rainMm ? _self.rainMm : rainMm // ignore: cast_nullable_to_non_nullable
as double,rainChancePercent: null == rainChancePercent ? _self.rainChancePercent : rainChancePercent // ignore: cast_nullable_to_non_nullable
as int,maxWindSpeed: null == maxWindSpeed ? _self.maxWindSpeed : maxWindSpeed // ignore: cast_nullable_to_non_nullable
as double,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ForecastDay].
extension ForecastDayPatterns on ForecastDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForecastDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForecastDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForecastDay value)  $default,){
final _that = this;
switch (_that) {
case _ForecastDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForecastDay value)?  $default,){
final _that = this;
switch (_that) {
case _ForecastDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime date,  double minTempC,  double maxTempC,  double rainMm,  int rainChancePercent,  double maxWindSpeed,  String? description,  String? iconUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForecastDay() when $default != null:
return $default(_that.date,_that.minTempC,_that.maxTempC,_that.rainMm,_that.rainChancePercent,_that.maxWindSpeed,_that.description,_that.iconUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@DateOnlyConverter()  DateTime date,  double minTempC,  double maxTempC,  double rainMm,  int rainChancePercent,  double maxWindSpeed,  String? description,  String? iconUrl)  $default,) {final _that = this;
switch (_that) {
case _ForecastDay():
return $default(_that.date,_that.minTempC,_that.maxTempC,_that.rainMm,_that.rainChancePercent,_that.maxWindSpeed,_that.description,_that.iconUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@DateOnlyConverter()  DateTime date,  double minTempC,  double maxTempC,  double rainMm,  int rainChancePercent,  double maxWindSpeed,  String? description,  String? iconUrl)?  $default,) {final _that = this;
switch (_that) {
case _ForecastDay() when $default != null:
return $default(_that.date,_that.minTempC,_that.maxTempC,_that.rainMm,_that.rainChancePercent,_that.maxWindSpeed,_that.description,_that.iconUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ForecastDay implements ForecastDay {
  const _ForecastDay({@DateOnlyConverter() required this.date, this.minTempC = 0, this.maxTempC = 0, this.rainMm = 0, this.rainChancePercent = 0, this.maxWindSpeed = 0, this.description, this.iconUrl});
  factory _ForecastDay.fromJson(Map<String, dynamic> json) => _$ForecastDayFromJson(json);

@override@DateOnlyConverter() final  DateTime date;
@override@JsonKey() final  double minTempC;
@override@JsonKey() final  double maxTempC;
@override@JsonKey() final  double rainMm;
@override@JsonKey() final  int rainChancePercent;
@override@JsonKey() final  double maxWindSpeed;
@override final  String? description;
@override final  String? iconUrl;

/// Create a copy of ForecastDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForecastDayCopyWith<_ForecastDay> get copyWith => __$ForecastDayCopyWithImpl<_ForecastDay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ForecastDayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForecastDay&&(identical(other.date, date) || other.date == date)&&(identical(other.minTempC, minTempC) || other.minTempC == minTempC)&&(identical(other.maxTempC, maxTempC) || other.maxTempC == maxTempC)&&(identical(other.rainMm, rainMm) || other.rainMm == rainMm)&&(identical(other.rainChancePercent, rainChancePercent) || other.rainChancePercent == rainChancePercent)&&(identical(other.maxWindSpeed, maxWindSpeed) || other.maxWindSpeed == maxWindSpeed)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,minTempC,maxTempC,rainMm,rainChancePercent,maxWindSpeed,description,iconUrl);

@override
String toString() {
  return 'ForecastDay(date: $date, minTempC: $minTempC, maxTempC: $maxTempC, rainMm: $rainMm, rainChancePercent: $rainChancePercent, maxWindSpeed: $maxWindSpeed, description: $description, iconUrl: $iconUrl)';
}


}

/// @nodoc
abstract mixin class _$ForecastDayCopyWith<$Res> implements $ForecastDayCopyWith<$Res> {
  factory _$ForecastDayCopyWith(_ForecastDay value, $Res Function(_ForecastDay) _then) = __$ForecastDayCopyWithImpl;
@override @useResult
$Res call({
@DateOnlyConverter() DateTime date, double minTempC, double maxTempC, double rainMm, int rainChancePercent, double maxWindSpeed, String? description, String? iconUrl
});




}
/// @nodoc
class __$ForecastDayCopyWithImpl<$Res>
    implements _$ForecastDayCopyWith<$Res> {
  __$ForecastDayCopyWithImpl(this._self, this._then);

  final _ForecastDay _self;
  final $Res Function(_ForecastDay) _then;

/// Create a copy of ForecastDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? minTempC = null,Object? maxTempC = null,Object? rainMm = null,Object? rainChancePercent = null,Object? maxWindSpeed = null,Object? description = freezed,Object? iconUrl = freezed,}) {
  return _then(_ForecastDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,minTempC: null == minTempC ? _self.minTempC : minTempC // ignore: cast_nullable_to_non_nullable
as double,maxTempC: null == maxTempC ? _self.maxTempC : maxTempC // ignore: cast_nullable_to_non_nullable
as double,rainMm: null == rainMm ? _self.rainMm : rainMm // ignore: cast_nullable_to_non_nullable
as double,rainChancePercent: null == rainChancePercent ? _self.rainChancePercent : rainChancePercent // ignore: cast_nullable_to_non_nullable
as int,maxWindSpeed: null == maxWindSpeed ? _self.maxWindSpeed : maxWindSpeed // ignore: cast_nullable_to_non_nullable
as double,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
