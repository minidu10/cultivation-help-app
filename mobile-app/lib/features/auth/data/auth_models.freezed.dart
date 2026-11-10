// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthSession {

 String get token; String get refreshToken; int get expiresIn; String get email; String get fullName; String? get city; String get themePreference; bool get desktopMode;
/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSessionCopyWith<AuthSession> get copyWith => _$AuthSessionCopyWithImpl<AuthSession>(this as AuthSession, _$identity);

  /// Serializes this AuthSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSession&&(identical(other.token, token) || other.token == token)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.email, email) || other.email == email)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.city, city) || other.city == city)&&(identical(other.themePreference, themePreference) || other.themePreference == themePreference)&&(identical(other.desktopMode, desktopMode) || other.desktopMode == desktopMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,refreshToken,expiresIn,email,fullName,city,themePreference,desktopMode);

@override
String toString() {
  return 'AuthSession(token: $token, refreshToken: $refreshToken, expiresIn: $expiresIn, email: $email, fullName: $fullName, city: $city, themePreference: $themePreference, desktopMode: $desktopMode)';
}


}

/// @nodoc
abstract mixin class $AuthSessionCopyWith<$Res>  {
  factory $AuthSessionCopyWith(AuthSession value, $Res Function(AuthSession) _then) = _$AuthSessionCopyWithImpl;
@useResult
$Res call({
 String token, String refreshToken, int expiresIn, String email, String fullName, String? city, String themePreference, bool desktopMode
});




}
/// @nodoc
class _$AuthSessionCopyWithImpl<$Res>
    implements $AuthSessionCopyWith<$Res> {
  _$AuthSessionCopyWithImpl(this._self, this._then);

  final AuthSession _self;
  final $Res Function(AuthSession) _then;

/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? refreshToken = null,Object? expiresIn = null,Object? email = null,Object? fullName = null,Object? city = freezed,Object? themePreference = null,Object? desktopMode = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,themePreference: null == themePreference ? _self.themePreference : themePreference // ignore: cast_nullable_to_non_nullable
as String,desktopMode: null == desktopMode ? _self.desktopMode : desktopMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthSession].
extension AuthSessionPatterns on AuthSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthSession value)  $default,){
final _that = this;
switch (_that) {
case _AuthSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthSession value)?  $default,){
final _that = this;
switch (_that) {
case _AuthSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  String refreshToken,  int expiresIn,  String email,  String fullName,  String? city,  String themePreference,  bool desktopMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthSession() when $default != null:
return $default(_that.token,_that.refreshToken,_that.expiresIn,_that.email,_that.fullName,_that.city,_that.themePreference,_that.desktopMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  String refreshToken,  int expiresIn,  String email,  String fullName,  String? city,  String themePreference,  bool desktopMode)  $default,) {final _that = this;
switch (_that) {
case _AuthSession():
return $default(_that.token,_that.refreshToken,_that.expiresIn,_that.email,_that.fullName,_that.city,_that.themePreference,_that.desktopMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  String refreshToken,  int expiresIn,  String email,  String fullName,  String? city,  String themePreference,  bool desktopMode)?  $default,) {final _that = this;
switch (_that) {
case _AuthSession() when $default != null:
return $default(_that.token,_that.refreshToken,_that.expiresIn,_that.email,_that.fullName,_that.city,_that.themePreference,_that.desktopMode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthSession implements AuthSession {
  const _AuthSession({required this.token, required this.refreshToken, this.expiresIn = 1800, required this.email, required this.fullName, this.city, this.themePreference = 'LIGHT', this.desktopMode = false});
  factory _AuthSession.fromJson(Map<String, dynamic> json) => _$AuthSessionFromJson(json);

@override final  String token;
@override final  String refreshToken;
@override@JsonKey() final  int expiresIn;
@override final  String email;
@override final  String fullName;
@override final  String? city;
@override@JsonKey() final  String themePreference;
@override@JsonKey() final  bool desktopMode;

/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthSessionCopyWith<_AuthSession> get copyWith => __$AuthSessionCopyWithImpl<_AuthSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthSession&&(identical(other.token, token) || other.token == token)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.email, email) || other.email == email)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.city, city) || other.city == city)&&(identical(other.themePreference, themePreference) || other.themePreference == themePreference)&&(identical(other.desktopMode, desktopMode) || other.desktopMode == desktopMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,refreshToken,expiresIn,email,fullName,city,themePreference,desktopMode);

@override
String toString() {
  return 'AuthSession(token: $token, refreshToken: $refreshToken, expiresIn: $expiresIn, email: $email, fullName: $fullName, city: $city, themePreference: $themePreference, desktopMode: $desktopMode)';
}


}

/// @nodoc
abstract mixin class _$AuthSessionCopyWith<$Res> implements $AuthSessionCopyWith<$Res> {
  factory _$AuthSessionCopyWith(_AuthSession value, $Res Function(_AuthSession) _then) = __$AuthSessionCopyWithImpl;
@override @useResult
$Res call({
 String token, String refreshToken, int expiresIn, String email, String fullName, String? city, String themePreference, bool desktopMode
});




}
/// @nodoc
class __$AuthSessionCopyWithImpl<$Res>
    implements _$AuthSessionCopyWith<$Res> {
  __$AuthSessionCopyWithImpl(this._self, this._then);

  final _AuthSession _self;
  final $Res Function(_AuthSession) _then;

/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? refreshToken = null,Object? expiresIn = null,Object? email = null,Object? fullName = null,Object? city = freezed,Object? themePreference = null,Object? desktopMode = null,}) {
  return _then(_AuthSession(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,themePreference: null == themePreference ? _self.themePreference : themePreference // ignore: cast_nullable_to_non_nullable
as String,desktopMode: null == desktopMode ? _self.desktopMode : desktopMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AuthConfig {

 String? get googleClientId; bool get googleEnabled;
/// Create a copy of AuthConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthConfigCopyWith<AuthConfig> get copyWith => _$AuthConfigCopyWithImpl<AuthConfig>(this as AuthConfig, _$identity);

  /// Serializes this AuthConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthConfig&&(identical(other.googleClientId, googleClientId) || other.googleClientId == googleClientId)&&(identical(other.googleEnabled, googleEnabled) || other.googleEnabled == googleEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,googleClientId,googleEnabled);

@override
String toString() {
  return 'AuthConfig(googleClientId: $googleClientId, googleEnabled: $googleEnabled)';
}


}

/// @nodoc
abstract mixin class $AuthConfigCopyWith<$Res>  {
  factory $AuthConfigCopyWith(AuthConfig value, $Res Function(AuthConfig) _then) = _$AuthConfigCopyWithImpl;
@useResult
$Res call({
 String? googleClientId, bool googleEnabled
});




}
/// @nodoc
class _$AuthConfigCopyWithImpl<$Res>
    implements $AuthConfigCopyWith<$Res> {
  _$AuthConfigCopyWithImpl(this._self, this._then);

  final AuthConfig _self;
  final $Res Function(AuthConfig) _then;

/// Create a copy of AuthConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? googleClientId = freezed,Object? googleEnabled = null,}) {
  return _then(_self.copyWith(
googleClientId: freezed == googleClientId ? _self.googleClientId : googleClientId // ignore: cast_nullable_to_non_nullable
as String?,googleEnabled: null == googleEnabled ? _self.googleEnabled : googleEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthConfig].
extension AuthConfigPatterns on AuthConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthConfig value)  $default,){
final _that = this;
switch (_that) {
case _AuthConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthConfig value)?  $default,){
final _that = this;
switch (_that) {
case _AuthConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? googleClientId,  bool googleEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthConfig() when $default != null:
return $default(_that.googleClientId,_that.googleEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? googleClientId,  bool googleEnabled)  $default,) {final _that = this;
switch (_that) {
case _AuthConfig():
return $default(_that.googleClientId,_that.googleEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? googleClientId,  bool googleEnabled)?  $default,) {final _that = this;
switch (_that) {
case _AuthConfig() when $default != null:
return $default(_that.googleClientId,_that.googleEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthConfig implements AuthConfig {
  const _AuthConfig({this.googleClientId, this.googleEnabled = false});
  factory _AuthConfig.fromJson(Map<String, dynamic> json) => _$AuthConfigFromJson(json);

@override final  String? googleClientId;
@override@JsonKey() final  bool googleEnabled;

/// Create a copy of AuthConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthConfigCopyWith<_AuthConfig> get copyWith => __$AuthConfigCopyWithImpl<_AuthConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthConfig&&(identical(other.googleClientId, googleClientId) || other.googleClientId == googleClientId)&&(identical(other.googleEnabled, googleEnabled) || other.googleEnabled == googleEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,googleClientId,googleEnabled);

@override
String toString() {
  return 'AuthConfig(googleClientId: $googleClientId, googleEnabled: $googleEnabled)';
}


}

/// @nodoc
abstract mixin class _$AuthConfigCopyWith<$Res> implements $AuthConfigCopyWith<$Res> {
  factory _$AuthConfigCopyWith(_AuthConfig value, $Res Function(_AuthConfig) _then) = __$AuthConfigCopyWithImpl;
@override @useResult
$Res call({
 String? googleClientId, bool googleEnabled
});




}
/// @nodoc
class __$AuthConfigCopyWithImpl<$Res>
    implements _$AuthConfigCopyWith<$Res> {
  __$AuthConfigCopyWithImpl(this._self, this._then);

  final _AuthConfig _self;
  final $Res Function(_AuthConfig) _then;

/// Create a copy of AuthConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? googleClientId = freezed,Object? googleEnabled = null,}) {
  return _then(_AuthConfig(
googleClientId: freezed == googleClientId ? _self.googleClientId : googleClientId // ignore: cast_nullable_to_non_nullable
as String?,googleEnabled: null == googleEnabled ? _self.googleEnabled : googleEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
