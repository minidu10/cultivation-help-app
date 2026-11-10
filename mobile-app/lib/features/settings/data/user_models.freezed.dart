// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 int get id; String get fullName; String get email; String? get phone; String? get city; String get themePreference; bool get desktopMode; bool get reminderEmailsEnabled; String get authProvider; bool get hasPassword; bool get googleLinked;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.city, city) || other.city == city)&&(identical(other.themePreference, themePreference) || other.themePreference == themePreference)&&(identical(other.desktopMode, desktopMode) || other.desktopMode == desktopMode)&&(identical(other.reminderEmailsEnabled, reminderEmailsEnabled) || other.reminderEmailsEnabled == reminderEmailsEnabled)&&(identical(other.authProvider, authProvider) || other.authProvider == authProvider)&&(identical(other.hasPassword, hasPassword) || other.hasPassword == hasPassword)&&(identical(other.googleLinked, googleLinked) || other.googleLinked == googleLinked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email,phone,city,themePreference,desktopMode,reminderEmailsEnabled,authProvider,hasPassword,googleLinked);

@override
String toString() {
  return 'UserProfile(id: $id, fullName: $fullName, email: $email, phone: $phone, city: $city, themePreference: $themePreference, desktopMode: $desktopMode, reminderEmailsEnabled: $reminderEmailsEnabled, authProvider: $authProvider, hasPassword: $hasPassword, googleLinked: $googleLinked)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 int id, String fullName, String email, String? phone, String? city, String themePreference, bool desktopMode, bool reminderEmailsEnabled, String authProvider, bool hasPassword, bool googleLinked
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? phone = freezed,Object? city = freezed,Object? themePreference = null,Object? desktopMode = null,Object? reminderEmailsEnabled = null,Object? authProvider = null,Object? hasPassword = null,Object? googleLinked = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,themePreference: null == themePreference ? _self.themePreference : themePreference // ignore: cast_nullable_to_non_nullable
as String,desktopMode: null == desktopMode ? _self.desktopMode : desktopMode // ignore: cast_nullable_to_non_nullable
as bool,reminderEmailsEnabled: null == reminderEmailsEnabled ? _self.reminderEmailsEnabled : reminderEmailsEnabled // ignore: cast_nullable_to_non_nullable
as bool,authProvider: null == authProvider ? _self.authProvider : authProvider // ignore: cast_nullable_to_non_nullable
as String,hasPassword: null == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool,googleLinked: null == googleLinked ? _self.googleLinked : googleLinked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String fullName,  String email,  String? phone,  String? city,  String themePreference,  bool desktopMode,  bool reminderEmailsEnabled,  String authProvider,  bool hasPassword,  bool googleLinked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.phone,_that.city,_that.themePreference,_that.desktopMode,_that.reminderEmailsEnabled,_that.authProvider,_that.hasPassword,_that.googleLinked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String fullName,  String email,  String? phone,  String? city,  String themePreference,  bool desktopMode,  bool reminderEmailsEnabled,  String authProvider,  bool hasPassword,  bool googleLinked)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.id,_that.fullName,_that.email,_that.phone,_that.city,_that.themePreference,_that.desktopMode,_that.reminderEmailsEnabled,_that.authProvider,_that.hasPassword,_that.googleLinked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String fullName,  String email,  String? phone,  String? city,  String themePreference,  bool desktopMode,  bool reminderEmailsEnabled,  String authProvider,  bool hasPassword,  bool googleLinked)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.phone,_that.city,_that.themePreference,_that.desktopMode,_that.reminderEmailsEnabled,_that.authProvider,_that.hasPassword,_that.googleLinked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({required this.id, required this.fullName, required this.email, this.phone, this.city, this.themePreference = 'LIGHT', this.desktopMode = false, this.reminderEmailsEnabled = true, this.authProvider = 'LOCAL', this.hasPassword = true, this.googleLinked = false});
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  int id;
@override final  String fullName;
@override final  String email;
@override final  String? phone;
@override final  String? city;
@override@JsonKey() final  String themePreference;
@override@JsonKey() final  bool desktopMode;
@override@JsonKey() final  bool reminderEmailsEnabled;
@override@JsonKey() final  String authProvider;
@override@JsonKey() final  bool hasPassword;
@override@JsonKey() final  bool googleLinked;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.city, city) || other.city == city)&&(identical(other.themePreference, themePreference) || other.themePreference == themePreference)&&(identical(other.desktopMode, desktopMode) || other.desktopMode == desktopMode)&&(identical(other.reminderEmailsEnabled, reminderEmailsEnabled) || other.reminderEmailsEnabled == reminderEmailsEnabled)&&(identical(other.authProvider, authProvider) || other.authProvider == authProvider)&&(identical(other.hasPassword, hasPassword) || other.hasPassword == hasPassword)&&(identical(other.googleLinked, googleLinked) || other.googleLinked == googleLinked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email,phone,city,themePreference,desktopMode,reminderEmailsEnabled,authProvider,hasPassword,googleLinked);

@override
String toString() {
  return 'UserProfile(id: $id, fullName: $fullName, email: $email, phone: $phone, city: $city, themePreference: $themePreference, desktopMode: $desktopMode, reminderEmailsEnabled: $reminderEmailsEnabled, authProvider: $authProvider, hasPassword: $hasPassword, googleLinked: $googleLinked)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 int id, String fullName, String email, String? phone, String? city, String themePreference, bool desktopMode, bool reminderEmailsEnabled, String authProvider, bool hasPassword, bool googleLinked
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? phone = freezed,Object? city = freezed,Object? themePreference = null,Object? desktopMode = null,Object? reminderEmailsEnabled = null,Object? authProvider = null,Object? hasPassword = null,Object? googleLinked = null,}) {
  return _then(_UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,themePreference: null == themePreference ? _self.themePreference : themePreference // ignore: cast_nullable_to_non_nullable
as String,desktopMode: null == desktopMode ? _self.desktopMode : desktopMode // ignore: cast_nullable_to_non_nullable
as bool,reminderEmailsEnabled: null == reminderEmailsEnabled ? _self.reminderEmailsEnabled : reminderEmailsEnabled // ignore: cast_nullable_to_non_nullable
as bool,authProvider: null == authProvider ? _self.authProvider : authProvider // ignore: cast_nullable_to_non_nullable
as String,hasPassword: null == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool,googleLinked: null == googleLinked ? _self.googleLinked : googleLinked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
