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
mixin _$Forecast {

 String? get location; List<ForecastItem> get items;
/// Create a copy of Forecast
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForecastCopyWith<Forecast> get copyWith => _$ForecastCopyWithImpl<Forecast>(this as Forecast, _$identity);

  /// Serializes this Forecast to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Forecast&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,location,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'Forecast(location: $location, items: $items)';
}


}

/// @nodoc
abstract mixin class $ForecastCopyWith<$Res>  {
  factory $ForecastCopyWith(Forecast value, $Res Function(Forecast) _then) = _$ForecastCopyWithImpl;
@useResult
$Res call({
 String? location, List<ForecastItem> items
});




}
/// @nodoc
class _$ForecastCopyWithImpl<$Res>
    implements $ForecastCopyWith<$Res> {
  _$ForecastCopyWithImpl(this._self, this._then);

  final Forecast _self;
  final $Res Function(Forecast) _then;

/// Create a copy of Forecast
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? location = freezed,Object? items = null,}) {
  return _then(_self.copyWith(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ForecastItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [Forecast].
extension ForecastPatterns on Forecast {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Forecast value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Forecast() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Forecast value)  $default,){
final _that = this;
switch (_that) {
case _Forecast():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Forecast value)?  $default,){
final _that = this;
switch (_that) {
case _Forecast() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? location,  List<ForecastItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Forecast() when $default != null:
return $default(_that.location,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? location,  List<ForecastItem> items)  $default,) {final _that = this;
switch (_that) {
case _Forecast():
return $default(_that.location,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? location,  List<ForecastItem> items)?  $default,) {final _that = this;
switch (_that) {
case _Forecast() when $default != null:
return $default(_that.location,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Forecast implements Forecast {
  const _Forecast({this.location, final  List<ForecastItem> items = const []}): _items = items;
  factory _Forecast.fromJson(Map<String, dynamic> json) => _$ForecastFromJson(json);

@override final  String? location;
 final  List<ForecastItem> _items;
@override@JsonKey() List<ForecastItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of Forecast
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForecastCopyWith<_Forecast> get copyWith => __$ForecastCopyWithImpl<_Forecast>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ForecastToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Forecast&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,location,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'Forecast(location: $location, items: $items)';
}


}

/// @nodoc
abstract mixin class _$ForecastCopyWith<$Res> implements $ForecastCopyWith<$Res> {
  factory _$ForecastCopyWith(_Forecast value, $Res Function(_Forecast) _then) = __$ForecastCopyWithImpl;
@override @useResult
$Res call({
 String? location, List<ForecastItem> items
});




}
/// @nodoc
class __$ForecastCopyWithImpl<$Res>
    implements _$ForecastCopyWith<$Res> {
  __$ForecastCopyWithImpl(this._self, this._then);

  final _Forecast _self;
  final $Res Function(_Forecast) _then;

/// Create a copy of Forecast
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? location = freezed,Object? items = null,}) {
  return _then(_Forecast(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ForecastItem>,
  ));
}


}


/// @nodoc
mixin _$ForecastItem {

/// OpenWeather's "2026-05-10 09:00:00", in UTC.
 String? get dateTime; double? get temperatureC; int? get humidity; int get rainChancePercent; String? get description; String? get iconUrl;
/// Create a copy of ForecastItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForecastItemCopyWith<ForecastItem> get copyWith => _$ForecastItemCopyWithImpl<ForecastItem>(this as ForecastItem, _$identity);

  /// Serializes this ForecastItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForecastItem&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC)&&(identical(other.humidity, humidity) || other.humidity == humidity)&&(identical(other.rainChancePercent, rainChancePercent) || other.rainChancePercent == rainChancePercent)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dateTime,temperatureC,humidity,rainChancePercent,description,iconUrl);

@override
String toString() {
  return 'ForecastItem(dateTime: $dateTime, temperatureC: $temperatureC, humidity: $humidity, rainChancePercent: $rainChancePercent, description: $description, iconUrl: $iconUrl)';
}


}

/// @nodoc
abstract mixin class $ForecastItemCopyWith<$Res>  {
  factory $ForecastItemCopyWith(ForecastItem value, $Res Function(ForecastItem) _then) = _$ForecastItemCopyWithImpl;
@useResult
$Res call({
 String? dateTime, double? temperatureC, int? humidity, int rainChancePercent, String? description, String? iconUrl
});




}
/// @nodoc
class _$ForecastItemCopyWithImpl<$Res>
    implements $ForecastItemCopyWith<$Res> {
  _$ForecastItemCopyWithImpl(this._self, this._then);

  final ForecastItem _self;
  final $Res Function(ForecastItem) _then;

/// Create a copy of ForecastItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dateTime = freezed,Object? temperatureC = freezed,Object? humidity = freezed,Object? rainChancePercent = null,Object? description = freezed,Object? iconUrl = freezed,}) {
  return _then(_self.copyWith(
dateTime: freezed == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as String?,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as double?,humidity: freezed == humidity ? _self.humidity : humidity // ignore: cast_nullable_to_non_nullable
as int?,rainChancePercent: null == rainChancePercent ? _self.rainChancePercent : rainChancePercent // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ForecastItem].
extension ForecastItemPatterns on ForecastItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForecastItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForecastItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForecastItem value)  $default,){
final _that = this;
switch (_that) {
case _ForecastItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForecastItem value)?  $default,){
final _that = this;
switch (_that) {
case _ForecastItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? dateTime,  double? temperatureC,  int? humidity,  int rainChancePercent,  String? description,  String? iconUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForecastItem() when $default != null:
return $default(_that.dateTime,_that.temperatureC,_that.humidity,_that.rainChancePercent,_that.description,_that.iconUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? dateTime,  double? temperatureC,  int? humidity,  int rainChancePercent,  String? description,  String? iconUrl)  $default,) {final _that = this;
switch (_that) {
case _ForecastItem():
return $default(_that.dateTime,_that.temperatureC,_that.humidity,_that.rainChancePercent,_that.description,_that.iconUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? dateTime,  double? temperatureC,  int? humidity,  int rainChancePercent,  String? description,  String? iconUrl)?  $default,) {final _that = this;
switch (_that) {
case _ForecastItem() when $default != null:
return $default(_that.dateTime,_that.temperatureC,_that.humidity,_that.rainChancePercent,_that.description,_that.iconUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ForecastItem implements ForecastItem {
  const _ForecastItem({this.dateTime, this.temperatureC, this.humidity, this.rainChancePercent = 0, this.description, this.iconUrl});
  factory _ForecastItem.fromJson(Map<String, dynamic> json) => _$ForecastItemFromJson(json);

/// OpenWeather's "2026-05-10 09:00:00", in UTC.
@override final  String? dateTime;
@override final  double? temperatureC;
@override final  int? humidity;
@override@JsonKey() final  int rainChancePercent;
@override final  String? description;
@override final  String? iconUrl;

/// Create a copy of ForecastItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForecastItemCopyWith<_ForecastItem> get copyWith => __$ForecastItemCopyWithImpl<_ForecastItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ForecastItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForecastItem&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC)&&(identical(other.humidity, humidity) || other.humidity == humidity)&&(identical(other.rainChancePercent, rainChancePercent) || other.rainChancePercent == rainChancePercent)&&(identical(other.description, description) || other.description == description)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,dateTime,temperatureC,humidity,rainChancePercent,description,iconUrl);

@override
String toString() {
  return 'ForecastItem(dateTime: $dateTime, temperatureC: $temperatureC, humidity: $humidity, rainChancePercent: $rainChancePercent, description: $description, iconUrl: $iconUrl)';
}


}

/// @nodoc
abstract mixin class _$ForecastItemCopyWith<$Res> implements $ForecastItemCopyWith<$Res> {
  factory _$ForecastItemCopyWith(_ForecastItem value, $Res Function(_ForecastItem) _then) = __$ForecastItemCopyWithImpl;
@override @useResult
$Res call({
 String? dateTime, double? temperatureC, int? humidity, int rainChancePercent, String? description, String? iconUrl
});




}
/// @nodoc
class __$ForecastItemCopyWithImpl<$Res>
    implements _$ForecastItemCopyWith<$Res> {
  __$ForecastItemCopyWithImpl(this._self, this._then);

  final _ForecastItem _self;
  final $Res Function(_ForecastItem) _then;

/// Create a copy of ForecastItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dateTime = freezed,Object? temperatureC = freezed,Object? humidity = freezed,Object? rainChancePercent = null,Object? description = freezed,Object? iconUrl = freezed,}) {
  return _then(_ForecastItem(
dateTime: freezed == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as String?,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as double?,humidity: freezed == humidity ? _self.humidity : humidity // ignore: cast_nullable_to_non_nullable
as int?,rainChancePercent: null == rainChancePercent ? _self.rainChancePercent : rainChancePercent // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
